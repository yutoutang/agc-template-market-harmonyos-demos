import { common } from '@kit.AbilityKit';
import {
  V2TIMAdvancedMsgListener,
  V2TIMConversation,
  V2TIMConversationFilterType,
  V2TIMConversationListener,
  V2TIMConversationListFilter,
  V2TIMElemType,
  V2TIMFriendAddApplication,
  V2TIMFriendInfo,
  V2TIMFriendRelationType,
  V2TIMFriendType,
  V2TIMLogLevel,
  V2TIMManager,
  V2TIMMessage,
  V2TIMMessageGetType,
  V2TIMMessageListGetOption,
  V2TIMSDKConfig,
  V2TIMSDKListener,
  V2TIMSetFriendInfoParam,
  V2TIMSetSelfInfoParam
} from '@tencentcloud/imsdk';
import { CMChatBase } from './CMChatBase';
import {
  CMChatConversation,
  CMChatConversationOperationResult,
  CMChatConversationResult
} from '../viewmodels/CMChatConversation';
import { ChatAudio, ChatImage, CMChatMessage } from '../viewmodels/CMChatMessage';
import { CMChatConversationListener } from '../listener/CMChatConversationListener';
import { CMChatSDKListener } from '../listener/CMChatSDKListener';
import {
  CMChatFriendCheckResult,
  CMChatFriendInfo,
  CMChatFriendOperationResult,
  CMChatUserInfo
} from '../viewmodels/CMChatGroupMemberInfo';
import { CMChatAdvanceMsgListener } from '../listener/CMChatAdvanceMsgListener';
import { CONVERSATION_COUNT, MESSAGE_COUNT } from '../constants/Constants';

/**
 * 1、腾讯云SDK群消息中没有群备注和个人在群里面的昵称，两个字段的读写；需要在腾讯云控制台中功能配置->群组配置->群自定义字段中添加
 * 群备注：groupRemark和个人在群里面的昵称：groupMiRemark，两个字段，群类型是public 陌生人社交群；
 *
 * 2、
 */

export class CMChatTencent extends CMChatBase {
  private advancedMsgListener: V2TIMAdvancedMsgListener | undefined;
  private conversationListener: V2TIMConversationListener | undefined;

  //************** Manager im SDK 的初始化、登录、消息收发，建群退群等功能
  /**
   * 初始化 SDK

   * @return true：成功；false：失败
   */
  initSDK(context: common.ApplicationContext, sdkAppID: number): boolean {
    let config: V2TIMSDKConfig = {
      logLevel: V2TIMLogLevel.V2TIM_LOG_DEBUG,
      logListener: undefined
    }
    let result = V2TIMManager.getInstance().initSDK(context, sdkAppID, config);
    return result;
  }

  /**
   * 添加 SDK 监听
   */
  addSDKListener(listener: CMChatSDKListener): void {
    let imListener: V2TIMSDKListener = {
      onKickedOffline: () => {
        listener.onKickedOffline?.();
      }
    }
    V2TIMManager.getInstance().addSDKListener(imListener);
  }

  /**
   * 登录
   */
  async login(userID: string, userSig: string): Promise<void> {
    await V2TIMManager.getInstance().login(userID, userSig);
  }

  /**
   * 登出
   */
  async logout(): Promise<void> {
    await V2TIMManager.getInstance().logout();
  }

  /**
   * 获取登录状态
   *
   * 1: 已登录
   * 2: 登录中
   * 3: 无登录
   */
  getLoginStatus(): number {
    let result = V2TIMManager.getInstance().getLoginStatus();
    return result;
  }

  /**
   * 修改个人资料（昵称、头像）
   */
  async setSelfInfo(nickName: string, avatar: string): Promise<void> {
    let info: V2TIMSetSelfInfoParam = {
      nickName: nickName,
      faceURL: avatar
    }
    await V2TIMManager.getInstance().setSelfInfo(info);
  }

