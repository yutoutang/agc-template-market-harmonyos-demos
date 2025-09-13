import { BreakpointSystem, PopViewUtil, RouterMap, routerStack, WindowUtil } from 'lib_foundation';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack: NavPathStack = routerStack

  aboutToAppear(): void {
    const uiContext = this.getUIContext()
    BreakpointSystem.register(uiContext)
    WindowUtil.initWindowUtil(uiContext)
    routerStack.pushPath({
      name: RouterMap.SAFE_PAGE,
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