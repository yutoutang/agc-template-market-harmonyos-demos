import { getString } from '@agctemplate/resources';
import { DramaInfo } from '@agctemplate/server';
import { promptAction, window } from '@kit.ArkUI';

@ObservedV2
export default class ShortDramaInfoVM {
  windowStage: window.WindowStage = AppStorage.get('windowStage')!
  dramaInfo: DramaInfo = new DramaInfo('')

  constructor(dramaInfo: DramaInfo) {
    this.dramaInfo = dramaInfo;
  }

  public playDrama() {
    // 调用Toast显示提示：此样式仅为案例演示
    this.windowStage.getMainWindowSync().getUIContext().getPromptAction().showToast({ message: getString('app.string.demo_toast_tips') });
  }
}