import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BundleUtils, Logger } from 'lib_common';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { WantUtils } from '../common/WantUtils';
import { CloudPrefetchUtils } from '../common/CloudPrefetchUtils';
import { NetworkUtils } from '../common/NetworkUtils';
import { ContinueUtils } from '../common/ContinueUtils';
import { WindowUtils } from '../common/WindowUtils';
import { AppUtils } from '../common/AppUtils';

const TAG = '[PhoneAbility]';

export default class PhoneAbility extends UIAbility {
  // 标记是否需要执行windowStage.loadContent
  private needLoadContent: boolean = false;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    this.setNeedLoadContent(true);
    ContinueUtils.disableContinue(this.context);
    WantUtils.handlePushCall(want);
    WantUtils.handleWeChatCallIfNeed(want);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
    CloudPrefetchUtils.functionPreload();
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    this.setNeedLoadContent(false);
    WantUtils.handlePushWant(want);
    WantUtils.handleWeChatCallIfNeed(want);
    WantUtils.handleFormCardCall(want);
    WantUtils.handleRestoreCall(want, launchParam);
  }

  onContinue(wantParam: Record<string, Object>) {
    Logger.info(TAG, 'Ability onContinue');
    return ContinueUtils.handleContinue(wantParam);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageCreate');
    this.handleWindowStageCreateOrRestore(windowStage);
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    Logger.info(TAG, 'Ability onWindowStageRestore');
    if (this.needLoadContent) {
      this.handleWindowStageCreateOrRestore(windowStage);
    }
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    AppUtils.listenConfigurationUpdate(newConfig);
  }

  onWindowStageDestroy(): void {
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    WindowUtils.offAvoidAreaChange();
    NetworkUtils.unRegisterNetwork();
  }

  handleWindowStageCreateOrRestore(windowStage: window.WindowStage) {
    WindowUtils.setWinConfig(windowStage);
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err));
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      AppUtils.setAppTheme();
      AppUtils.setColorMode();
      BundleUtils.getBundleInfo();
      LoneTakeAnimationsTransition.init(windowStage);
      // 判断是否是模拟器
      let productMode = deviceInfo.productModel;
      if (productMode !== 'emulator') {
        NetworkUtils.initNetwork();
      }
    });
  }

  setNeedLoadContent(value: boolean) {
    this.needLoadContent = value;
  }
};
