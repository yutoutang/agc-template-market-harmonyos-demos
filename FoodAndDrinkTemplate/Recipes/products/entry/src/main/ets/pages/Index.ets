import { BreakpointUtils, CommonConstants, GlobalContextUtils, RouterMap, RouterModule } from 'commonlib';

@Entry
@ComponentV2
struct Index {
  navStack: NavPathStack = RouterModule.getStack();
  breakpoint: BreakpointUtils | null = null;

  aboutToAppear(): void {
    GlobalContextUtils.setUIContext('entry', this.getUIContext());
    this.breakpoint = new BreakpointUtils(this.getUIContext().getMediaQuery());
    this.breakpoint?.register()
    RouterModule.replace(RouterMap.LAUNCH_PAGE)
  }

  aboutToDisappear(): void {
    this.breakpoint?.unRegister();
  }

  build() {
    Navigation(this.navStack) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH);
  }
}
