/**
 * 三环组件
 */
@ComponentV2
export struct SportThirdRingRoad {
  @Param multiple: number = 1
  @Param showCircle: boolean = true;
  @Param caloriesData: number[] = [200, 1000];
  @Param distanceData: number[] = [500, 1000];
  @Param stepData: number[] = [300, 1000];
  @Event click?: () => void;

  build() {
    Stack() {
      Stack() {
        Gauge({ value: this.dataShow(this.caloriesData[0], this.caloriesData[1]), min: 0, max: this.caloriesData[1] })
          .width(125 / this.multiple)
          .height(125 / this.multiple)
          .strokeWidth(11 / this.multiple)
          .colors('#E04537')
          .startAngle(210)
          .endAngle(150)
          .indicator(null)
          .description(null)
          .trackShadow(null)
        Circle()
          .width(6 / this.multiple)
          .aspectRatio(1)
          .fill(Color.White)
          .position({
            x: (125 / 2 + (125 / 2 - 11 / 2) * Math.cos(126 * Math.PI / 180) - 3) / this.multiple,
            y: (125 / 2 + (125 / 2 - 11 / 2) * Math.sin(126 * Math.PI / 180) - 3) / this.multiple
          })
          .visibility(this.showCircle ? Visibility.Visible : Visibility.None)
      }.width(125 / this.multiple).aspectRatio(1)

      Stack() {
        Gauge({ value: this.dataShow(this.distanceData[0] / 1000,
          this.distanceData[1]), min: 0, max: this.distanceData[1] })
          .width(90 / this.multiple)
          .height(90 / this.multiple)
          .strokeWidth(11 / this.multiple)
          .colors('#F2B73F')
          .startAngle(210)
          .endAngle(150)
          .description(null)
          .indicator(null)
          .trackShadow(null)
        Circle()
          .width(6 / this.multiple)
          .aspectRatio(1)
          .fill(Color.White)
          .position({
            x: (90 / 2 + (90 / 2 - 11 / 2) * Math.cos(129 * Math.PI / 180) - 3) / this.multiple,
            y: (90 / 2 + (90 / 2 - 11 / 2) * Math.sin(129 * Math.PI / 180) - 3) / this.multiple
          })
          .visibility(this.showCircle ? Visibility.Visible : Visibility.None)
      }.width(90 / this.multiple)
      .aspectRatio(1)

      Stack() {
        Gauge({ value: this.dataShow(this.stepData[0], this.stepData[1]), min: 0, max: this.stepData[1] })
          .width(50 / this.multiple)
          .height(50 / this.multiple)
          .strokeWidth(11 / this.multiple)
          .colors('#3E78F7')
          .startAngle(210)
          .endAngle(150)
          .description(null)
          .indicator(null)
          .trackShadow(null)
        Circle()
          .width(6 / this.multiple)
          .aspectRatio(1)
          .fill(Color.White)
          .position({
            x: (50 / 2 + (50 / 2 - 11 / 2) * Math.cos(137 * Math.PI / 180) - 3) / this.multiple,
            y: (50 / 2 + (50 / 2 - 11 / 2) * Math.sin(137 * Math.PI / 180) - 3) / this.multiple
          })
          .visibility(this.showCircle ? Visibility.Visible : Visibility.None)
      }.width(50 / this.multiple).aspectRatio(1)

    }
    .alignContent(Alignment.Center)
    .onClick(() => {
      if (this.click) {
        this.click()
      }
    })
  }

  dataShow(currentData: number, max: number) {
    return currentData > max ? max : currentData;
  }
}