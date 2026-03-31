import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BookApi, ColorModeClass, Constants, GlobalContext, TCRouter, UserInfoUtil, WindowUtils } from 'common';
import { BusinessError } from '@kit.BasicServicesKit';
import { pushService } from '@kit.PushKit';
import { notificationManager } from '@kit.NotificationKit';
import { Configuration } from '@ohos.app.ability.Configuration';
import { AppStorageV2 } from '@kit.ArkUI';

interface PushData {
  pushContent: string
  time: string
  read: false
}

const DOMAIN_NUMBER: number = 0xFF00;

export default class EntryAbility extends UIAbility {
  private isDark: boolean = false;

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {

    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    GlobalContext.initContext(this.context);
    TCRouter.init();
    BookApi.init('data.json');
    UserInfoUtil.init();
    let pushToken: string
    // 获取Push Token
    try {
      const pushToken = await pushService.getToken();
      AppStorage.setOrCreate('PushToken', pushToken)
      hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }

    if (want.action === 'com.test.action') {

      AppStorage.setOrCreate('takeMessage', 1)

      const pushData: PushData = {
        pushContent: want.parameters?.pushContent as string,
        time: want.parameters?.time as string,
        read: false
      }
      AppStorage.setOrCreate('pushData', pushData)
    }

    let currentColorMode = this.context.config.colorMode;
    this.isDark = currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    AppStorage.setOrCreate<boolean>('currentColorMode', this.isDark)
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {

    if (want.action === 'com.test.action') {
      AppStorage.setOrCreate('takeMessage', 1)
      AppStorage.setOrCreate('coldBoot', 1)
      const pushData: PushData = {
        pushContent: want.parameters?.pushContent as string,
        time: want.parameters?.time as string,
        read: false
      }
      AppStorage.setOrCreate('pushData', pushData)
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 设置WindowStage的事件订阅（获焦/失焦、切到前台/切到后台、前台可交互/前台不可交互）
    try {
      windowStage.on('windowStageEvent', (data) => {
        let stageEventType: window.WindowStageEventType = data;
        switch (stageEventType) {
          case window.WindowStageEventType.SHOWN: // 切到前台
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage foreground.`);
            break;
          case window.WindowStageEventType.ACTIVE: // 获焦状态
            if (AppStorage.get('takeMessage') === 1 &&
              AppStorage.get('coldBoot') === 1 &&
              AppStorage.get('inMessagePage') !== 1) {
              TCRouter.push(Constants.MESSAGE_PAGE_ROUTE)
              AppStorage.setOrCreate('takeMessage', 0)
              AppStorage.setOrCreate('coldBoot', 0)
              AppStorage.setOrCreate('inMessagePage', 1)
            }
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage active.`);
            break;
          case window.WindowStageEventType.INACTIVE: // 失焦状态
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage inactive.`);
            break;
          case window.WindowStageEventType.HIDDEN: // 切到后台
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage background.`);
            break;
          case window.WindowStageEventType.RESUMED: // 前台可交互状态
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage resumed.`);
            break;
          case window.WindowStageEventType.PAUSED: // 前台不可交互状态
            hilog.info(DOMAIN_NUMBER, 'testTag', `windowStage paused.`);
            break;
          default:
            break;
        }

      });
    } catch (exception) {
      hilog.error(DOMAIN_NUMBER, 'testTag',
        `Failed to enable the listener for window stage event changes. Cause: ${JSON.stringify(exception)}`);
    }
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      WindowUtils.init(windowStage.getMainWindowSync());
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      notificationManager.requestEnableNotification(this.context).then(() => {
        hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',
          `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    let currentColorMode = newConfig.colorMode;
    this.isDark = currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    let sysColor = AppStorageV2.connect(ColorModeClass, () => new ColorModeClass())!;
    sysColor.currentMode = newConfig.colorMode;
    AppStorage.setOrCreate<boolean>('currentColorMode', this.isDark);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
