import { AsyncClass } from '../utils/AsyncUtils';
import { MockMessage } from './mockdata/MockMessage';
import { BriefIMResponse, ChatInfoDetailResponse } from '../params/response/MessageResponse';
import { AuthorServiceApi } from './AuthorService';
import { BriefIMInfo, ChatInfoDetail } from '../database/MessageType';
import { SendMessageRequest } from '../params/request/CommonRequest';
import { ChatEnum } from '../constants/Constants';
import { MockComment } from './mockdata/MockComment';
import { CommentServiceApi } from './CommentService';
import { AggregateNewsComment, CommentDetailResponse } from '../params/response/AggregateResponse';
import { CommentResponse } from '../params/response/CommentResponse';
import { VideoServiceApi } from './VideoService';

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
   * 查询我的所有评论和回复
   * @returns
   */
  public async queryMyAllCommentsAndReplies(): Promise<AggregateNewsComment[]> {
    const mineInfo = AuthorServiceApi.queryAuthorInfo()!;
    // 获取我发表的所有评论（包括主评论和回复）
    const myAllComments = MockComment.list
      .filter(v => v.authorId === mineInfo.authorId)

    // 分离主评论和回复
    const myMainComments = myAllComments.filter(v => !v.parentCommentId);
    const myReplies = myAllComments.filter(v => v.parentCommentId);

    // 处理主评论
    const mainCommentsResult = myMainComments.map(comment => {
      const aggregateComment = CommentServiceApi.queryComment(comment.commentId) as AggregateNewsComment;
      const videoDetail = VideoServiceApi.queryVideoDetail(comment.videoId);
      if (videoDetail) {
        aggregateComment.videoDetailInfo = videoDetail;
      }
      return aggregateComment;
    }).filter(v => Boolean(v)) as AggregateNewsComment[];

    // 处理回复（需要找到被回复的评论并添加到其replyComments中）
    myReplies.forEach(reply => {
      const parentComment = CommentServiceApi.queryComment(reply.commentId);
      if (parentComment) {
        const videoDetail = VideoServiceApi.queryVideoDetail(reply.videoId);
        if (videoDetail) {
          (parentComment as AggregateNewsComment).videoDetailInfo = videoDetail;
        }
      }
    });

    return mainCommentsResult;
  }

  /**
   * 删除单条评论
   * @param commentId 要删除的评论ID
   */
  public async deleteComment(commentId: string): Promise<void> {
    // 1. 从模拟数据中删除主评论
    const mainCommentIndex = MockComment.list.findIndex(c => c.commentId === commentId);
    if (mainCommentIndex > -1) {
      MockComment.list.splice(mainCommentIndex, 1);
    }
  }

  /**
   * 删除我的所有评论和回复
   */
  public async deleteAllComments(): Promise<void> {
    const mineInfo = AuthorServiceApi.queryAuthorInfo()!;
    // 从模拟数据中过滤掉所有我发表的评论
    MockComment.list = MockComment.list.filter(comment => comment.authorId !== mineInfo.authorId);
  }

  /**
   * 查询单个评论消息的全部详情
   * @param commentInfo
   */
  public async querySingleCommentList(commentId: string): Promise<CommentDetailResponse> {
    let current: CommentResponse | undefined = undefined;
    const rootId = CommentServiceApi.queryRootComment(commentId);
    const root = CommentServiceApi.queryComment(rootId) as AggregateNewsComment;
    const resp = VideoServiceApi.queryVideoDetail(root.videoId);
    if (resp) {
      root.videoDetailInfo = resp;
    }
    if (rootId !== commentId) {
      current = CommentServiceApi.queryComment(commentId);
    }
    const list = (root?.replyComments || [])
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