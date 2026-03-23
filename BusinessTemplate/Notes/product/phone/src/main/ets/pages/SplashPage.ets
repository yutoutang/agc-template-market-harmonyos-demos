import { AdvertisementComponent } from 'aggregated_ads';
import { router } from '@kit.ArkUI';

@Builder
export function buildSplashPage() {
  SplashPage()
}

@Entry
@ComponentV2
export struct SplashPage {


  build() {
    Column(){
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.startIcon'))
          .width('300vp')
          .height('300vp')

        AdvertisementComponent({
          adType: 1,
          testAd: 'testd7c5cewoj6',
          skipAd: () => {
            try {
              router.replaceUrl({
                url: 'pages/Index',
              });
            } catch (error) {
              console.error(`路由跳转失败: ${JSON.stringify(error)}`);
            }
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}