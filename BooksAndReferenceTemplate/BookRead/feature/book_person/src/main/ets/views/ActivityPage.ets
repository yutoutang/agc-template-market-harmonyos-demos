import { webview } from '@kit.ArkWeb';
import {  Constants } from 'common';

@ComponentV2
export struct ActivityPage {
  @Local windowTopHeight: number = AppStorage.get('windowTopHeight') as number || 38.77;
  @Local controller: webview.WebviewController = new webview.WebviewController();

  build() {
    NavDestination() {
      Column() {
        Web({ src: $rawfile('reading_app_activity.html'), controller: this.controller })
          .fileAccess(false)
          .geolocationAccess(false)
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
    }
    .title('活动中心')
    .padding({top:this.windowTopHeight})
  }
}