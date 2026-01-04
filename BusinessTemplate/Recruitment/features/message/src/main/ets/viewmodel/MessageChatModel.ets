import { BusinessError, pasteboard, systemDateTime } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { Constants, getPositionByHR, GlobalContext, PositionInfo, RouterMap, TValueType, UserInfo } from 'common';
import { CMChatConversation, CMChatFactory, CMChatMessage } from 'instant_messaging';
import { MessageUtil } from '../utils/MessageUtil';
import { ChatInputSendMessageModel } from 'chat_input';
import { ChatContentAudio, ChatContentImage, ChatContentSingleModel, ChatTypeEnum, RcpDownloader } from 'chat_base';
import { phoneRouterControl } from 'oh_router';
import { POP_MENU_TYPE } from 'chat_window/src/main/ets/model/BubbleMsgModel';
import { common } from '@kit.AbilityKit';
import { SpeechRecognizerU } from '../utils/SpeechRecognizerU';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { ForwardChatPageBuilder } from '../view/ForwardChatPage';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { AudioRendererUtil } from '../utils/AudioRendererUtil';
import { audio } from '@kit.AudioKit';
import { ResumeEntity } from 'file_management';
import { filePreview } from '@kit.PreviewKit';

const DEVICE_TYPE = [audio.DeviceType.EARPIECE, audio.DeviceType.SPEAKER]

@ObservedV2
export class MessageChatModel {
  @Trace chatContentList: ChatContentSingleModel[] = [];
  @Trace conversationVM: CMChatConversation = new CMChatConversation();
  @Trace pageTitle: string = '';
  @Trace companyName: string = '';
  @Trace positionInfo?: PositionInfo;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  scroller: ListScroller = new ListScroller();
  private context: UIContext
  private downloader?: RcpDownloader
  @Trace isFriend: boolean = false;
  videoMutyStatus = true //视频播放音量状态（静音/非静音）
  // 语音转文字识别
  currentSingleModel?: ChatContentSingleModel
  private recognizer: SpeechRecognizerU = new SpeechRecognizerU((result: string) => {
    if (this.currentSingleModel !== undefined) {
      this.currentSingleModel.speechToText = result
    }
  })
  audioRendererUtil: AudioRendererUtil = AudioRendererUtil.getInstance()
  soundStatus: boolean = false //语音播放状态（停止/暂停/播放中）
  deviceType = 0 //语音输出设备，默认听筒

  constructor(context: UIContext) {
    this.context = context
  }

