const topMargin: number = 50

export const stationDistanceLength: number = 120

export const startStationLocation: number = 30

export const busIcon: Resource = $r('app.media.bus_icon_normal')

/*
 * 公交示意图封装
 * */
@ComponentV2
export struct BusLineView {
  scroller: Scroller = new Scroller()
  @Param busStationName: string[] = []
  // 此处使用下标的形式来计算位置信息，需要在传入时自动转换成下标，提供了getIndex函数用来使用
  // 规则：这辆车在a 到 a+1站之间，则整数部分为a，小数部分使用车距离站点的位置比上两个车站之间的直线距离获得
  @Param busIndex: number[] = []
  // 线路上有多个公交，最近的公交做不同的标记
  //这里使用距离最近的公交在busIndex中的下标，需要调用方提供
  @Param nearToMe: number = -1


  build() {
    Scroll(this.scroller) {
      RelativeContainer() {
        //使用绝对坐标
        Column()
          .height(15)
          .width(stationDistanceLength * (this.busStationName.length - 1) + 40)
          .backgroundColor(Color.Green)
          .borderRadius(3)
          .margin({
            top: topMargin,
            left: startStationLocation - 10
          })

        //与分隔符
        ForEach(this.busStationName, (item: string, index: number) => {
          Text(item)
            .width(18)
            .fontSize('16fp')
            .maxLines(item.length)
            .margin({
              top: topMargin + 30,
              left: startStationLocation + stationDistanceLength * index - 9
            })
          Image($r('app.media.arr_busLine'))
            .width(8)
            .height(16)
            .margin({
              top: topMargin,
              left: startStationLocation + stationDistanceLength * index - 14
            })
          Image($r('app.media.arr_busLine'))
            .width(8)
            .height(16)
            .margin({
              top: topMargin,
              left: startStationLocation + stationDistanceLength * index + 16
            })
          Image($r('app.media.arr_busLine'))
            .width(8)
            .height(16)
            .margin({
              top: topMargin,
              left: startStationLocation + stationDistanceLength * index + 46
            })
          Image($r('app.media.arr_busLine'))
            .width(8)
            .height(16)
            .margin({
              top: topMargin,
              left: startStationLocation + stationDistanceLength * index + 76
            })
        }, (item: number) => item.toString())

        // bus
        ForEach(this.busIndex, (item: number, index: number) => {
          if (index === this.nearToMe) {
            Image($r('app.media.bus_icon_orange'))
              .width(30)
              .height(30)
              .margin({
                top: 20 - 2.5,
                left: startStationLocation + stationDistanceLength * item - 15
              })
            Image($r('app.media.station_orange'))
              .width(20)
              .height(20)
              .margin({
                top: topMargin - 2.5,
                left: startStationLocation + stationDistanceLength * item - 10
              })
          } else {

            Image($r('app.media.bus_icon_normal'))
              .width(30)
              .height(30)
              .margin({
                top: 20 - 2.5,
                left: startStationLocation + stationDistanceLength * item - 15
              })
            Image($r('app.media.station_normal'))
              .width(20)
              .height(20)
              .margin({
                top: topMargin - 2.5,
                left: startStationLocation + stationDistanceLength * item - 10
              })
          }
        }, (item: number) => item.toString())

      }
      .height('100%')
      .width(stationDistanceLength * (this.busStationName.length - 1) + 60 + startStationLocation)
      .constraintSize({ minWidth: '90%' })
      .backgroundColor($r('app.color.background_color_white'))
      .borderRadius({ topLeft: '20vp', topRight: '20vp' })

    }.height('100%')
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
