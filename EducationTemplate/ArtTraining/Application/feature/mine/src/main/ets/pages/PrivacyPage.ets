import { CommonHeader } from 'componentlib';
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';

@Builder
export function privacyPageBuilder() {
  PrivacyPage();
}

@Component
export struct PrivacyPage {
  @State controller: AtomicServiceWebController = new AtomicServiceWebController();

  build() {
    NavDestination() {
      CommonHeader({ title: '隐私声明' });
      Column() {
        AtomicServiceWeb({ src: $rawfile('privacy.html'), controller: this.controller })
      }
      .padding($r('app.string.padding_s'))
      .layoutWeight(1);
    }
    .hideTitleBar(true);
  }
}
