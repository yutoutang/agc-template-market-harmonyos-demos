import { AppStorageV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BaseViewModel,
  CommonConstants,
  ContinueModel,
  RouterMap,
  RouterParams,
  RouterToNews,
  RouterUtils,
  TabBarType,
  VideoType,
  ShortcutKey,
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { BaseNewsServiceApi } from 'lib_news_api';
import { AppLinkingRouter, FormCardRouter, ShortcutRouter } from '../common/Types';
import { NEWS_DETAIL_PAGE, PhoneConstants, TABS_INFO } from '../common/Constants';

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace firstBackTime: number = 0;
  @Trace formCardModel: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  @Trace appLinkRouter: AppLinkingRouter = AppStorageV2.connect(AppLinkingRouter, () => new AppLinkingRouter())!;
  @Trace shortcutRouter: ShortcutRouter = AppStorageV2.connect(ShortcutRouter, () => new ShortcutRouter())!;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  @Trace assignedVideoTabIndex: number = VideoType.CHOICE;
  private changeTabIndex: (index: number) => void = () => {
  };

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    if (this.tabModel.isTabVertical) {
      return;
    }
    let isShowCustomTabBar = monitor.value()?.now as boolean;
    if (isShowCustomTabBar) {
      this.translateY = '';
    } else {
      this.translateY = '100%';
    }
  }

  @Monitor('tabModel.isTabVertical')
  onShowChangeTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateY = '';
      this.tabModel.showTabBar = true;
    }
  }

  @Monitor('formCardModel.id')
  onFormCardClick() {
    this.checkJumpNewsDetail();
  }

  @Monitor('continueModel.id')
  onContinueSceneChange() {
    this.checkContinueScene();
  }

  @Monitor('appLinkRouter.id')
  onAppLinkingClick() {
    this.checkAppLinkingScene();
  }

  @Monitor('shortcutRouter.pageName')
  onShortcutClick() {
    this.checkShortcutScene();
  }

  setTabChangeFunc(func: (index: number) => void) {
    this.changeTabIndex = func;
  }

  refreshUserInfo() {
    new AccountApi().queryUserInfo();
  }

  registerSubEmitter() {
    emitter.on('on_sub_window', (eventData: emitter.GenericEventData<string>): void => {
      let params: Record<string, string | boolean | undefined> = {
        'avId': eventData?.data,
        'subWindow': true,
        'isCreateSubWindow': true,
      }
      RouterUtils.pushPathByName(RouterMap.AUDIO_DETAILS, params)
    })
  }

  backToHomePage() {
    const currentPage = RouterUtils.getStack().getAllPathName().pop();
    if (currentPage !== RouterMap.INDEX_PAGE) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
    }
  }

  checkJumpNewsDetail() {
    if (this.formCardModel.id && this.formCardModel.newsId && this.formCardModel.pageUrl === NEWS_DETAIL_PAGE) {
      this.backToHomePage();
      let routerParams: RouterParams<null> = {
        'type': this.formCardModel.newsType,
        'newsId': this.formCardModel.newsId,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.formCardModel.id = 0;
    }
  }

  async checkContinueScene() {
    if (this.continueModel.id && this.continueModel.newsId) {
      const news = await BaseNewsServiceApi.queryNews(this.continueModel.newsId);
      if (!news) {
        this.continueModel.id = 0;
        this.contextModel.showToast({ message: '新闻内容不存在，无法流转' });
        return;
      }
      this.backToHomePage();
      let routerParams: RouterParams<null> = {
        'type': this.continueModel.newsType,
        'newsId': this.continueModel.newsId,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.continueModel.id = 0;
    }
  }

  checkAppLinkingScene() {
    if (this.appLinkRouter.id && this.appLinkRouter.newsId) {
      this.backToHomePage();
      let routerParams: RouterParams<null> = {
        newsId: this.appLinkRouter.newsId,
        type: this.appLinkRouter.newsType,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.appLinkRouter.id = 0;
    }
  }

  checkShortcutScene() {
    if (this.shortcutRouter.pageName) {
      this.backToHomePage();
      switch (this.shortcutRouter.pageName) {
        case ShortcutKey.TV:
          // 针对视频页面未初始化的场景
          this.assignedVideoTabIndex = VideoType.TELEVISION;
          // 切换到视频Tab
          this.changeTabIndex(TabBarType.VIDEO);
          // 处理视频页面已经初始化的场景
          emitter.emit('changeVideoTab', { data: { pageName: ShortcutKey.TV } });
          break;
        case ShortcutKey.AUDIO:
          this.assignedVideoTabIndex = VideoType.BROADCAST;
          this.changeTabIndex(TabBarType.VIDEO);
          emitter.emit('changeVideoTab', { data: { pageName: ShortcutKey.AUDIO } });
          break;
        case ShortcutKey.DIGITAL_NEWS:
          RouterUtils.pushPathByName(RouterMap.DIGITAL_NEWSPAPER, null, undefined, false);
          break;
      }
      this.shortcutRouter.pageName = '';
    }
  }

  onBackPressed() {
    // 视频tab，返回前要重置showTabBar状态
    if (this.tabModel.selectedIndex === TabBarType.VIDEO) {
      if (this.videoExtraInfoModel.isDisplayChange) {
        this.videoExtraInfoModel.isDisplayChange = false;
        return true;
      }
      this.tabModel.showTabBar = true;
    }
    let nowTime = Date.now();
    if (nowTime - this.firstBackTime < 1500) {
      return false;
    } else {
      this.firstBackTime = nowTime;
      this.contextModel.showToast({ message: '再按一次退出' });
      return true;
    }
  }

  @Computed
  get barPosition() {
    if (this.tabModel.isTabVertical) {
      return BarPosition.Start;
    }
    return BarPosition.End;
  }

  @Computed
  get tabWidth(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_WIDTH;
    }
    return CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabHeight(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT * TABS_INFO.length;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }

  @Computed
  get showDivider(): DividerStyle | null {
    if (!this.tabModel.isTabVertical) {
      return null;
    }
    if ([TabBarType.HOME, TabBarType.COMMUNITY].includes(this.tabModel.selectedIndex)) {
      return null;
    }
    if (this.hideTabScene) {
      return null;
    }
    return {
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: 0,
      endMargin: 0,
    } as DividerStyle
  }

  // 存在隐藏Tab的场景
  @Computed
  get hideTabScene() {
    return this.tabModel.selectedIndex === TabBarType.VIDEO &&
    [VideoType.FOLLOW, VideoType.CHOICE].includes(this.tabModel.videoCurrentTabIndex);
  }

  @Computed
  get barBgColor() {
    if ([TabBarType.HOME, TabBarType.COMMUNITY].includes(this.tabModel.selectedIndex) ||
    [VideoType.TELEVISION, VideoType.BROADCAST].includes(this.tabModel.videoCurrentTabIndex)) {
      return $r('sys.color.background_secondary');
    }
    if (this.hideTabScene) {
      return Color.Black;
    }
    return Color.Transparent;
  }

  @Computed
  get pageBgColor(): ResourceColor {
    if (this.hideTabScene) {
      return Color.Black;
    }
    return $r('sys.color.background_secondary');
  }

  @Computed
  get paddingBottom() {
    if (this.tabModel.isTabVertical) {
      return 0;
    }
    return this.windowModel.windowBottomPadding;
  }

  @Computed
  get tabBarHeight() {
    if (this.tabModel.isTabVertical || this.tabModel.showTabBar) {
      return this.tabHeight;
    }
    return 0
  }
}