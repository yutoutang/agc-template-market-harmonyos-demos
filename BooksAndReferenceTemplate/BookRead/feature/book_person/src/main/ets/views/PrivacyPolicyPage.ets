import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants, NavHeaderBar} from 'common';
import { webview } from '@kit.ArkWeb';
@ComponentV2
export struct PrivacyPolicyPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local controller: webview.WebviewController = new webview.WebviewController();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '隐私声明',
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: false,
        })
        Column(){
          Web({ src: $rawfile('privacy_policy.html'), controller: this.controller })
            .darkMode(WebDarkMode.Auto)
            .forceDarkAccess(true)
            .fileAccess(false)
            .geolocationAccess(false)
        }
        .width(this.curBreakpoint.value === BreakpointTypeEnum.LG ? '70%' : '100%')
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .hideTitleBar(true)
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