  /**
   * 获取历史消息、撤回、删除、标记已读等高级接口
   */
  async getHistoryMessageList() {
    let result =
      await CMChatFactory.instance.getHistoryMessageList(this.conversationVM.userId, this.conversationVM.groupID);
    this.chatContentList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let chatVM = this.parseMessage(element);
      this.chatContentList.push(chatVM);
    }
    if (result.length > 0) {
      this.cleanConversationUnreadMessageCount();
    }
    setTimeout(() => {
      this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    }, 1000)
  }

  /**
   * 添加高级消息的事件监听器
   */
  addAdvancedMsgListener() {
    CMChatFactory.instance.addAdvancedMsgListener({
      onRecvNewMessage: (message: CMChatMessage) => {
        let chatVM = this.parseMessage(message);
        this.chatContentList.push(chatVM);
        this.cleanConversationUnreadMessageCount();
        this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
      }
    })
  }

  /**
   * 移除高级消息监听器
   */
  removeAdvancedMsgListener() {
    CMChatFactory.instance.removeAdvancedMsgListener();
  }

  private parseMessage(element: CMChatMessage) {
    let chatVM = new ChatContentSingleModel();
    chatVM.forwardMessage = element.forwardMessage;
    chatVM.chatId = element.msgID;
    chatVM.conversationType = this.conversationVM.type;
    chatVM.timestamp = element.timestamp;
    chatVM.chatType = element.elemType;
    chatVM.groupId = element.groupID ?? '';
    chatVM.userId = element.userID ?? '';
    chatVM.sender = element.sender;
    chatVM.keyId = element.seq + systemDateTime.getTime(true).toString();
    chatVM.isOwner = element.isSelf;
    chatVM.customChat = element.customElem;
    chatVM.locationName = element.locationName;
    chatVM.locationDesc = element.locationDesc;
    chatVM.locationLongitude = element.locationLongitude;
    chatVM.locationLatitude = element.locationLatitude;
    chatVM.videoChatSrc = element.videoChatSrc;
    chatVM.fileName = element.fileName;
    chatVM.fileChatUrl = element.fileChatUrl;
    chatVM.type = element.type;
    chatVM.duration = element.duration;
    chatVM.snapshotPath = element.snapshotPath;
    if (chatVM.isOwner) {
      chatVM.avatarUrl = this.userInfo.avatarUrl;
      chatVM.nickName = this.userInfo.nickName;
    } else {
      chatVM.nickName = Constants.getMockNickName(element.sender);
      chatVM.avatarUrl = Constants.getMockAvatar(element.sender);
    }
    chatVM.avatarUrl = element.faceURL;
    chatVM.nickName = element.nickName;
    chatVM.friendRemark = element.friendRemark;
    if (element.imageInfo !== undefined) {
      let imgInfoList: ChatContentImage[] = []
      element.imageInfo.forEach((item) => {
        const tmpContentImgInfo = new ChatContentImage()
        tmpContentImgInfo.uuid = item.uuid
        tmpContentImgInfo.type = item.type
        tmpContentImgInfo.size = item.size
        tmpContentImgInfo.width = item.width
        tmpContentImgInfo.height = item.height
        tmpContentImgInfo.url = item.url
        imgInfoList.push(tmpContentImgInfo)
      })
      chatVM.imageInfo = imgInfoList
    }
    if (element.soundInfo !== undefined) {
      const audioInfo: ChatContentAudio = new ChatContentAudio()
      audioInfo.path = element.soundInfo.path
      audioInfo.uuid = element.soundInfo.uuid
      audioInfo.dataSize = element.soundInfo.dataSize
      audioInfo.duration = element.soundInfo.duration
      audioInfo.url = element.soundInfo.url
      chatVM.soundInfo = audioInfo
    }
    return chatVM;
  }

  sendMessageAction(content: ChatInputSendMessageModel) {
    switch (content.messageType) {
      case ChatTypeEnum.CHAT_TYPE_IMAGE: {
        this.createImageMessage(content.pictureUrl);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_File: {
        this.createFileMessage(content.fileUrl, content.fileName);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_SOUND: {
        this.createSoundMessage(content.audioUrl, content.duration / 1000);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_CUSTOM: {
        this.createCustomMessage(content.content);
      }
        break
      case ChatTypeEnum.CHAT_TYPE_VIDEO: {
        this.SimpleMsgListener(content.videoUrl, content.mimeType, content.duration / 1000, content.snapshotPath);
      }
        break
      default:
        break
    }
  }

  /**
   * 创建自定义消息
   */
  async createCustomMessage(context: string) {
    if (context.length === 0) {
      return;
    }
    let data = MessageUtil.strToArrayBuffer(context);
    let result = await CMChatFactory.instance.createCustomMessage(data,
      this.conversationVM.userId, this.conversationVM.groupID);
    let chatVM = this.parseMessage(result);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    this.cleanConversationUnreadMessageCount();
  }

  async createImageMessage(filePath: string) {
    let result = await CMChatFactory.instance.createImageMessage(filePath,
      this.conversationVM.userId, this.conversationVM.groupID);
    let chatVM = this.parseMessage(result);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    this.cleanConversationUnreadMessageCount();
  }

  copyFileToCache(context: Context, entity: ResumeEntity) {
    // 解决中文文件名乱码
    const fileUri = decodeURIComponent(entity.uri)
    let fileName = fileUri.split('/').pop() as string;
    const cacheFile =
      context.cacheDir + '/' + fileName;
    if (fs.accessSync(cacheFile)) {
      this.createFileMessage(cacheFile, entity.name)
      return
    }

    // 开始拷贝
    let srcFile: fs.File | null = null;
    let dstFile: fs.File | null = null;
    try {
      srcFile = fs.openSync(fileUri);
      dstFile = fs.openSync(cacheFile, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      const buffer = new ArrayBuffer(1);
      const readLen = fs.readSync(srcFile.fd, buffer); // 读取首字节
      if (readLen === 0) {
        // 读取长度为0即文件为空
        return;
      }
      fs.copyFileSync(srcFile.fd, dstFile.fd);
    } catch (e) {
    } finally {
      if (srcFile) {
        fs.closeSync(srcFile);
      }
      if (dstFile) {
        fs.closeSync(dstFile);
      }

      this.createFileMessage(cacheFile, entity.name)
    }
  }

  async createFileMessage(filePath: string, fileName: string) {
    let result = await CMChatFactory.instance.createFileMessage(filePath, fileName,
      this.conversationVM.userId, this.conversationVM.groupID);
    let chatVM = this.parseMessage(result);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    this.cleanConversationUnreadMessageCount();
  }

  async createSoundMessage(filePath: string, duration: number) {
    let result = await CMChatFactory.instance.createSoundMessage(filePath, duration,
      this.conversationVM.userId, this.conversationVM.groupID);
    let chatVM = this.parseMessage(result);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    this.cleanConversationUnreadMessageCount();
  }

  /**
   * 视频接口的调用
   */
  async SimpleMsgListener(videoFilePath: string, type: string, duration: number,
    snapshotPath: string) {
    let result = await CMChatFactory.instance.addSimpleMsgListener(videoFilePath, type, duration, snapshotPath,
      this.conversationVM.userId, this.conversationVM.groupID);
    let chatVM = this.parseMessage(result);
    this.chatContentList.push(chatVM);
    this.scroller.scrollToIndex(this.chatContentList.length - 1, true);
    this.cleanConversationUnreadMessageCount();
  }

  /**
   * 清理会话的未读消息计数
   *
   * @param conversationID  会话唯一 ID，C2C 单聊组成方式为: "c2c_userID"；群聊组成方式为: "group_groupID"
   */
  cleanConversationUnreadMessageCount() {
    CMChatFactory.instance.cleanConversationUnreadMessageCount(this.conversationVM.conversationID);
  }


  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async getFriendsInfo() {
    if (this.conversationVM.userId.length === 0) {
      return;
    }

    let result = await CMChatFactory.instance.getFriendsInfo([this.conversationVM.userId]);
    const friendRemark = result[0].friendRemark;
    if (friendRemark !== undefined && friendRemark.length > 0) {
      this.pageTitle = friendRemark;
    } else {
      this.pageTitle = Constants.getMockNickName(this.conversationVM.userId);
      this.companyName = Constants.getMockCompanyName(this.conversationVM.userId) || '';
      this.positionInfo = getPositionByHR(this.conversationVM.userId)
    }
  }

  chatBubbleClick(chatVM: ChatContentSingleModel) {
    if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
      ChatJumpManager.gotoVideoPage(chatVM);
    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
      ChatJumpManager.gotoFullImagePage(chatVM);
    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
      if (this.soundStatus && this.audioRendererUtil.url === chatVM.soundInfo?.url) {
        this.soundStop()
      } else {
        this.soundStart(chatVM)
      }

    } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_File) {
      this.previewFile(chatVM)
    }
  }

  // 预览文件
  private previewFile(chatVM: ChatContentSingleModel) {
    let url: string = chatVM.fileChatUrl
    let fileName: string = url.split('/').pop() as string
    fileName = fileName.split('?')[0]
    let tmpContext: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext
    let filePath = `${tmpContext.cacheDir}/downloads/` + fileName
    if (fs.accessSync(filePath)) {
      this.jumpPreviewPage(chatVM.fileName, filePath, this.checkFileType(fileName))
      return
    }

    this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
    this.downloader.startDownload(url, fileName).then((resp) => {
      this.jumpPreviewPage(chatVM.fileName, filePath, this.checkFileType(fileName))
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: $r('app.string.download_failed') })
    })
  }

  // 跳转预览页面
  private jumpPreviewPage(name: string, path: string, mimeType: string) {
    let uri = fileUri.getUriFromPath(path);
    let fileInfo: filePreview.PreviewInfo = {
      title: name,
      uri: uri,
      mimeType: mimeType,
    };
    const displayInfo: filePreview.DisplayInfo = {
      x: 100,
      y: 100,
      width: 800,
      height: 800,
    };
    filePreview.openPreview(this.context.getHostContext(), fileInfo, displayInfo).then(() => {
    }).catch((err: BusinessError) => {
    });
  }

  private checkFileType(fileName: string): string {
    const lowerCase: string = fileName.toLowerCase()
    const suffix: string = fileName.split('.').pop() as string
    let fileType: string = ''
    switch (suffix) {
      case 'pdf': {
        fileType = 'application/pdf';
        break;
      }
      case 'txt': {
        fileType = 'text/plain';
        break;
      }
      case 'doc': {
        fileType = 'application/msword';
        break;
      }
      case 'docx': {
        fileType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        break;
      }

      case 'xls': {
        fileType = 'application/vnd.ms-excel';
        break;
      }
      case 'xlsx': {
        fileType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        break;
      }
      case 'ppt': {
        fileType = 'application/vnd.ms-powerpoint';
        break;
      }
      case 'pptx': {
        fileType = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        break;
      }
      default: {
        break;
      }
    }

    return fileType
  }

  /*
   * 长按气泡弹窗菜单点击事件
   */
  onPopMenuClick(chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) {
    switch (type) {
      case POP_MENU_TYPE.COPY:
        this.popMenuCopy(chatVM.customChat)
        break;
      case POP_MENU_TYPE.RELAY:
        this.gotoForwardMessage(chatVM);
        break;
      case POP_MENU_TYPE.COLLECT:

        break;
      case POP_MENU_TYPE.DEL:

        break;
      case POP_MENU_TYPE.SPEECH_TO_TEXT:
        this.convertToText(chatVM)
        break;
      case POP_MENU_TYPE.PLAY_SPEAKER:
        const tempType = (DEVICE_TYPE.length - 1) - this.deviceType
        this.setDeviceType(tempType)
        break;
      case POP_MENU_TYPE.PLAY_MUTE:

        break;
      case POP_MENU_TYPE.DOWNLOAD:

        break;

      default:
        break;
    }
  }

  // 语音转换为文字
  convertToText(chatVM: ChatContentSingleModel) {
    this.currentSingleModel = chatVM

    let url: string = chatVM.soundInfo?.url ?? ''
    let fileName: string = url.split('/').pop() as string
    fileName = fileName.split('?')[0]
    let tmpContext: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext
    let filePath = `${tmpContext.cacheDir}/downloads/` + fileName
    if (fs.accessSync(filePath)) {
      this.recognizer.writeAudio(Date.now().toString(), filePath)
      return
    }

    this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
    this.downloader.startDownload(url, fileName).then((resp) => {
      this.recognizer.writeAudio(Date.now().toString(), filePath)
    }).catch(() => {
      this.context.getPromptAction().showToast({ message: $r('app.string.download_failed') })
    })
  }

  /*
   * 气泡菜单-复制
   */
  async popMenuCopy(content: ArrayBuffer) {
    try {
      const tempContent = MessageUtil.arrayBufferToStr(content)
      const systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
      let pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, tempContent);
      await systemPasteboard.setData(pasteData);
      GlobalContext.getUIContext().getPromptAction().showToast({
        message: '复制成功'
      })
    } catch (error) {
    }
  }

  /*
   * 准备音频文件
   */
  async readySoundFile(url: string | undefined) {
    if (!url) {
      return
    }
    if (url !== this.audioRendererUtil.url) {
      this.audioRendererUtil.stop()
    }
    let fileName: string = url.split('/').pop() as string
    fileName = fileName.split('?')[0]
    const tempContext = this.context.getHostContext()
    const dir: string = tempContext?.cacheDir + '/downloads/'
    const fullPath = dir + fileName
    if (fs.accessSync(fullPath)) { //语音文件存在
      this.audioRendererUtil.setFile(fullPath)
    } else { //语音文件不存在
      if (!this.downloader) {
        this.downloader = new RcpDownloader(this.context.getHostContext() as common.UIAbilityContext)
      }
      try {
        await this.downloader?.startDownload(url, fileName)
        this.readySoundFile(url)
      } catch (err) {
        this.context.getPromptAction().showToast({ message: '语音加载失败' })
      }
    }
  }

  /*
   * 设置语音输出设备
   */
  setDeviceType(deviceType: number) {
    this.deviceType = deviceType
    this.audioRendererUtil.setOutDevice(DEVICE_TYPE[this.deviceType])
  }

  /*
   * 语音播放状态回调
   */
  soundStatusCallBack = (status: boolean) => {
    this.soundStatus = status
  }

  /*
   * 语音开始播放
   */
  async soundStart(chatVM: ChatContentSingleModel) {
    await this.readySoundFile(chatVM.soundInfo?.url)
    this.audioRendererUtil.setOutDevice(DEVICE_TYPE[this.deviceType])
    this.audioRendererUtil.start(chatVM.soundInfo?.url || '')
  }


  /*
   * 语音停止播放
   */
  soundStop() {
    this.audioRendererUtil.stop()
  }

  /**
   * 跳转转发消息页面
   */
  gotoForwardMessage(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.FORWARD_CHAT_PAGE,
      builder: wrapBuilder(ForwardChatPageBuilder),
      param: chatVM as TValueType
    })
  }

  /**
   * 获取指定好友资料
   *
   * @param userIDList 好友 userID 列表
   *                 - ID 建议一次最大 100
   * 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
   */
  async checkFriend() {
    if (this.conversationVM.userId.length === 0) {
      return;
    }

    let result = await CMChatFactory.instance.checkFriend([this.conversationVM.userId]);
    this.isFriend = result[0]?.isFriend;
  }
}