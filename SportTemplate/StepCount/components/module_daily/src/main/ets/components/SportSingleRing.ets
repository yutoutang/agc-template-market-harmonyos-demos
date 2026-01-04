/**
 * 运动环类型
 */
export enum SportSingleRingType {
  Step,
  Distance,
  Calorie,
}

/**
 * 单环组件
 */
@ComponentV2
export struct SportSingleRing {
  @Param max: number = 1000;
  @Param currentData: number = 0;
  @Local colorData: ResourceStr = '';
  @Local imageData: ResourceStr = '';
  @Param type: SportSingleRingType = SportSingleRingType.Step;
  @Local imageHeight: number = 30;

  aboutToAppear(): void {
    switch (this.type) {
      case SportSingleRingType.Step:
        this.colorData = '#035ff2';
        this.imageData = $r('app.media.ic_chart_distance')
        break;
      case SportSingleRingType.Distance:
        this.colorData = '#f2b73f';
        this.imageData = $r('app.media.icon_running_distance')
        this.imageHeight = 24
        break;
      case SportSingleRingType.Calorie:
        this.colorData = '#e04537';
        this.imageData = $r('app.media.ic_chart_deplete')
        break;
    }
  }

  build() {
    Stack() {
      Gauge({ value: this.dataShow(this.currentData, this.max), min: 0, max: this.max })
        .width(56)
        .height(56)
        .strokeWidth(7)
        .colors(this.colorData)
        .startAngle(210)
        .endAngle(150)
        .indicator(null)
        .description(null)
        .trackShadow(null)
      Image(this.imageData)
        .width(this.imageHeight)
        .objectFit(ImageFit.Contain)
        .aspectRatio(1)
        .offset({ y: 4 })
    }
    .alignContent(Alignment.Center)
  }

  dataShow(currentData: number, max: number) {
    return currentData > max ? max : currentData;
  }
}