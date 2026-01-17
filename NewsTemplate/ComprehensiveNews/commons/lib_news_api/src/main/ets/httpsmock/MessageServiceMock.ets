import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { MockMessage } from './mockdata/MockMessage';
import { MockComment } from './mockdata/MockComment';
import { AuthorRequest, CommentRequest, SendMessageRequest } from '../params/request/CommonRequest';
import { CommentResponse } from '../params/response/CommentResponse';
import { BriefIMResponse, ChatInfoDetailResponse } from '../params/response/MessageResponse';
import { AggregateNewsComment, CommentDetailResponse } from '../params/response/AggregateResponse';
import { ChatInfoDetail, BriefIMInfo } from '../database/MessageType';
import { ChatEnum } from '../constants/Constants';
import { MockArticle } from './mockdata/MockArticle';
import { MockVideo } from './mockdata/MockVideo';
import { MockPost } from './mockdata/MockPost';
import { BaseNewsServiceMock } from './BaseNewsServiceMock';
import { AuthorServiceMock } from './AuthorServiceMock';
import { CommentServiceMock } from './CommentServiceMock';

/**
 * 消息Mock
 */
export class MessageServiceMock {
  private baseNewsMock: BaseNewsServiceMock = new BaseNewsServiceMock();
  private authorMock: AuthorServiceMock = new AuthorServiceMock();
  private commentMock: CommentServiceMock = new CommentServiceMock();

  public start(adapter: AxiosMockAdapter) {
    // 查询评论与回复概要信息
    adapter.onGet('/brief/comment/reply').reply(() => {
      return [HttpStatusCode.Ok, MockMessage.briefCommentReplyInfo];
    });

    // 查询私信简概要信息
    adapter.onGet('/brief/im').reply(() => {
      const authorId = MockMessage.allBriefIMList.filter(v => v.chatList.length)[0].chatAuthorId;
      const authorInfo = this.authorMock.queryAuthorInfo(authorId);
      MockMessage.briefIMInfo.latestNews = `${authorInfo?.authorNickName}  私信了你`;
      return [HttpStatusCode.Ok, MockMessage.briefIMInfo];
    });

    // 查询新增粉丝概要信息
    adapter.onGet('/brief/new/fans').reply(() => {
      return [HttpStatusCode.Ok, MockMessage.briefNewFansInfo];
    });

    // 查询系统消息概要信息
    adapter.onGet('/brief/system/info').reply(() => {
      return [HttpStatusCode.Ok, MockMessage.briefSystemInfo];
    });

    // 查询评论与回复列表
    adapter.onGet('/comment/reply/list').reply(() => {
      const mineInfo = this.authorMock.queryAuthorInfo()!;
      const myNewsList = [...MockArticle.list, ...MockVideo.list, ...MockPost.list]
        .filter(v => v.authorId === mineInfo.authorId)
        .map(v => this.baseNewsMock.handleRawNews(v, true))
      // 场景1：我的文章被别人评论
      const myNewsCommentList = MockComment.list
        .filter(v => myNewsList.map(item => item.id).includes(v.newsId))
        .filter(v => !v.parentCommentId)

      // 场景2：我的评论被回复
      const myCommentList = MockComment.list
        .filter(v => v.authorId === mineInfo.authorId)
        .filter(v => !v.parentCommentId)
        .filter(v => v.replyComments.length)

      // 场景3：我的回复被回复
      const myReplyList = MockComment.list
        .filter(v => v.authorId === mineInfo.authorId)
        .filter(v => v.parentCommentId)
        .filter(v => MockComment.list.map(item => item.parentCommentId).includes(v.commentId))

      const finalList = [...myNewsCommentList, ...myCommentList, ...myReplyList]
        .map(v => this.commentMock.queryComment(v.commentId)!)
        .filter(v => Boolean(v))
        .map(v => {
          const item = v as AggregateNewsComment;
          let news = this.baseNewsMock.queryNews(v.newsId);
          if (news) {
            item.newsDetailInfo = news;
          }
          return item;
        })

      return [HttpStatusCode.Ok, finalList];
    });

    // 查询单个评论消息的全部详情
    adapter.onGet('/single/comment/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as CommentRequest;
      const commentId = params.commentId;
      let current: CommentResponse | undefined = undefined;
      const rootId = this.commentMock.queryRootComment(commentId);
      const root = this.commentMock.queryComment(rootId) as AggregateNewsComment;

      let resp = this.baseNewsMock.queryNews(root.newsId);
      if (resp) {
        root.newsDetailInfo = resp;
      }
      if (rootId !== commentId) {
        current = this.commentMock.queryComment(commentId);
      }
      const replyList = this.commentMock.queryAllReplyComment(rootId);
      const list = replyList
        .filter(v => ![root.commentId, current?.commentId].includes(v.commentId))

      const result: CommentDetailResponse = {
        root,
        current,
        list,
      };
      return [HttpStatusCode.Ok, result];
    });

