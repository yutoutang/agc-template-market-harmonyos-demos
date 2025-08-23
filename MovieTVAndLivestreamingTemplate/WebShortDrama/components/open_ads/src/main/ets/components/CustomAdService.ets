import { adType } from '../common/Constant';
import { display, window } from '@kit.ArkUI';

@ComponentV2
export struct CustomAdService {
  // 广告类型
  @Param adType?: adType = adType.AD_PICTURE
  @Param videoSrc?: ResourceStr = ''
  @Param previewUri?: ResourceStr = ''
  @Param imageUrl?: ResourceStr = ''
  // 应用Id（三方广告平台必传）
  @Param appId?: string = '';
  // 应用名称（三方广告平台必传）
  @Param appName?: string = '';
  // 广告关闭的回调
  @Param closeCallBack: () => void = () => {
  };
  controller: VideoController = new VideoController();
  @Local pageCountDown: number = 3;
  private timer: number = 0;
  private windowSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };

  aboutToAppear(): void {
    this.startTimer()
  }

  startTimer() {
    this.timer = setInterval(() => {
      this.pageCountDown--;
      if (this.pageCountDown === 0) {
        clearInterval(this.timer); // 关闭定时器
        this.closeCallBack()
      }
    }, 1000)
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Column() {
        if (this.adType === adType.AD_PICTURE) {
          Image(this.imageUrl)
            .width('100%')
            .height('100%')
        } else {
          Video({
            src: this.videoSrc,
            previewUri: this.previewUri,
            controller: this.controller,
          })
            .controls(false)
            .autoPlay(true)
            .loop(true)
            .width('100%')
            .height('100%')
        }
      }
      .width('100%')
      .height('100%')

      // 跳过按钮和倒计时
      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        Text('跳过')
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
        Text(`${this.pageCountDown}`)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
          .margin({ left: 2 })
      }
      .position({
        x: this.getUIContext().px2vp(this.windowSize.width - 300),
        y: 40
      })
      .width(66)
      .height(24)
      .backgroundColor($r('app.string.advertising_description_backgroundColor'))
      .borderRadius(18)
      .onClick(() => {
        this.pageCountDown = 1;
        clearInterval(this.timer); // 手动跳过时关闭定时器
        this.closeCallBack()
      })
    }
    .width('100%')
    .height('100%')
  }
}