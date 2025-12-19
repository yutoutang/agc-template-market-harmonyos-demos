import { webview } from '@kit.ArkWeb';
import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';
import { common } from '@kit.AbilityKit';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  topRectHeight: number = 0;
  uiContext: UIContext = this.getUIContext() as UIContext;
  hostContext: common.Context = this.uiContext.getHostContext() as Context;
  vm: MainEntryVM = MainEntryVM.instance;
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = this.hostContext.resourceManager.getStringSync($r('app.string.privacyAgreementPath').id);

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false);
    }
    .hideTitleBar(true)
    .margin({
      top: this.uiContext.px2vp(this.topRectHeight)
    })
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as Record<string, Object>;
      if (param !== undefined) {
        this.privacyAgreementPath = param.protocolUrl as string;
      }
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
  }
}