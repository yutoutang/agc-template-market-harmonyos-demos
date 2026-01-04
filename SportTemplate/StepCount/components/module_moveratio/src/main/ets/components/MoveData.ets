import { MoveDataModel } from '../model/MoveDataModel'

@ComponentV2
export struct MoveData {
  @Consumer('homeMoveDataModel') moveDataModel: MoveDataModel = new MoveDataModel()
  @Param widthGlobal ?: string = '100%'
  @Param isLogin: boolean = false

  build() {
    // 1. 统一层叠容器
    Stack() {
      // 外层最大
      Stack() {
        Gauge({
          value: this.isLogin ?
            (this.dataShow(this.moveDataModel.caloriesData[0], this.moveDataModel.caloriesData[1])) : 0,
          min: 0,
          max: this.moveDataModel.caloriesData[1]
        })
          .width(125)
          .height(125)
          .strokeWidth(11)
          .colors('#E04537')
          .startAngle(210)
          .endAngle(150)
          .indicator(null)
          .description(null)
          .trackShadow(null)
        Circle()
          .width(6).height(6)
          .fill(Color.White)
          .position({
            x: 125 / 2 + (125 / 2 - 11 / 2) * Math.cos(127 * Math.PI / 180) - 3,
            y: 125 / 2 + (125 / 2 - 11 / 2) * Math.sin(127 * Math.PI / 180) - 3
          })
      }.width(125).height(125)

      // 中层
      Stack() {
        Gauge({
          value: this.isLogin ? this.dataShow(this.moveDataModel.distanceData[0], this.moveDataModel.distanceData[1]) :
            0,
          min: 0,
          max: this.moveDataModel.distanceData[1]
        })
          .width(90)
          .height(90)
          .strokeWidth(11)
          .colors('#F2B73F',)
          .startAngle(210)
          .endAngle(150)
          .description(null)
          .indicator(null)
          .trackShadow(null)
        Circle()
          .width(6).height(6)
          .fill(Color.White)
          .position({
            x: 90 / 2 + (90 / 2 - 11 / 2) * Math.cos(129 * Math.PI / 180) - 3,
            y: 90 / 2 + (90 / 2 - 11 / 2) * Math.sin(129 * Math.PI / 180) - 3
          })
      }.width(90).height(90)

      // 内层最小
      Stack() {
        Gauge({
          value: this.isLogin ? this.dataShow(this.moveDataModel.stepData[0], this.moveDataModel.stepData[1]) : 0,
          min: 0,
          max: this.moveDataModel.stepData[1]
        })
          .width(50)
          .height(50)
          .strokeWidth(11)
          .colors('#3E78F7')
          .startAngle(210)
          .endAngle(150)
          .description(null)
          .indicator(null)
          .trackShadow(null)
        Circle()
          .width(6).height(6)
          .fill(Color.White)
          .position({
            x: 50 / 2 + (50 / 2 - 11 / 2) * Math.cos(140 * Math.PI / 180) - 3,
            y: 50 / 2 + (50 / 2 - 11 / 2) * Math.sin(140 * Math.PI / 180) - 3
          })
      }.width(50).height(50)

    }
    .alignContent(Alignment.Center) // 2. 三层圆心完全重合
    .width(this.widthGlobal)
    .height(this.widthGlobal)
  }

  dataShow(currentData: number, max: number) {
    return currentData > max ? max : currentData;
  }
}