    // 查询所有私信
    adapter.onGet('/all/im/list').reply(() => {
      const list = MockMessage.allBriefIMList
        .map(item => {
          const copyItem = JSON.parse(JSON.stringify(item)) as BriefIMResponse;
          const authorInfo = this.authorMock.queryAuthorInfo(item.chatAuthorId);
          if (authorInfo) {
            copyItem.chatAuthor = authorInfo;
          }
          // 更新下最新消息
          copyItem.latestNews = copyItem.chatList.pop()?.content || '';
          return copyItem;
        })
        .filter(v => v.chatList.length);
      return [HttpStatusCode.Ok, list];
    });

    // 进入单人聊天页面-消息已读
    adapter.onPost('/single/chat/read').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as AuthorRequest;
      const item = MockMessage.allBriefIMList.find(v => v.chatAuthorId === data.authorId);
      if (item) {
        item.allUnreadCount = 0;
      }
      MockMessage.briefIMInfo.allUnreadCount = MockMessage.allBriefIMList.reduce((acc: number, cur: BriefIMInfo) => {
        return acc + cur.allUnreadCount;
      }, 0);
      return [HttpStatusCode.Ok];
    });

    // 查询和单个用户的全部聊天记录
    adapter.onGet('/chat/record/list').reply((config: AxiosRequestConfig) => {
      const params = config.params as AuthorRequest;
      const authorId = params.authorId;
      let list: ChatInfoDetail[] = [];
      const item = MockMessage.allBriefIMList.find(v => v.chatAuthorId === authorId);
      if (item) {
        list = item.chatList;
      } else {
        const newItem: BriefIMInfo = {
          chatAuthorId: authorId,
          allUnreadCount: 0,
          receiveTime: new Date().getTime(),
          latestNews: '',
          chatList: list,
        };
        MockMessage.allBriefIMList.splice(0, 0, newItem);
      }

      const result = list.map(item => {
        const copyItem: ChatInfoDetailResponse = {
          type: item.type,
          content: item.content,
          isMyself: item.isMyself,
          createTime: item.createTime,
        };
        return copyItem;
      })

      return [HttpStatusCode.Ok, result];
    });

    // 发送私信
    adapter.onPost('/send/message').reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as SendMessageRequest;
      const params = config.params as AuthorRequest;
      const info: ChatInfoDetail = {
        type: data.type,
        content: data.content,
        isMyself: true,
        createTime: data.createTime ?? new Date().getTime(),
      };
      const item = MockMessage.allBriefIMList.find(v => v.chatAuthorId === params.authorId);
      if (item) {
        let list: ChatInfoDetail[] = item.chatList;
        list.push(info);

        const reply: ChatInfoDetail = {
          type: ChatEnum.Text,
          content: '感谢你的消息！',
          isMyself: false,
          createTime: new Date().getTime(),
        };
        list.push(reply);
      }

      return [HttpStatusCode.Ok];
    });

    // 查询所有系统消息
    adapter.onGet('/all/system/info/list').reply(() => {
      return [HttpStatusCode.Ok, MockMessage.allSystemInfoList];
    });

    // 评论回复已读
    adapter.onPost('/reply/read').reply(() => {
      MockMessage.briefCommentReplyInfo.allUnreadCount = 0;
      return [HttpStatusCode.Ok];
    });

    // 私信一键已读
    adapter.onPost('/im/read').reply(() => {
      MockMessage.allBriefIMList.forEach(v => v.allUnreadCount = 0);
      MockMessage.briefIMInfo.allUnreadCount = 0;
      return [HttpStatusCode.Ok];
    });

    // 新增粉丝已读
    adapter.onPost('/new/fans/read').reply(() => {
      MockMessage.briefNewFansInfo.allUnreadCount = 0;
      return [HttpStatusCode.Ok];
    });

    // 系统消息已读
    adapter.onPost('/system/read').reply(() => {
      MockMessage.briefSystemInfo.allUnreadCount = 0;
      return [HttpStatusCode.Ok];
    });
  }
}