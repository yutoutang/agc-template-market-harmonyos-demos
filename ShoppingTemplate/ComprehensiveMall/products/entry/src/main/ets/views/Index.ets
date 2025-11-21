import { BreakpointSystem, RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack: NavPathStack = routerStack
  @Local
  isEnabled: boolean = true

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
    .mode(NavigationMode.Stack)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        },
      });
    })
  }
}