  //************** ConversationManager 会话的获取，删除，更新的逻辑

  /**
   * 获取会话列表
   */
  async getConversationListByFilter(nextSeq: number, count?: number): Promise<CMChatConversationResult> {
    if (count === undefined) {
      count = CONVERSATION_COUNT;
    }
    let filter: V2TIMConversationListFilter = {
      filterType: V2TIMConversationFilterType.V2TIM_CONVERSATION_FILTER_TYPE_NONE,
      markType: 0,
      hasUnreadCount: true
    }
    let result = await V2TIMManager.getConversationManager().getConversationListByFilter(nextSeq, count, filter);
    let chatResult = new CMChatConversationResult();
    chatResult.nextSeq = result.nextSeq;
    chatResult.isFinished = result.isFinished;
    chatResult.conversationList = await this.parseConversationList(result.conversationList);
    return chatResult;
  }

  private async parseConversationList(conversationList: V2TIMConversation[]) {
    let chatConversationList: CMChatConversation[] = [];
    for (let index = 0; index < conversationList.length; index++) {
      const element = conversationList[index];
      let conversationModel = new CMChatConversation();
      conversationModel.type = element.type;
      conversationModel.userId = element.userID;
      conversationModel.groupID = element.groupID;
      conversationModel.showName = element.showName;
      conversationModel.faceURL = element.faceUrl;
      conversationModel.conversationID = element.conversationID;
      conversationModel.unreadCount = element.unreadCount;
      conversationModel.isPinned = element.isPinned;
      conversationModel.lastMessage = await this.parseMessage(element.lastMessage);
      chatConversationList.push(conversationModel);
    }
    return chatConversationList;
  }

  /**
   * 添加会话监听器
   */
  addConversationListener(listener: CMChatConversationListener) {
    this.conversationListener = {
      onNewConversation: (_conversationList: V2TIMConversation[]) => {
        listener.onNewConversation?.();
      },
      onConversationChanged: (_conversationList: V2TIMConversation[]) => {
        listener.onConversationChanged?.();
      }
    }
    V2TIMManager.getConversationManager().addConversationListener(this.conversationListener);
  }

  /**
   * 移除会话监听器
   */
  removeConversationListener() {
    if (this.conversationListener) {
      V2TIMManager.getConversationManager().removeConversationListener(this.conversationListener);
    }
  }

  /**
   * 会话置顶
   */
  async pinConversation(conversationID: string, isPinned: boolean): Promise<void> {
    await V2TIMManager.getConversationManager().pinConversation(conversationID, isPinned);
  }

  /**
   * 删除会话
   */
  async deleteConversation(conversationID: string): Promise<void> {
    await V2TIMManager.getConversationManager().deleteConversation(conversationID);
  }

