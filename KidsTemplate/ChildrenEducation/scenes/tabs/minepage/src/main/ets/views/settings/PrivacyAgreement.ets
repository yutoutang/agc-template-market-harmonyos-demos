import { webview } from '@kit.ArkWeb';
import { CommonConstants } from '@ohos_agcit/children_education_utils';
import { common } from '@kit.AbilityKit';

@Builder
export function PrivacyAgreementBuilder() {
  PrivacyAgreement();
}

@ComponentV2
export struct PrivacyAgreement {
  topRectHeight: number = 0;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack()
  controller: webview.WebviewController = new webview.WebviewController();
  hostContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  privacyAgreementPath: string = ''

  build() {
    NavDestination() {
      Web({ src: this.privacyAgreementPath, controller: this.controller })
        .verticalScrollBarAccess(false)
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .hideTitleBar(true)
    .margin({
      top: this.getUIContext().px2vp(this.topRectHeight)
    })
    .onReady((cxt: NavDestinationContext) => {
      let param = cxt.pathInfo.param as string;
      this.privacyAgreementPath = param
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
  }
}