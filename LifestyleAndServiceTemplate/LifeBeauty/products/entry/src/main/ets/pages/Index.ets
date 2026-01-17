import { RouterModule, RouterMap, BreakpointUtils, AppPrivacyUtils } from 'foundation';

@Entry
@ComponentV2
struct Index {
  private intervalId = 0;
  @Local privacyImpl: AppPrivacyUtils = AppPrivacyUtils.instance;
  breakpoint: BreakpointUtils | null = null;

  @Monitor('privacyImpl.agreeFlag')
  agreeFlagChange() {
    if (!this.privacyImpl.CONFIG_SHOW_HOME && this.privacyImpl.agreeFlag) {
      this.routeJoin();
    }
  }

  aboutToAppear() {
    this.registerBreakpointListener();
    this.privacyImpl.subscribe();
    if (!this.privacyImpl.CONFIG_SHOW_HOME && !this.privacyImpl.agreeFlag) {
      // 未同意隐私协议，不进入首页
      return;
    }
    this.routeJoin();
  }

  aboutToDisappear(): void {
    // 清除定时器
    clearInterval(this.intervalId);
    this.breakpoint?.unRegister();
    this.privacyImpl.unSubscribe();
  }

  routeJoin() {
    RouterModule.replace({ url: RouterMap.MAIN });
  }

  registerBreakpointListener() {
    this.breakpoint = new BreakpointUtils(this.getUIContext().getMediaQuery());
    this.breakpoint?.register();
  }

  build() {
    Navigation(RouterModule.getStack()) {
    }.hideNavBar(true)
  }
}