import { Want } from '@kit.AbilityKit';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { ShareService } from 'aggregated_share';
import { PushUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { UtilLog } from '@hw-agconnect/util-log';
import { SetupUtil } from '../utils/SetupUtil';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  private shareServiceImpl: ShareService =
    ShareService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('wxc92d9d6570127a32')
      // todo 填写QQ互联平台配置的应用AppID
      .initQQ(102061317);

  onCreate(want: Want): void {
    UtilLog.setGlobalConfig({
      tag: 'ComprehensiveMall',
      domain: 0xff00,
      open: true,
      showStack: false,
    });
    UtilLog.info(TAG, 'set global log config success.');
    try {
      this.context
        .getApplicationContext()
        .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (err) {
      UtilLog.error(TAG, JSON.stringify(err));
    }
    this.shareServiceImpl.handleWant(want, this.context);
    SetupUtil.handleWant(want);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('views/Index', (): void => {
      try {
        windowStage
          .getMainWindowSync()
          .getUIContext()
          .setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET);
        PushUtil.getTokenSyn();
        LoneTakeAnimationsTransition.init(windowStage);
      } catch (err) {
        UtilLog.error(TAG, JSON.stringify(err));
      }
    });
  }

  onNewWant(want: Want): void {
    SetupUtil.handleWant(want);
    SetupUtil.jumpToTarget();
  }
}
