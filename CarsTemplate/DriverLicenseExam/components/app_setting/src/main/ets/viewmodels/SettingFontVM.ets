import { fp2pxUtil } from '../common/FontUtils';
import { BaseViewModel } from '../models/BaseViewModel';

@ObservedV2
export class SettingFontViewModel extends BaseViewModel {
  @Trace currentRatio: number = this.fontModel.fontSizeRatio;
  @Trace uiContext: UIContext | null = null;
  static _instance:SettingFontViewModel

  static get instance() {
    if (!SettingFontViewModel._instance) {
      SettingFontViewModel._instance = new SettingFontViewModel();
    }
    return SettingFontViewModel._instance;
  }

  confirm(ratio: number) {
    this.currentRatio = ratio;
    this.fontModel.fontSizeRatio = ratio;
    this.uiContext?.getPromptAction().showToast({ message: '字号设置已成功' });
  }

  setUIContext(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  getDescFg(fg: number): number | string {
    return fp2pxUtil(fg);
  }
}