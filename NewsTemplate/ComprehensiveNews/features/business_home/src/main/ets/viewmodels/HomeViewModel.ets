import { AppStorageV2, curves, PersistenceV2 } from '@kit.ArkUI';
import {
  BaseViewModel,
  BreakpointModel,
  BreakpointNameEnum,
  PushActionParams,
  PushUtils,
  RouterMap,
  RouterParams,
  RouterToNews,
  RouterUtils,
  SearchHistory,
  SettingModel,
} from 'lib_common';
import { BaseNewsServiceApi, RequestListData } from 'lib_news_api';
import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { LongTakeAnimationProperties, LongTakeTransitionParam } from 'module_transition';

@ObservedV2
export class HomeViewModel extends BaseViewModel {
  searchHistory: SearchHistory = PersistenceV2.connect(SearchHistory, () => new SearchHistory())!;
  @Trace searchResultList: RequestListData[] = []
  @Trace settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM
  }

  getSearchResultList(searchValue: string) {
    this.searchResultList = BaseNewsServiceApi.querySearchResultList(searchValue)
  }

  searchChange(searchValue: string) {
    this.getSearchResultList(searchValue)
    if (this.searchHistory.historyList.includes(searchValue) || searchValue.trim() === '') {
      return
    }
    this.searchHistory.historyList.push(searchValue)
  }

  clearHistory() {
    this.searchHistory.historyList = []
  }

  // mock 开启随机推送
  sendPushMessage() {
    let pushArticle = BaseNewsServiceApi.queryAllNewsList()
    PushUtils.randomPushMessage(pushArticle)
  }

  sendPushNotice(context: common.UIAbilityContext) {
    if (!this.settingInfo.pushSwitch) {
      notificationManager.requestEnableNotification(context).then((err) => {
        this.settingInfo.pushSwitch = true;
        this.sendPushMessage();
      }).catch(() => {
        this.settingInfo.pushSwitch = false;
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
  public goSearchWithLongTake(uiContext: UIContext) {
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
  
  @Computed get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 48;
  }

  /*
   * sm屏幕下，返回不需要一镜到底的效果
   * */
  public onLongTakeSearchBack(uiContext: UIContext) {
    if(this.isSmDevice) {
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