import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { HintParam } from '../model/Index';

@Builder
export function privacyCheckHint(param: HintParam) {
  Column({ space: 32 }) {
    Text('请先阅读并勾选会员服务协议').fontColor($r('sys.color.font_primary'));
    Text('我知道了').fontWeight(FontWeight.Medium).fontColor(param.btnFg).onClick(() => {
      param.uiContext.getPromptAction().closeCustomDialog(param.node).catch((err: BusinessError) => {
        hilog.error(0xFF00, '[Membership]', `privacyCheckHint err: ${JSON.stringify(err)}`);
      });
    });
  }
  .width(!param.isExpand ? 328 : 400)
  .padding(16)
  .backgroundColor($r('sys.color.comp_background_primary'))
  .borderRadius(32);
}