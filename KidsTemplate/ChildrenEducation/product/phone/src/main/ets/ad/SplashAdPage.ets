import { AdServicePage, AdType, ChannelType } from 'aggregated_ads';
import {
  CommonConstants, GlobalInfoModel
} from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';


@Builder
export function SplashAdPageBuilder() {
  SplashAdPage();
}

@ComponentV2
struct SplashAdPage {
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    NavDestination() {
      RelativeContainer() {
        AdServicePage({
          channelType: ChannelType.HUAWEI_AD,
          adId: 'testq6zq98hecj',
          adType: AdType.SPLASH_AD,
          closeCallBack: () => {
            this.globalInfo.navStack.pop();
          },
        })
      }
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
  }
}