import { AccountUtil, RouterMap, RouterModule, WindowUtil } from 'commonlib';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack:NavPathStack = RouterModule.stack

  aboutToAppear(): void {
    WindowUtil.initWindowUtil(this.getUIContext());
    RouterModule.push({
      url:RouterMap.SAFE_PAGE
    }, false)
  }

  build() {
    Navigation(this.stack) {
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .hideBackButton(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack);
  }
}