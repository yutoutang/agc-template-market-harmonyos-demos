import { common } from '@kit.AbilityKit';
import { CMChatConversationOperationResult, CMChatConversationResult } from '../viewmodels/CMChatConversation';
import {
  CMChatFriendCheckResult,
  CMChatFriendInfo,
  CMChatFriendOperationResult,
  CMChatUserInfo
} from '../viewmodels/CMChatGroupMemberInfo';
import { CMChatMessage } from '../viewmodels/CMChatMessage';
import { CMChatAdvanceMsgListener } from '../listener/CMChatAdvanceMsgListener';
import { CMChatConversationListener } from '../listener/CMChatConversationListener';
import { CMChatSDKListener } from '../listener/CMChatSDKListener';

export abstract class CMChatBase {
  //************** Manager im SDK 的初始化、登录、消息收发，建群退群等功能

  /**
   * 初始化 SDK

   * @return true：成功；false：失败
   */
  abstract initSDK(context: common.ApplicationContext, sdkAppID: number): boolean;

  /**
   * 添加 SDK 监听
   */
  abstract addSDKListener(listener: CMChatSDKListener): void;

  /**
   * 登录
   */
  abstract login(userID: string, userSig: string): Promise<void>;

  /**
   * 登出
   */
  abstract logout(): Promise<void>;

  /**
   * 获取登录状态
   *
   * 1: 已登录
   * 2: 登录中
   * 3: 无登录
   */
  abstract getLoginStatus(): number;

  /**
   * 修改个人资料（昵称、头像）
   */
  abstract setSelfInfo(nickName: string, avatar: string): Promise<void>;

  //************** ConversationManager 会话的获取，删除，更新的逻辑

  /**
   * 获取会话列表
   */
  abstract getConversationListByFilter(nextSeq: number, count?: number): Promise<CMChatConversationResult>;

  /**
   * 添加会话监听器
   */
  abstract addConversationListener(listener: CMChatConversationListener);

  /**
   * 移除会话监听器
   */
  abstract removeConversationListener();

  /**
   * 会话置顶
   */
  abstract pinConversation(conversationID: string, isPinned: boolean): Promise<void>;

  /**
   * 删除会话
   */
  abstract deleteConversation(conversationID: string): Promise<void>;

  /**
   * 删除会话列表
   *
   * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式为: "c2c_userID"：群聊组成方式为: "group_groupID"
   * @param clearMessage 是否删除会话中的消息；设置为 false 时，保留会话消息；设置为 true 时，本地和服务器的消息会一起删除，并且不可恢复
   */
  abstract deleteConversationList(conversationIDList: string[],
    clearMessage: boolean): Promise<CMChatConversationOperationResult[]>;

  /**
   * 清理会话的未读消息计数
   *
   * @param conversationID  会话唯一 ID，C2C 单聊组成方式为: "c2c_userID"；群聊组成方式为: "group_groupID"
   */
  abstract cleanConversationUnreadMessageCount(conversationID: string): Promise<void>;


  //************** FriendshipManager 好友的添加、删除，黑名单的添加、删除等逻辑
  /**
   * 添加好友
   */
  abstract addFriend(userID: string, nickName: string): Promise<CMChatFriendOperationResult>;

  /**
   * 删除好友
   *
   * @param userIDList 要删除的好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  abstract deleteFromFriendList(userIDList: string[]): Promise<CMChatFriendOperationResult[]>;

  /**
   * 获取好友列表
   */
  abstract getFriendList(): Promise<CMChatFriendInfo[]>;

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  abstract getFriendsInfo(userIDList: string[]): Promise<CMChatFriendInfo[]>;

  /** 检查指定用户的好友关系
   * 设置指定好友备注
   */
  abstract setFriendInfo(userID: string, friendRemark: string): Promise<void>;

  /**
   * 检查指定用户的好友关系
   *
   * @param userIDList 要检查的 userID 列表
   */
  abstract checkFriend(userIDList: string[]): Promise<CMChatFriendCheckResult[]>;

  //************** MessageManager 高级消息(图片、语音、视频等)的创建、收发逻辑

  /**
   * 监听 - 高级（图片、语音、视频等）消息
   */
  /**
   * 添加高级消息的事件监听器
   */
  abstract addAdvancedMsgListener(listener: CMChatAdvanceMsgListener);

  /**
   * 移除高级消息监听器
   */
  abstract removeAdvancedMsgListener();

  /**
   * 获取历史消息、撤回、删除、标记已读等高级接口
   *
   * 可以设置从云端、本地拉取更老或更新的消息
   */
  abstract getHistoryMessageList(userID?: string, groupID?: string, count?: number): Promise<CMChatMessage[]>;

  /**
   * 创建自定义消息
   */
  abstract createCustomMessage(data: ArrayBuffer, userId?: string, groupId?: string): Promise<CMChatMessage>;

  /**
   * 创建图片消息
   */
  abstract createImageMessage(imagePath: string, userId?: string, groupId?: string): Promise<CMChatMessage>;

  /**
   * 创建文件消息
   */
  abstract createFileMessage(filePath: string, fileName: string, userId?: string,
    groupId?: string): Promise<CMChatMessage>;

  /**
   * 创建语音消息
   */
  abstract createSoundMessage(soundPath: string, duration: number, userId?: string,
    groupId?: string): Promise<CMChatMessage>;

  /**
   * 创建转发消息
   */
  abstract createForwardMessage(forwardMsg?: Object, userId?: string,
    groupId?: string): Promise<CMChatMessage | undefined>;

  // ************** GroupManager 群组高级接口，里面包含了群组的高级功能，比如群成员邀请、非群成员申请进群等操作接口。
  /**
   *创建视频接口
   *
   */
  abstract addSimpleMsgListener(videoFilePath: string, type: string, duration: number,
    snapshotPath: string, userId?: string, groupId?: string): Promise<CMChatMessage>;
  /**
   *获取用户资料
   */
  abstract getUsersInfo(userIDList: string[]): Promise<CMChatUserInfo[]>
}