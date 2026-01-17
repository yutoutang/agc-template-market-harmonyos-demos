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
} from 'lib_common';
import { AccountApi } from 'lib_account';
import { BaseNewsServiceApi } from 'lib_news_api';
import { FormCardRouter } from '../common/Types';
import { NEWS_DETAIL_PAGE, PhoneConstants, TabBarType, TABS_INFO } from '../common/Constants';

@ObservedV2
export class IndexPageViewModel extends BaseViewModel {
  @Trace translateY: string | number = '';
  @Trace firstBackTime: number = 0;
  @Trace formCardModel: FormCardRouter = AppStorageV2.connect(FormCardRouter, () => new FormCardRouter())!;
  @Trace continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;

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

  checkJumpNewsDetail() {
    if (this.formCardModel.id && this.formCardModel.newsId && this.formCardModel.pageUrl === NEWS_DETAIL_PAGE) {
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
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
      RouterUtils.popToName(RouterMap.INDEX_PAGE, undefined, false);
      let routerParams: RouterParams<null> = {
        'type': this.continueModel.newsType,
        'newsId': this.continueModel.newsId,
      };
      RouterToNews.pushToNewsDetails(routerParams);
      this.continueModel.id = 0;
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
      (this.tabModel.videoCurrentTabIndex === 0 || this.tabModel.videoCurrentTabIndex === 1);
  }

  @Computed
  get barBgColor() {
    if ([TabBarType.HOME, TabBarType.COMMUNITY].includes(this.tabModel.selectedIndex) ||
    [4, 5].includes(this.tabModel.videoCurrentTabIndex)) {
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