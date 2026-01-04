import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { controllerMap, createNWeb, IResourceConfig, preLoadUrl, WebProperties } from '@hw-agconnect/fast-web';
import { BaseViewModel, RouterMap, RouterUtils } from 'lib_common';
import { MessageServiceApi } from 'lib_video_api';
import { BriefIMModel } from '../common/ObservedModel';
import { WebIdMap } from '../constants/Constants';

@ObservedV2
export class MsgIMViewModel extends BaseViewModel {
  @Trace chatList: BriefIMModel[] = [];

  constructor() {
    super();
    this.queryList();
  }

  queryList() {
    MessageServiceApi.queryAllIMList().then((resp) => {
      this.chatList = resp.map(v => new BriefIMModel(v));
    })
  }

  setAllRead() {
    MessageServiceApi.setIMAllRead().then(() => {
      this.queryList();
    })
  }

  createWeb(uiContent: UIContext) {
    if (controllerMap.get(WebIdMap.ChatWebId)) {
      return;
    }
    const webProperties = new WebProperties();
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
      }
    ];
    createNWeb(WebIdMap.ChatWebId, uiContent, webProperties, [], resourceConfigs);
  }

  jumpChatPage(v: BriefIMModel) {
    preLoadUrl(WebIdMap.ChatWebId, 'about:blank');
    RouterUtils.pushPathByName(RouterMap.MINE_MSG_IM_CHAT, v.chatAuthor, () => {
      this.queryList();
    });
  }

  @Computed
  get allowClean() {
    return this.chatList.some(v => v.allUnreadCount !== 0);
  }
}