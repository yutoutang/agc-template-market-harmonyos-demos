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
            .aspectRatio(16 / 9)
            .width('100%')
        }, (item: string) => item)
      }
      .itemSpace(
        new BreakpointType<number>({
          sm: 0,
          md: 12,
          lg: 16,
        }).getValue(this.globalInfo.currentBreakpoint)
      )
      .interval(3000)
      .nextMargin(new BreakpointType<number>({
        sm: 0,
        md: 24,
        lg: 36,
      }).getValue(this.globalInfo.currentBreakpoint))
      .prevMargin(new BreakpointType<number>({
        sm: 0,
        md: 24,
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
