import { HintParam } from '../model/Index';

@Builder
export function privacyCheckHint(param: HintParam) {
  Column({ space: 32 }) {
    Text('请先阅读并勾选会员服务协议').fontColor($r('sys.color.font_primary'))
      .maxFontScale(1);
    Text('我知道了').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_emphasize'))
      .maxFontScale(1)
      .onClick(() => {
      param.uiContext.getPromptAction().closeCustomDialog(param.node);
    });
  }.width('90%').padding(16).backgroundColor($r('sys.color.comp_background_primary')).borderRadius(32);
}