import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum, Constants, NavHeaderBar, ReturnButton } from 'common';
import { webview } from '@kit.ArkWeb';

@ComponentV2
export struct DataSharingPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  controller: webview.WebviewController = new webview.WebviewController();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '第三方共享信息清单',
          hasBackButton: true,
          hasBgColor: false,
          isMainPage: false,
        })
        Column(){
          Web({ src: $rawfile('data_sharing.html'), controller: this.controller })
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
