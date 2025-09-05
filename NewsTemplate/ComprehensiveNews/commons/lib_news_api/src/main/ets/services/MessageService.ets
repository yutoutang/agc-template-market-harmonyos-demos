import { AsyncClass } from '../utils/AsyncUtils';
import { MockMessage } from './mockdata/MockMessage';
import { BriefIMResponse, ChatInfoDetailResponse } from '../params/response/MessageResponse';
import { AuthorServiceApi } from './AuthorService';
import { ChatInfoDetail, BriefIMInfo } from '../database/MessageType';
import { SendMessageRequest } from '../params/request/CommonRequest';
import { ChatEnum } from '../constants/Constants';
import { BaseNewsServiceApi } from './BaseNewsService';
import { MockComment } from './mockdata/MockComment';
import { CommentServiceApi } from './CommentService';
import { AggregateNewsComment, CommentDetailResponse } from '../params/response/AggregateResponse';
import { CommentResponse } from '../params/response/CommentResponse';

/**
 * 消息接口
 */
@AsyncClass
export class MessageService {
  /**
   * 查询评论与回复概要信息
   * @returns
   */
  public async queryBriefCommentReply() {
    return MockMessage.briefCommentReplyInfo;
  }

  /**
   * 查询私信简概要信息
   * @returns
   */
  public async queryBriefIM() {
    const authorId = MockMessage.allBriefIMList.filter(v => v.chatList.length)[0].chatAuthorId;
    const authorInfo = AuthorServiceApi.queryAuthorInfo(authorId);
    MockMessage.briefIMInfo.latestNews = `${authorInfo?.authorNickName}  私信了你`;
    return MockMessage.briefIMInfo;
  }

  /**
   * 查询新增粉丝概要信息
   * @returns
   */
  public async queryBriefNewFans() {
    return MockMessage.briefNewFansInfo;
  }

  /**
   * 查询系统消息概要信息
   * @returns
   */
  public async queryBriefSystemInfo() {
    return MockMessage.briefSystemInfo;
  }

  /**
   * 查询评论与回复列表
   * @returns
   */
  public async queryCommentReplyList(): Promise<AggregateNewsComment[]> {
    const mineInfo = AuthorServiceApi.queryAuthorInfo()!;
    const myNewsList = BaseNewsServiceApi.queryAllNews(mineInfo.authorId);
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
      .map(v => CommentServiceApi.queryComment(v.commentId)!)
      .filter(v => Boolean(v))
      .map(v => {
        const item = v as AggregateNewsComment;
        const resp = BaseNewsServiceApi.queryNews(v.newsId);
        if (resp) {
          item.newsDetailInfo = resp;
        }
        return item;
      })

    return finalList;
  }

  /**
   * 查询单个评论消息的全部详情
   * @param commentInfo
   */
  public async querySingleCommentList(commentId: string): Promise<CommentDetailResponse> {
    let current: CommentResponse | undefined = undefined;
    const rootId = CommentServiceApi.queryRootComment(commentId);
    const root = CommentServiceApi.queryComment(rootId) as AggregateNewsComment;
    const resp = BaseNewsServiceApi.queryNews(root.newsId);
    if (resp) {
      root.newsDetailInfo = resp;
    }
    if (rootId !== commentId) {
      current = CommentServiceApi.queryComment(commentId);
    }
    const replyList = CommentServiceApi.queryAllReplyComment(rootId);
    const list = replyList
      .filter(v => ![root.commentId, current?.commentId].includes(v.commentId))

    return {
      root,
      current,
      list,
    };
  }

  /**
   * 查询所有私信
   * @returns
   */
  public async queryAllIMList(): Promise<BriefIMResponse[]> {
    return MockMessage.allBriefIMList
      .map(item => {
        const copyItem = JSON.parse(JSON.stringify(item)) as BriefIMResponse;
        const authorInfo = AuthorServiceApi.queryAuthorInfo(item.chatAuthorId);
        if (authorInfo) {
          copyItem.chatAuthor = authorInfo;
        }
        // 更新下最新消息
        copyItem.latestNews = copyItem.chatList.pop()?.content || '';
        return copyItem;
      })
      .filter(v => v.chatList.length);
  }

  /**
   * 进入单人聊天页面-消息已读
   * @param authorId
   */
  public setSingleChatRead(authorId: string) {
    const item = MockMessage.allBriefIMList.find(v => v.chatAuthorId === authorId);
    if (item) {
      item.allUnreadCount = 0;
    }
    MockMessage.briefIMInfo.allUnreadCount = MockMessage.allBriefIMList.reduce((acc: number, cur: BriefIMInfo) => {
      return acc + cur.allUnreadCount;
    }, 0);
  }


  /**
   * 查询和单个用户的全部聊天记录
   * @param authorId
   */
  public async queryChatRecordByAuthorId(authorId: string): Promise<ChatInfoDetailResponse[]> {
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

    return list.map(item => {
      const copyItem: ChatInfoDetailResponse = {
        type: item.type,
        content: item.content,
        isMyself: item.isMyself,
        createTime: item.createTime,
      };
      return copyItem;
    })
  }

  /**
   * 发送私信
   * @param chatWithAuthorId
   * @param data
   */
  public async sendMessage(chatWithAuthorId: string, data: SendMessageRequest) {
    const info: ChatInfoDetail = {
      type: data.type,
      content: data.content,
      isMyself: true,
      createTime: data.createTime ?? new Date().getTime(),
    };
    const item = MockMessage.allBriefIMList.find(v => v.chatAuthorId === chatWithAuthorId);
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
  }

  /**
   * 查询所有系统消息
   * @returns
   */
  public async queryAllSystemInfoList() {
    return MockMessage.allSystemInfoList;
  }

  /**
   * 评论回复已读
   */
  public async setReplyRead() {
    MockMessage.briefCommentReplyInfo.allUnreadCount = 0;
  }

  /**
   * 私信一键已读
   */
  public async setIMAllRead() {
    MockMessage.allBriefIMList.forEach(v => v.allUnreadCount = 0);
    MockMessage.briefIMInfo.allUnreadCount = 0;
  }

  /**
   * 新增粉丝已读
   */
  public async setNewFansRead() {
    MockMessage.briefNewFansInfo.allUnreadCount = 0;
  }

  /**
   * 系统消息已读
   */
  public async setSystemRead() {
    MockMessage.briefSystemInfo.allUnreadCount = 0;
  }

  /**
   * 一键已读
   */
  public async setAllRead() {
    this.setReplyRead();
    this.setIMAllRead();
    this.setNewFansRead();
    this.setSystemRead();
  }
}

const instance = new MessageService();

export { instance as MessageServiceApi }