  /**
   * 删除会话列表
   *
   * @param conversationIDList 会话唯一 ID 列表，C2C 单聊组成方式为: "c2c_userID"：群聊组成方式为: "group_groupID"
   * @param clearMessage 是否删除会话中的消息；设置为 false 时，保留会话消息；设置为 true 时，本地和服务器的消息会一起删除，并且不可恢复
   */
  async deleteConversationList(conversationIDList: string[],
    clearMessage: boolean): Promise<CMChatConversationOperationResult[]> {
    let result = await V2TIMManager.getConversationManager().deleteConversationList(conversationIDList, clearMessage);
    let operationResults: CMChatConversationOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatConversationOperationResult();
      operationResult.conversationID = element.conversationID;
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResults.push(operationResult);
    }
    return operationResults;
  }

  /**
   * 清理会话的未读消息计数
   *
   * @param conversationID  会话唯一 ID，C2C 单聊组成方式为: "c2c_userID"；群聊组成方式为: "group_groupID"
   */
  async cleanConversationUnreadMessageCount(conversationID: string): Promise<void> {
    return await V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(conversationID,
      { cleanTimestamp: new Date().getTime(), cleanSequence: 0 });
  }

  //************** FriendshipManager 好友的添加、删除，黑名单的添加、删除等逻辑
  /**
   * 添加好友
   */
  async addFriend(userID: string, nickName: string): Promise<CMChatFriendOperationResult> {
    let application: V2TIMFriendAddApplication = {
      userID: userID,
      friendRemark: nickName,
      addType: 2
    }
    let result = await V2TIMManager.getFriendshipManager().addFriend(application);
    let operationResult = new CMChatFriendOperationResult();
    operationResult.resultCode = result.resultCode;
    operationResult.resultInfo = result.resultInfo;
    operationResult.userID = result.userID;
    return operationResult;
  }

  /**
   * 删除好友
   *
   * @param userIDList 要删除的好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async deleteFromFriendList(userIDList: string[]): Promise<CMChatFriendOperationResult[]> {
    let result = await V2TIMManager.getFriendshipManager()
      .deleteFromFriendList(userIDList, V2TIMFriendType.V2TIM_FRIEND_TYPE_BOTH);
    let operationList: CMChatFriendOperationResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let operationResult = new CMChatFriendOperationResult();
      operationResult.resultCode = element.resultCode;
      operationResult.resultInfo = element.resultInfo;
      operationResult.userID = element.userID;
      operationList.push(operationResult);
    }
    return operationList;
  }

  /**
   * 获取好友列表
   */
  async getFriendList(): Promise<CMChatFriendInfo[]> {
    let result = await V2TIMManager.getFriendshipManager().getFriendList();
    let friendList: CMChatFriendInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let message = this.parseFriendInfo(element);
      friendList.push(message);
    }
    return friendList;
  }

  private parseFriendInfo(element: V2TIMFriendInfo) {
    let friend = new CMChatFriendInfo();
    friend.userId = element.userID;
    friend.nickName = element.userFullInfo.nickName;
    friend.avatarUrl = element.userFullInfo.faceURL;
    friend.friendRemark = element.friendRemark;
    friend.selfSignature = element.userFullInfo.selfSignature;
    return friend;
  }

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async getFriendsInfo(userIDList: string[]): Promise<CMChatFriendInfo[]> {
    let result = await V2TIMManager.getFriendshipManager().getFriendsInfo(userIDList);
    let friendList: CMChatFriendInfo[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let message = this.parseFriendInfo(element.friendInfo);
      friendList.push(message);
    }
    return friendList;
  }

  /**
   * 设置指定好友备注
   */
  async setFriendInfo(userID: string, friendRemark: string): Promise<void> {
    let option: V2TIMSetFriendInfoParam = {
      userID: userID,
      friendRemark: friendRemark
    }
    return await V2TIMManager.getFriendshipManager().setFriendInfo(option)
      .then(() => {
      })
      .catch(() => {
      });
  }

  /**
   * 检查指定用户的好友关系
   *
   * @param userIDList 要检查的 userID 列表
   */
  async checkFriend(userIDList: string[]): Promise<CMChatFriendCheckResult[]> {
    let result = await V2TIMManager.getFriendshipManager().checkFriend(userIDList, 2);
    let friendList: CMChatFriendCheckResult[] = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let friend = new CMChatFriendCheckResult();
      friend.userId = element.userID;
      friend.resultCode = element.resultCode;
      friend.resultInfo = element.resultInfo;
      friend.isFriend = element.relationType === V2TIMFriendRelationType.V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY;
      friendList.push(friend);
    }
    return friendList;
  }

  //************** MessageManager 高级消息(图片、语音、视频等)的创建、收发逻辑

  /**
   * 监听 - 高级（图片、语音、视频等）消息
   */
  /**
   * 添加高级消息的事件监听器
   */
  addAdvancedMsgListener(listener: CMChatAdvanceMsgListener) {
    this.advancedMsgListener = {
      onRecvNewMessage: async (message: V2TIMMessage) => {
        listener.onRecvNewMessage?.(await this.parseMessage(message));
      }
    }
    V2TIMManager.getMessageManager().addAdvancedMsgListener(this.advancedMsgListener);
  }

  removeAdvancedMsgListener() {
    if (this.advancedMsgListener) {
      V2TIMManager.getMessageManager().removeAdvancedMsgListener(this.advancedMsgListener);
    }
  }

  /**
   * 获取历史消息、撤回、删除、标记已读等高级接口
   *
   * 可以设置从云端、本地拉取更老或更新的消息
   */
  async getHistoryMessageList(userID?: string, groupID?: string, count?: number): Promise<CMChatMessage[]> {
    if (count === undefined) {
      count = MESSAGE_COUNT;
    }
    let option: V2TIMMessageListGetOption = {
      getType: V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG,
      count: count,
      userID: userID,
      groupID: groupID
    }
    let result = await V2TIMManager.getMessageManager().getHistoryMessageList(option);
    let messageList: CMChatMessage[] = [];
    for (let index = result.length - 1; index >= 0; index--) {
      const element = result[index];
      let message = await this.parseMessage(element);
      messageList.push(message);
    }
    return messageList;
  }

  setMessage1(element: V2TIMMessage, message: CMChatMessage) {
    message.forwardMessage = element;
    message.msgID = element.msgID;
    message.timestamp = element.timestamp;
    message.sender = element.sender;
    message.nickName = element.nickName;
    message.friendRemark = element.friendRemark;
    message.faceURL = element.faceURL;
    message.elemType = element.elemType;
    message.groupID = element.groupID;
    message.userID = element.userID;
    message.seq = element.seq;
    message.isSelf = element.isSelf;
    message.customElem = element.customElem?.data ?? new ArrayBuffer(0);
    message.imageElem = element.imageElem?.path ?? '';
    message.soundElem = element.soundElem ?? {};
    let locationDesc = element.locationElem?.desc ?? '';
    let locationDescList = locationDesc.split('|LOCATION|');
    message.locationName = locationDescList[0] ?? '';
    message.locationDesc = locationDescList[1] ?? '';
    message.fileName = element.fileElem?.filename ?? ''
    message.type = element.videoElem?.videoType ?? '';
    message.duration = element.videoElem?.videoSize ?? 0;
    message.locationLongitude = element.locationElem?.longitude ?? 0;
    message.locationLatitude = element.locationElem?.latitude ?? 0;
    return message
  }

  async setMessage2(element: V2TIMMessage, message: CMChatMessage) {
    message.videoChatSrc = await element.videoElem?.getVideoUrl() ?? '';
    message.fileChatUrl = await element.fileElem?.getUrl() ?? '';
    message.snapshotPath = await element.videoElem?.getSnapshotUrl() ?? '';
    if (element.imageElem !== undefined) {
      message.imageInfo = this.parseImageInfo(element)
    }
    if (element.elemType === V2TIMElemType.V2TIM_ELEM_TYPE_SOUND && element.soundElem !== undefined) {
      message.soundInfo = await this.parseSoundInfo(element)
    }
    return message
  }

  private async parseMessage(element: V2TIMMessage) {
    let message = new CMChatMessage();
    message = this.setMessage1(element, message)
    message = await this.setMessage2(element, message)
    return message;
  }

  /**
   * 图片数据解析，排序返回
   */
  private parseImageInfo(element: V2TIMMessage): ChatImage[] {
    let imgInfoList: ChatImage[] = []
    element.imageElem?.imageList.forEach((item) => {
      const tmpImgInfo = new ChatImage()
      tmpImgInfo.uuid = item.uuid
      tmpImgInfo.type = item.type
      tmpImgInfo.size = item.size
      tmpImgInfo.width = item.width
      tmpImgInfo.height = item.height
      tmpImgInfo.url = item.url
      imgInfoList.push(tmpImgInfo)
    })
    imgInfoList.sort((a: ChatImage, b: ChatImage) => {
      if (a.type === 2) {
        return -1
      }

      if (b.type === 2) {
        return 1
      }

      // 倒叙，大图在前，原图在后
      return b.type - a.type
    })

    return imgInfoList
  }

  /**
   * 图片数据解析，排序返回
   */
  private async parseSoundInfo(element: V2TIMMessage): Promise<ChatAudio> {
    const audioInfo: ChatAudio = new ChatAudio()
    audioInfo.path = element.soundElem!.path
    audioInfo.uuid = element.soundElem!.uuid
    audioInfo.dataSize = element.soundElem!.dataSize
    audioInfo.duration = element.soundElem!.duration
    audioInfo.url = await element.soundElem!.getUrl()

    return audioInfo
  }

  /**
   * 创建自定义消息
   */
  async createCustomMessage(data: ArrayBuffer, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let customMessage = V2TIMManager.getMessageManager().createCustomMessage(data);
    let result = V2TIMManager.getMessageManager().sendMessage(customMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建图片消息
   */
  async createImageMessage(imagePath: string, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let imageMessage = V2TIMManager.getMessageManager().createImageMessage(imagePath);
    let result = V2TIMManager.getMessageManager().sendMessage(imageMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建文件消息
   */
  async createFileMessage(filePath: string, fileName: string, userId?: string,
    groupId?: string): Promise<CMChatMessage> {
    let fileMessage = V2TIMManager.getMessageManager().createFileMessage(filePath, fileName);
    let result = V2TIMManager.getMessageManager().sendMessage(fileMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建语音消息
   */
  async createSoundMessage(soundPath: string, duration: number, userId?: string,
    groupId?: string): Promise<CMChatMessage> {
    let soundMessage = V2TIMManager.getMessageManager().createSoundMessage(soundPath, duration)
    let result = V2TIMManager.getMessageManager().sendMessage(soundMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let messageResult = await result.promise;
    let message = this.parseMessage(messageResult);
    return message;
  }

  /**
   * 创建转发消息
   */
  async createForwardMessage(forwardMsg?: Object, userId?: string,
    groupId?: string): Promise<CMChatMessage | undefined> {
    if (forwardMsg) {
      try {
        let targetMsg = forwardMsg as V2TIMMessage;
        let forward = V2TIMManager.getMessageManager().createForwardMessage(targetMsg);
        let result = V2TIMManager.getMessageManager().sendMessage(forward,
          { receiver: userId, groupID: groupId, priority: 2 });
        let messageResult = await result.promise;
        let forwardResult = this.parseMessage(messageResult);
        return forwardResult;
      } catch (err) {
        return undefined;
      }
    }
    return undefined;
  }

  /**
   * 创建视频图片接口请求
   * @param element
   * @returns
   */
  async addSimpleMsgListener(videoFilePath: string, type: string, duration: number,
    snapshotPath: string, userId?: string, groupId?: string): Promise<CMChatMessage> {
    let videoMessage =
      V2TIMManager.getMessageManager().createVideoMessage(videoFilePath, type, duration, snapshotPath);
    let result = V2TIMManager.getMessageManager().sendMessage(videoMessage,
      { receiver: userId, groupID: groupId, priority: 2 });
    let videoResult = await result.promise;
    let message = this.parseMessage(videoResult);
    return message;
  }
  /**
   * 获取用户资料
   */
  async getUsersInfo(userIDList: string[]): Promise<CMChatUserInfo[]> {
    let cMChatUserInfoList = await V2TIMManager.getInstance().getUsersInfo(userIDList)
    let groupMemberOperationResult: CMChatUserInfo[] = []
    for (let i = 0; i < cMChatUserInfoList.length; i++) {
      groupMemberOperationResult[i].userId = cMChatUserInfoList[i].userID;
      groupMemberOperationResult[i].nickName = cMChatUserInfoList[i].nickName
      groupMemberOperationResult[i].avatarUrl = cMChatUserInfoList[i].faceURL
    }
    return groupMemberOperationResult
  }
}