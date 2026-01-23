import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { WantUtils } from '../push/WantUtils';
import { notificationManager } from '@kit.NotificationKit';
import { CloudPrefetchUtils, WindowUtil } from '@ohos_agcit/children_education_utils';
import { webview } from '@kit.ArkWeb';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.handlePushCall(want);
    CloudPrefetchUtils.functionPreload();
    webview.WebviewController.initializeWebEngine();

    try {
      let url = this.context.resourceManager.getStringByNameSync('privacyAgreementPath')
      webview.WebviewController.prepareForPageLoad(url, true, 2);
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', '%{public}s', 'prepareForPageLoad fail');
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    WantUtils.handlePushWant(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 一多适配
    WindowUtil.registerBreakPoint(windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      notificationManager.requestEnableNotification(this.context).then(() => {
        hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',
          `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
};
