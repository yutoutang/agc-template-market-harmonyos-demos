import { BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from 'module_ui_base';
import { Constants } from '../commons/Constants';

@ComponentV2
export struct ProductSwiper {
  @Param
  imgList: ResourceStr[] = [];
  @Local
  curIndex: number = 0;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Computed
  get outImageDisplayWidth() {
    return this.curBreakpoint.value === BreakpointTypeEnum.MD ? 120 : 0;
  }

  @Computed
  get swiperPadding() {
    return this.curBreakpoint.value === BreakpointTypeEnum.MD ? 0 : $r('app.string.space_l')
  }

  @Computed
  get imagePadding() {
    return this.curBreakpoint.value === BreakpointTypeEnum.MD ?
      {
        left: 6,
        right: 6,
        top: 8,
        bottom: 8,
      } as Padding : 0
  }

  build() {
    Swiper() {
      ForEach(this.imgList, (item: ResourceStr) => {
        Image(item)
          .height('100%')
          .constraintSize({
            maxHeight: this.curBreakpoint.value === BreakpointTypeEnum.LG ? '100%' : 360,
          })
          .aspectRatio(this.curBreakpoint.value === BreakpointTypeEnum.LG ? undefined : 1.0)
          .objectFit(ImageFit.Cover)
          .padding(this.imagePadding)
      }, (item: ResourceStr) => JSON.stringify(item));
    }
    .index(this.curIndex)
    .width('100%')
    .padding({ left: this.swiperPadding, right: this.swiperPadding })
    .prevMargin(this.outImageDisplayWidth, true)
    .nextMargin(this.outImageDisplayWidth, true)
    .indicatorInteractive(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .indicator(
      new DotIndicator()
        .selectedItemWidth(12)
        .selectedItemHeight(6)
        .selectedColor(Constants.THEME_COLOR)
        .itemWidth(6)
        .itemHeight(6)
        .color($r('sys.color.comp_background_secondary')),
    );
  }
}