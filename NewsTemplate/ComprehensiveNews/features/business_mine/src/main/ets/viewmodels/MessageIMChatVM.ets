import { webview } from '@kit.ArkWeb';
import { controllerMap, updateWeb, webOptionMap } from '@hw-agconnect/fast-web';
import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview';
import { BaseViewModel, FileUtils, Logger, RouterMap, RouterUtils } from 'lib_common';
import { AuthorModel, ChatInfoDetailResponse, MessageServiceApi, SendMessageRequest } from 'lib_news_api';
import { ChatInfoDetailModel } from '../common/ObservedModel';
import { WebIdMap } from '../constants/Constants';

export interface ChatModel {
  myAvatar: string
  otherAvatar: string
  messages: ChatInfoDetailResponse[]
}

const TAG = 'MsgIMChatViewModel';

@ObservedV2
export class MsgIMChatViewModel extends BaseViewModel {
  @Trace public controller: webview.WebviewController | undefined = controllerMap.get(WebIdMap.ChatWebId);
  @Trace public webController: webview.WebviewController = new webview.WebviewController();
  @Trace public chatAuthor: AuthorModel | null = null;
  @Trace public chatList: ChatInfoDetailModel[] = [];
  // 自行选择是否使用离线Web
  @Trace public useOfflineWeb: boolean = true;
  public readonly JAVASCRIPT_PROXY_NAME: string = 'msgIMChatViewModel';
  public readonly METHOD_LIST: string[] = [
    'queryList', 'sendMessage', 'enterPreview', 'jumpTAProfile', 'jumpMyProfile',
  ];

  constructor() {
    super();
    this.chatAuthor = RouterUtils.getParamByName(RouterMap.MINE_MSG_IM_CHAT) as AuthorModel;
    MessageServiceApi.setSingleChatRead(this.chatAuthor.authorId);
  }

  queryList(): Promise<ChatModel> {
    return MessageServiceApi.queryChatRecordByAuthorId(this.chatAuthorId).then((resp) => {
      const dataInject: ChatModel = {
        myAvatar: this.getMyAvatar,
        otherAvatar: this.chatAuthor?.authorIcon || '',
        messages: resp,
      };
      this.chatList = resp.map(v => new ChatInfoDetailModel(v));
      return dataInject;
    });
  }

  sendMessage(content: string, type: string, createTime: number) {
    MessageServiceApi.sendMessage(this.chatAuthorId, {
      type,
      content,
      createTime,
    } as SendMessageRequest).then(() => {
      this.queryList()
    })
  }

  jumpTAProfile() {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.chatAuthor?.authorId);
  }

  jumpMyProfile() {
    RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.userInfoModel.authorId);
  }

  enterPreview(content: string = '', createTime: number = 0) {
    let index = this.imageList.findIndex(v => v.content === content && v.createTime === createTime);
    if (index === -1) {
      index = 0;
    }
    ImagePreview.show(this.imageList.map(v => v.content), {
      startIndex: index,
      showIndex: false,
      loop: false,
      isBasicMode: true,
      indexPosition: PreviewVerticalAlign.Top,
    })
  }

  setWebDebuggingAccess(enableDebug: boolean) {
    // 配置Web是否开启调试模式
    webview.WebviewController.setWebDebuggingAccess(enableDebug);
  }

  setWebProperty() {
    const webProperty = webOptionMap.get(WebIdMap.ChatWebId)?.config.webProperties;
    if (webProperty) {
      webProperty.defaultFontSize = 14 * this.settingInfo.fontSizeRatio;
      updateWeb(WebIdMap.ChatWebId);
    }
  }

  registerJavaScriptProxy(object: MsgIMChatViewModel) {
    try {
      this.controller?.registerJavaScriptProxy(object, this.JAVASCRIPT_PROXY_NAME, this.METHOD_LIST);
    } catch (e) {
      Logger.error(TAG, 'registerJavaScriptProxy fail, error: ' + JSON.stringify(e));
    }
  }

  deleteJavaScriptRegister() {
    try {
      this.controller?.deleteJavaScriptRegister(this.JAVASCRIPT_PROXY_NAME);
    } catch (e) {
      Logger.error(TAG, 'deleteJavaScriptRegister fail, error: ' + JSON.stringify(e));
    }
  }

  @Computed
  get getMyAvatar() {
    if (this.userInfoModel.authorIcon.startsWith('file://')) {
      return FileUtils.sandboxToBase64(this.userInfoModel.authorIcon);
    }
    return this.userInfoModel.authorIcon;
  }

  @Computed
  get haveOfflineWeb() {
    return this.useOfflineWeb && Boolean(this.controller);
  }

  @Computed
  get chatAuthorId() {
    return this.chatAuthor?.authorId || '';
  }

  @Computed
  get imageList() {
    return this.chatList.filter(v => v.type === 'image');
  }
}