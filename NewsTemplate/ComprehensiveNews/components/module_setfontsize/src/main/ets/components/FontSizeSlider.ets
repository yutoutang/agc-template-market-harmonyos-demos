import { Constants, FontSizeEnum, FontSizeItem, FONT_SIZE_LIST } from '../common/Constants'

@ComponentV2
export struct FontSizeSlider {
  @Param currentRatio: number = FontSizeEnum.NORMAL;
  @Event $currentRatio: (value: FontSizeEnum) => void = () => {
  };
  @Local sliderV: number = 1;

  aboutToAppear(): void {
    const item = FONT_SIZE_LIST.find(v => v.value === this.currentRatio);
    if (item) {
      this.sliderV = item.id;
    }
  }

  build() {
    Column({ space: 2 }) {
      Row({ space: 20 }) {
        Text('A')
          .fontSize(14 * FontSizeEnum.SMALL)
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
        Slider({
          min: 0,
          max: 3,
          step: 1,
          style: SliderStyle.InSet,
          value: this.sliderV,
        })
          .layoutWeight(1)
          .showSteps(true)
          .onChange((value: number) => {
            this.$currentRatio(FONT_SIZE_LIST[value].value);
          })
        Text('A')
          .fontSize(14 * FontSizeEnum.XL)
          .fontColor($r('sys.color.font_secondary'))
          .accessibilityLevel('no')
      }
      .width(Constants.FULL_PERCENT)
      .height(40)

      Row() {
        ForEach(FONT_SIZE_LIST, (v: FontSizeItem) => {
          Text(v.label).fontSize(10).fontColor($r('sys.color.font_secondary'))
        }, (v: FontSizeItem) => v.label)
      }
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 42, right: 42 })
    }
    .width(Constants.FULL_PERCENT)
  }
}
