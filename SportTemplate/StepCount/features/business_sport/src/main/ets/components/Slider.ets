import {
  CustomSlider, CustomSliderThumbStyle, CustomSliderTraceParameters
} from 'lib_widget'

@ComponentV2
export struct ComSlider {
  @Param value: number = 50
  @Param minValue: number = 0
  @Param maxValue: number = 100
  @Local traceHeight: number = 100

  build() {
    CustomSlider({
      value: this.value,
      maxValue: this.maxValue,
      minValue: this.minValue,
      slideEnabled: false,
      thumbStyle: CustomSliderThumbStyle.Custom,
      customThumbBuilder: this.customThumbBuilder,
      customTrackBuilder: this.customTrackBuilder,
      customTraceBuilder: this.customTraceBuilder,
      trackSize: 14
    })
      .width('100%')
      .height(14)
  }

  @Builder
  customThumbBuilder() {
    // thumb
    Stack({ alignContent: Alignment.Start }) {
      Stack() {

      }
      .width(8)
      .height(8)
      .borderRadius(4)
      .backgroundColor(Color.White)
    }
    .width(26)
  }

  @Builder
  customTrackBuilder() {
    Stack()
      .width('100%')
      .height('100%')
      .backgroundColor('#D9D9D9')
  }

  @Builder
  customTraceBuilder(params: CustomSliderTraceParameters) {
    Stack()
      .width((params.value - params.minValue) / (params.maxValue - params.minValue) * params.trackLayoutWidth)
      .height('100%')
      .backgroundColor('#0A59F7')
      .borderRadius(7)
  }
}

@ComponentV2
export struct ColorSlider {
  @Param value: number = 50
  @Param minValue: number = 0
  @Param maxValue: number = 100
  @Local traceHeight: number = 100
  @Param colors: [ResourceColor, number][] = [['#E83B3D', 0], ['#FFD755', 0.5], ['#3BD148', 1.0]]

  build() {
    CustomSlider({
      value: this.value,
      maxValue: this.maxValue,
      minValue: this.minValue,
      slideEnabled: false,
      thumbStyle: CustomSliderThumbStyle.Custom,
      customThumbBuilder: this.customThumbBuilder,
      customTrackBuilder: this.customTrackBuilder,
      customTraceBuilder: this.customTraceBuilder,
      trackSize: 10
    })
      .width('100%')
      .height(10)
  }

  @Builder
  customThumbBuilder() {
    // thumb
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.ic_slider_arrow_thumb'))
        .width(20)
    }
    .height(28)
  }

  @Builder
  customTrackBuilder() {
    Stack()
      .width('100%')
      .height('100%')
      .backgroundColor('#D9D9D9')
  }

  @Builder
  customTraceBuilder(params: CustomSliderTraceParameters) {
    Stack()
      .width((params.value - params.minValue) / (params.maxValue - params.minValue) * params.trackLayoutWidth)
      .height('100%')
      .backgroundColor('#0A59F7')
      .linearGradient({
        direction: GradientDirection.Right,
        colors: this.colors
      })
      .borderRadius(5)
  }
}