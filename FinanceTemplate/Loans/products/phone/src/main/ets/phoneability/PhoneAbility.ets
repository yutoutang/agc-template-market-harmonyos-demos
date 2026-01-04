import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, PersistenceV2, ThemeControl, window } from '@kit.ArkUI';
import {
  BundleUtils,
  Logger,
  SettingModel,
  SystemBarOperation,
  WindowModel,
} from 'lib_common';
import { WXApi, WXEventHandler } from 'lib_account';
import { gAppTheme } from '../common/AppTheme';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  onCreate(want: Want) {
    Logger.info(TAG, 'Ability onCreate');
    this.handleWeChatCallIfNeed(want);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    this.offAvoidAreaChange();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    ThemeControl.setDefaultTheme(gAppTheme);
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
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onNewWant(want: Want): void {
    this.handleWeChatCallIfNeed(want);
  }

  onForeground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onBackground');
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



  private handleWeChatCallIfNeed(want: Want) {
    WXApi.handleWant(want, WXEventHandler);
  }

  private setColorMode(context: common.UIAbilityContext) {
    Logger.info('setColorMode PersistenceV2 keys: ' + JSON.stringify(PersistenceV2.keys()));
    const settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;
    const mode = settingInfo.darkSwitch ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK :
    ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    context.getApplicationContext().setColorMode(mode);
    SystemBarOperation.setWindowSystemBarProp({
      statusBarContentColor: settingInfo.darkSwitch ? '#ffffff' : '#ff090909',
    })
  }
}