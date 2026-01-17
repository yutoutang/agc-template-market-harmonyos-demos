import request from '../common/BaseRequest';
import { AuthorRequest, SendMessageRequest } from '../params/request/CommonRequest';
import { AggregateNewsComment, CommentDetailResponse } from '../params/response/AggregateResponse';
import {
  BriefIMResponse,
  ChatInfoDetailResponse,
  SystemDetailInfo,
  BriefMsgInfo,
} from '../params/response/MessageResponse';

/**
 * 消息接口
 */
export class MessageService {
  /**
   * 查询评论与回复概要信息
   * @returns
   */
  public queryBriefCommentReply(): Promise<BriefMsgInfo> {
    return request.get('/brief/comment/reply');
  }

  /**
   * 查询私信简概要信息
   * @returns
   */
  public queryBriefIM(): Promise<BriefMsgInfo> {
    return request.get('/brief/im');
  }

  /**
   * 查询新增粉丝概要信息
   * @returns
   */
  public queryBriefNewFans(): Promise<BriefMsgInfo> {
    return request.get('/brief/new/fans');
  }

  /**
   * 查询系统消息概要信息
   * @returns
   */
  public queryBriefSystemInfo(): Promise<BriefMsgInfo> {
    return request.get('/brief/system/info');
  }

  /**
   * 查询评论与回复列表
   * @returns
   */
  public queryCommentReplyList(): Promise<AggregateNewsComment[]> {
    return request.get('/comment/reply/list');
  }

  /**
   * 查询单个评论消息的全部详情
   * @param commentId
   */
  public querySingleCommentList(commentId: string): Promise<CommentDetailResponse> {
    return request.get('/single/comment/list', { params: { commentId } });
  }

  /**
   * 查询所有私信
   * @returns
   */
  public queryAllIMList(): Promise<BriefIMResponse[]> {
    return request.get('/all/im/list');
  }

  /**
   * 进入单人聊天页面-消息已读
   * @param authorId
   */
  public setSingleChatRead(authorId: string): Promise<void> {
    const data: AuthorRequest = { authorId };
    return request.post('/single/chat/read', data);
  }

  /**
   * 查询和单个用户的全部聊天记录
   * @param authorId
   */
  public queryChatRecordByAuthorId(authorId: string): Promise<ChatInfoDetailResponse[]> {
    return request.get('/chat/record/list', { params: { authorId } });
  }

  /**
   * 发送私信
   * @param chatWithAuthorId
   * @param data
   */
  public sendMessage(chatWithAuthorId: string, data: SendMessageRequest): Promise<void> {
    return request.post('/send/message', data, { params: { authorId: chatWithAuthorId } });
  }

  /**
   * 查询所有系统消息
   * @returns
   */
  public queryAllSystemInfoList(): Promise<SystemDetailInfo[]> {
    return request.get('/all/system/info/list');
  }

  /**
   * 评论回复已读
   */
  public setReplyRead(): Promise<void> {
    return request.post('/reply/read');
  }

  /**
   * 私信一键已读
   */
  public setIMAllRead(): Promise<void> {
    return request.post('/im/read');
  }

  /**
   * 新增粉丝已读
   */
  public setNewFansRead(): Promise<void> {
    return request.post('/new/fans/read');
  }

  /**
   * 系统消息已读
   */
  public setSystemRead(): Promise<void> {
    return request.post('/system/read');
  }

  /**
   * 一键已读
   */
  public setAllRead() {
    return Promise.all([
      this.setReplyRead(),
      this.setIMAllRead(),
      this.setNewFansRead(),
      this.setSystemRead(),
    ])
  }
}

const instance = new MessageService();

export { instance as MessageServiceApi }