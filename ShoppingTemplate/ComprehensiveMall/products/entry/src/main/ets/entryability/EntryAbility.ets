import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { Logger } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';

const TAG: string = '[EntryAbility]'

export default class EntryAbility extends UIAbility {
  onCreate(): void {
    try {
      this.context
        .getApplicationContext()
        .setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    } catch (err) {
      Logger.error(TAG, JSON.stringify(err))
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    LoneTakeAnimationsTransition.init(windowStage);

    windowStage.loadContent('views/Index', (): void => {
      try {
        windowStage
          .getMainWindowSync()
          .getUIContext()
          .setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET);
      } catch (err) {
        Logger.error(TAG, JSON.stringify(err))
      }
    });
  }
}
