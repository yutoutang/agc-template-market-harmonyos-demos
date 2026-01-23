import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct Banner {
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  @Param bannerArray: Array<string> = [];

  build() {
    Column() {
      Swiper() {
        ForEach(this.bannerArray, (item: string, index: number) => {
          Image(item)
            .borderRadius(16)
            .margin({ left: 8, right: 8 })
            .width(new BreakpointType<number>({
              sm: 336,
              md: 496,
              lg: 496,
            }).getValue(this.globalInfo.currentBreakpoint))
            .height(new BreakpointType<number>({
              sm: 189,
              md: 189,
              lg: 189,
            }).getValue(this.globalInfo.currentBreakpoint))
        }, (item: string) => item)
      }
      .nextMargin(new BreakpointType<number>({
        sm: 0,
        md: 36,
        lg: 36,
      }).getValue(this.globalInfo.currentBreakpoint))
      .prevMargin(new BreakpointType<number>({
        sm: 0,
        md: 36,
        lg: 36,
      }).getValue(this.globalInfo.currentBreakpoint))
      .displayCount(new BreakpointType<number>({
        sm: 1,
        md: 2,
        lg: 3,
      }).getValue(this.globalInfo.currentBreakpoint))
      .loop(true)
      .indicator(false)
      .autoPlay(true)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
