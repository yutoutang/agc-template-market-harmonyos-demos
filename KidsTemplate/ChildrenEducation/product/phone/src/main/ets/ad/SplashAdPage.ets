import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import {
  CommonConstants
} from '@ohos_agcit/children_education_utils';


@Builder
export function SplashAdPageBuilder() {
  SplashAdPage();
}

@ComponentV2
struct SplashAdPage {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      RelativeContainer() {
        AdServicePage({
          channelType: ChannelType.HUAWEI_AD,
          adId: 'testq6zq98hecj',
          adType: AdType.SPLASH_AD,
          closeCallBack: () => {
            this.appPathStack.pop();
          },
        })
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
  }
}