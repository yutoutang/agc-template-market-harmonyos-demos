import { webview } from '@kit.ArkWeb';
import { ObjectUtil } from '@ohos_agcit/notes_utils';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack()
  controller: webview.WebviewController = new webview.WebviewController();
  privacyAgreementPath : string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.privacyAgreementPath').id);

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .hideTitleBar(true)
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as Record<string, Object>;
      if (ObjectUtil.isNotNull(param)) {
        this.privacyAgreementPath = param.protocolUrl as string;
      }
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}