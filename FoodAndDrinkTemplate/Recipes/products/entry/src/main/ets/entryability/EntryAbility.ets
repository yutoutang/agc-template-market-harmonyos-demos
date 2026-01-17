import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { FormCardJump } from '../types/Types';
import { WXLoginService } from 'aggregated_login';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  // 实例化登录服务
  private loginServiceImpl: WXLoginService =
    WXLoginService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('wxc92d9d6570127a32')
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    UtilLog.setGlobalConfig({
      tag: 'ComprehensiveMall',
      domain: 0xff00,
      open: true,
      showStack: false,
    })
    UtilLog.info(TAG, 'Ability onCreate');
    this.loginServiceImpl.handleWant(want);
    this.resolvePagePath(want);
  }

  onDestroy(): void {
    UtilLog.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    UtilLog.info(TAG, 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        UtilLog.error(TAG, JSON.stringify(err));
        return;
      }
      UtilLog.info(TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    UtilLog.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    UtilLog.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    UtilLog.info(TAG, 'Ability onBackground');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.loginServiceImpl.handleWant(want);
    this.resolvePagePath(want);
  }

  resolvePagePath(want: Want) {
    let parameters = want?.parameters;
    if (parameters?.url) {
      let formCardJump: FormCardJump = AppStorageV2.connect(FormCardJump, () => new FormCardJump())!;
      formCardJump.form = JSON.parse(parameters?.params.toString() || '');
      formCardJump.form.id = new Date().getTime()
    }
  }
};
