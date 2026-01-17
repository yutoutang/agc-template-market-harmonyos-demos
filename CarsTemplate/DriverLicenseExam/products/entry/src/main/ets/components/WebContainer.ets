import { webview } from '@kit.ArkWeb';
import { CommonModel } from '@ohos_agcit/driver_license_exam_commonlib';

export interface  webViewParam {
  title: string;
  path: string;
}

@Builder
export function WebContainerBuilder() {
  WebContainer()
}

@ComponentV2
struct WebContainer {
  topRectHeight: number = 0;
  vm: CommonModel = CommonModel.instance;
  @Local title:string = '';
  controller: webview.WebviewController = new webview.WebviewController();
  @Local path: string = 'developer.huawei.com';

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    let param:webViewParam = this.vm.navStack.getParamByIndex(this.vm.navStack.size() - 1) as webViewParam;
    this.path = param.path;
    this.title = param.title;
  }

  build() {
    NavDestination() {
      Web({ src: this.path, controller: this.controller })
        .fileAccess(false)
        .geolocationAccess(false)
    }
    .title(this.title)
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.vm.navStack.pop();
      return true;
    })
  }
}