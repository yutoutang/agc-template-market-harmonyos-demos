import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { controllerMap, createNWeb, IResourceConfig, preLoadUrl, WebProperties } from '@hw-agconnect/fast-web';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { MessageServiceApi } from 'lib_news_api';
import { BriefIMModel } from '../common/ObservedModel';
import { WebIdMap } from '../constants/Constants';

@ObservedV2
export class MsgIMViewModel extends BaseViewModel {
  @Trace chatList: BriefIMModel[] = [];

  constructor() {
    super();
    this.queryList();
  }

  // 查询聊天列表
  queryList() {
    MessageServiceApi.queryAllIMList().then((resp) => {
      this.chatList = resp.map(v => new BriefIMModel(v));
    })
  }

  // 一键已读
  setAllRead() {
    MessageServiceApi.setIMAllRead().then(() => {
      this.queryList();
    })
  }

  // 创建离线Web
  createWeb(uiContent: UIContext) {
    if (controllerMap.get(WebIdMap.ChatWebId)) {
      return;
    }
    // 设置web属性
    const webProperties = new WebProperties();
    webProperties.geolocationAccess = false;
    webProperties.fileAccess = false;
    webProperties.darkMode = WebDarkMode.Auto;
    webProperties.forceDarkAccess = true;
    // 免拦截注入的离线资源如图片、样式表和脚本资源
    const resourceConfigs: IResourceConfig[] = [
      {
        localPath: 'news_tra_2.jpg',
        urlList: [
          'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg',
        ],
        type: webview.OfflineResourceType.IMAGE,
      },
      {
        localPath: 'news_tra_3.jpg',
        urlList: [
          'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg',
        ],
        type: webview.OfflineResourceType.IMAGE,
      },
    ];
    createNWeb(WebIdMap.ChatWebId, uiContent, webProperties, [], resourceConfigs);
  }

  // 复用web实例，需要在合适时机重置为空白页，避免闪现上一个页面的问题
  loadBlank() {
    preLoadUrl(WebIdMap.ChatWebId, 'about:blank');
  }

  // 跳转聊天详情页
  jumpChatPage(v: BriefIMModel) {
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_IM_CHAT, v.chatAuthor, () => {
      this.queryList();
    });
  }

  @Computed
  get allowClean() {
    return this.chatList.some(v => v.allUnreadCount !== 0);
  }
}