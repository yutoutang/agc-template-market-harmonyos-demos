import { BreakpointModel, BreakpointType } from '../models/BreakpointModel';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct Banner {
  @Param bannerArray: Array<ResourceStr> = [
    $r('app.media.ic_banner01'),
    $r('app.media.ic_banner02'),
    $r('app.media.ic_banner01'),
    $r('app.media.ic_banner02')
  ];
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // banner 显示个数
  swiperDisplayCount: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  build() {
    Column() {
      Swiper() {
        ForEach(this.bannerArray, (item: ResourceStr) => {
          Image(item)
            .interpolation(ImageInterpolation.High)
            .objectFit(ImageFit.Fill)
            .draggable(false)
            .borderRadius(16)
            .margin({ left: 6, right: 6 })
            .width(new BreakpointType<number>({
              sm: 496,
              md: 496,
              lg: 496,
              xl: 496
            }).getValue(this.breakpointModel.currentBreakpoint))
            .height(new BreakpointType<number>({
              sm: 159,
              md: 189,
              lg: 189,
              xl: 189
            }).getValue(this.breakpointModel.currentBreakpoint));
        }, (item: string, index: number) => item + index);
      }
      .indicator(false)
      .nextMargin(32)
      .prevMargin(32)
      .loop(true)
      .autoPlay(true)
      .displayCount(this.swiperDisplayCount.getValue(this.breakpointModel.currentBreakpoint))
      .layoutWeight(1);
    }
    .width('100%')
    .height(new BreakpointType<number>({
      sm: 159,
      md: 189,
      lg: 189,
      xl: 189
    }).getValue(this.breakpointModel.currentBreakpoint));
  }
}