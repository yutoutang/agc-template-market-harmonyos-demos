import { TotalCountParam } from '../types/MoveCount'
import { MoveData } from './MoveData'

@Builder
export function TotalDataBuilder() {
  TotalData()
}

@ComponentV2
export struct TotalData {
  @Param totalCountData: TotalCountParam[] = []
  @Event dataClick: () => void
  @Param isLogin: boolean = false

  @Builder
  moveDataBuilder(item: TotalCountParam) {
    Column({ space: 8 }) {
      // 为图标添加更多空间，确保完全显示
      Image($r('app.media.' + item.icon))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .margin({ top: 2, bottom: 2 })
      Text(item.title).fontSize(12).lineHeight(17).fontColor('#888')
      Row() {
        Text(this.isLogin ? item.count : '0')
          .fontSize(20)
          .lineHeight(25)
          .fontColor('#333')
        Text(`/${item.uint}`)
          .fontSize(12)
          .lineHeight(25)
          .fontColor('#888')
      }.alignItems(VerticalAlign.Bottom)
    }.justifyContent(FlexAlign.Start)
  }

  build() {
    NavDestination() {
      Column({ space: 14 }) {
        Column({ space: 4 }) {
          Stack({ alignContent: Alignment.Bottom }) {
            MoveData({ isLogin: this.isLogin }).size({ width: '100%', height: 120 })
            Text($r('app.string.recent_seven_day')).fontSize(14).fontColor('#999').textAlign(TextAlign.Center)
          }

        }
        .width('100%')
        .height(140)
        .padding({ top: 15 })
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          if (this.dataClick) {
            this.dataClick()
          }
        })

        Row({ space: 20 }) {
          ForEach(this.totalCountData, (item: TotalCountParam) => {
            this.moveDataBuilder(item)
          }, (item: TotalCountParam) => JSON.stringify(item))
        }.justifyContent(FlexAlign.Center)
        .width('100%')
      }
      .padding({ left: 24, right: 24 })
      .borderRadius(12)
      .width('100%')
      .height(258)
      .shadow({ radius: 10, color: '#FFF8EB' })
      .linearGradient({
        angle: 180,
        colors: [['#FFF8EB', 0.5], ['#FFFFFF', 1]]
      })
    }
    .borderRadius(12)
    .hideTitleBar(true)
    .height(258)
  }
}