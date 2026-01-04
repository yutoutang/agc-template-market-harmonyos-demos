import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, ThemeControl, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BundleUtils,
  Logger,
  NetworkUtil,
  PushActionParams,
  PushUtils,
  ResUtil,
  RouterToNews,
  SystemBarOperation,
  WindowModel
} from 'lib_common';
import { WXApi, WXEventHandler } from 'lib_account';
import { gAppTheme } from '../common/AppTheme';
import { UIBase } from 'ui_base';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    ResUtil.init(this.context)
    this.handlePushCall(want);
    this.handleWeChatCallIfNeed(want);
    // 网络解析
    this.initNetwork()
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    this.offAvoidAreaChange();
    // 取消网络监听
    this.unRegisterNetwork()
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    this.setWinConfig(windowStage);
    this.setAppTheme();
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      this.setColorMode(this.context);
      BundleUtils.getBundleInfo()
    });
    UIBase.init(windowStage);
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onNewWant(want: Want): void {
    this.handlePushWant(want);
    this.handleWeChatCallIfNeed(want);
  }

  onForeground(): void {
    try {
      emitter.emit('AbilityOnForegroundEvent')
      Logger.info(TAG, '%{public}s', 'Ability onForeground');
    } catch (error) {
      Logger.info(TAG, '%{public}s', 'Ability onForeground error');
    }
  }

  onBackground(): void {
    try {
      emitter.emit('AbilityOnBackgroundEvent')
      Logger.info(TAG, '%{public}s', 'Ability onBackground');
    } catch (error) {
      Logger.info(TAG, '%{public}s', 'Ability onBackground error');
    }
  }

  private setAppTheme() {
    ThemeControl.setDefaultTheme(gAppTheme);
  }

  private async setWinConfig(windowStage: window.WindowStage) {
    AppStorage.setOrCreate('windowStage', windowStage);
    let windowClass: window.Window = windowStage.getMainWindowSync();
    await windowClass.setWindowLayoutFullScreen(true);
    this.setAvoidArea(windowClass);
    this.onAvoidAreaChange(windowStage);
    this.setWindowSize(windowStage)
  }

  private setAvoidArea(windowClass: window.Window) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let type = window.AvoidAreaType.TYPE_SYSTEM;
    let avoidArea = windowClass.getWindowAvoidArea(type);
    windowModel.windowTopPadding = px2vp(avoidArea.topRect.height);
    type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
    avoidArea = windowClass.getWindowAvoidArea(type);
    windowModel.windowBottomPadding = px2vp(avoidArea.bottomRect.height);
  }

  private onAvoidAreaChange(windowStage: window.WindowStage) {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.on('avoidAreaChange', () => {
        this.setAvoidArea(windowClass);
      });
    } catch (e) {
      Logger.error(TAG, 'Failed to onAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  private offAvoidAreaChange() {
    try {
      let windowStage = AppStorage.get('windowStage') as window.WindowStage;
      if (windowStage) {
        windowStage.getMainWindowSync().off('avoidAreaChange');
      }
    } catch (e) {
      Logger.error(TAG, 'Failed to offAvoidAreaChange. Cause: ' + JSON.stringify(e));
    }
  }

  private setWindowSize(windowStage: window.WindowStage) {
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    let windowClass: window.Window = windowStage.getMainWindowSync();
    windowModel.windowWidth = windowClass.getWindowProperties().windowRect.width;
    windowModel.windowHeight = windowClass.getWindowProperties().windowRect.height;
  }

  private handlePushWant(want: Want) {
    /*
    * 获取push卡片点击进入携带参数
    * */
    const articleInfo = want.parameters?.articleInfo as PushActionParams;
    if (articleInfo) {
      let articleId = articleInfo?.articleId
      RouterToNews.routerToNewsById(articleId)
    }
  }

  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler);
  }

  private setColorMode(context: common.UIAbilityContext) {
    const mode =
      ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    context.getApplicationContext().setColorMode(mode);
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: '#ff090909',
    })
  }

  private async handlePushCall(want: Want) {
    let pushToken: string = await PushUtils.getTokenSyn()
    AppStorage.setOrCreate('pushToken', pushToken)
    const articleInfo = want.parameters?.articleInfo;
    AppStorage.setOrCreate('pushCardEntry', articleInfo)
  }

  private initNetwork() {
    let networkInstance = NetworkUtil.getInstance();
    networkInstance.init()
  }

  private unRegisterNetwork() {
    let networkInstance = NetworkUtil.getInstance();
    networkInstance.unregister()
  }
}