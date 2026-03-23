import { common } from '@kit.AbilityKit';
import { AppStorageV2, curves, PersistenceV2 } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  BreakpointModel,
  BreakpointNameEnum,
  FileUtils,
  Logger,
  OptimizeUtils,
  PushActionParams,
  PushUtils,
  RouterMap,
  RouterParams,
  RouterToNews,
  RouterUtils,
  SearchHistory,
  SettingModel,
} from 'lib_common';
import { BaseNewsServiceApi, HomeServiceApi, RequestListData } from 'lib_news_api';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

const TAG = '[HomeViewModel]';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchAbstractResult: string = '';
  @Trace heightControl: number | string = 150;
  @Trace maxHeight: number = 150;
  @Trace historyHeight: number = 0;
  @Trace isExpand: boolean = false;
  @Trace searchResultList: RequestListData[] = []
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  public eNewsMap: Map<string, PixelMap> = new Map();

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  async getSearchResultList(searchValue: string) {
    if (searchValue.trim() === '') {
      this.searchResultList = []
      return
    }
    let abstractSearchResult = await BaseNewsServiceApi.querySearchResultList(searchValue)
    this.searchResultList = abstractSearchResult.list;
    this.searchAbstractResult = abstractSearchResult.abstract
  }

  // 预加载图片
  async preloadENewsImages() {
    // 调用接口查询图片数据
    const sourceId = '1';
    const publishDate = new Date().getTime();
    const list = await HomeServiceApi.queryDigitalNewsList(sourceId, publishDate);
    list.forEach((v) => {
      // 下载解码成PixelMap，并将其缓存
      FileUtils.downloadImage(v.newsImg)
        .then((buffer) => {
          const pixelMap = image.createImageSource(buffer).createPixelMapSync();
          this.eNewsMap.set(v.newsImg, pixelMap);
        })
    })
  }

  searchChange(searchValue: string) {
    OptimizeUtils.debounce(() => {
      this.getSearchResultList(searchValue)
      if (this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') {
        return
      }
      this.searchHistory.historyList.unshift(searchValue)
    })
  }

  expandOperation() {
    if (this.heightControl === this.maxHeight) {
      this.expandAnimateTo(() => {
        this.heightControl = '100%';
        this.isExpand = true;
      })
    } else {
      this.expandAnimateTo(() => {
        this.heightControl = this.maxHeight;
        this.isExpand = false;
      })
    }
  }

  private expandAnimateTo(cb: () => void) {
    this.contextModel.globalUIContext.animateTo({
      duration: 300,
      curve: Curve.EaseOut,
    }, () => {
      cb()
    })
  }

  clearHistory() {
    this.searchHistory.historyList = []
  }

  // mock 开启随机推送
  async sendPushMessage() {
    let pushArticle = await BaseNewsServiceApi.queryAllNewsList()
    PushUtils.randomPushMessage(pushArticle)
  }

  sendPushNotice(context: common.UIAbilityContext) {
    if (!this.settingInfo.pushSwitch) {
      notificationManager.requestEnableNotification(context).then(() => {
        this.settingInfo.pushSwitch = true;
        this.sendPushMessage();
        Logger.info(TAG, 'requestEnableNotification success');
      }).catch((error: BusinessError) => {
        this.settingInfo.pushSwitch = false;
        Logger.error(TAG, 'requestEnableNotification fail, error: ' + JSON.stringify(error));
      });
    } else {
      this.sendPushMessage();
    }
    /*
     * 判断是否是从push 卡片进入
     * */
    if (AppStorage.get('pushCardEntry')) {
      let newsData = AppStorage.get('pushCardEntry') as PushActionParams
      let routerParams: RouterParams<null> = {
        'type': newsData.type,
        'newsId': newsData.articleId,
        'authorId': newsData.authorId,
      }
      RouterToNews.pushToNewsDetails(routerParams)
      AppStorage.setOrCreate('isPushCardEntry', '')
    }
  }

  /*
   * 跳转到搜索
   * */
  public goSearchWithLongTake() {
    RouterUtils.pushPathByName(RouterMap.NEWS_SEARCH)
  }

  /*
   * 初始化一镜到底参数
   * */
  public registerCustomTransition(navDestContext: NavDestinationContext, longTakeSession: LongTakeAnimationProperties) {
    let param = navDestContext.pathInfo?.param as Record<string, Object>;
    let longTakeTransitionParam = param.longTakeTransitionParam as LongTakeTransitionParam;
    if (longTakeTransitionParam) {
      longTakeSession.init(navDestContext, longTakeTransitionParam, {
        pop: () => {
          navDestContext.pathStack.pop()
        },
      });
    }
  }

  @Computed
  get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }

  /*
   * sm屏幕下，返回不需要一镜到底的效果
   * */
  public onLongTakeSearchBack(uiContext: UIContext) {
    if (this.isSmDevice) {
      RouterUtils.pop();
      return
    }
    uiContext.animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38),
    }, () => {
      RouterUtils.pop(undefined, false);
    })
  }
}