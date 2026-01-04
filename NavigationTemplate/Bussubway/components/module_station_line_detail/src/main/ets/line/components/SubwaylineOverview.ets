import { LineCommonConstants } from '../common/LineCommonConstants'

@ComponentV2
export struct SubwaylineOverview {
  @Param @Require name: string
  @Param @Require startStop: string
  @Param @Require endStop: string
  @Param @Require startTime: string
  @Param @Require endTime: string
  @Param @Require basicPrice: string
  @Param @Require totalPrice: string
  @Param @Require interval: string
  @Event switchDirec: () => void = () => {
  }

  build() {
    Row() {
      Column() {
        Text(this.name)
          .fontWeight(FontWeight.Bold)
          .fontSize(20)
          .lineHeight(24)
          .height(28)
        Row() {
          Text(this.startStop)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
          Image($r('app.media.direction'))
            .width(24).height(6)
            .margin({ left: 7, right: 7 })
          Text(this.endStop)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
        }
        .height(20)
        .margin({ top: 8 })

        Text() {
          Span('首 ')
          Span(this.startTime)
          Span(' | ')
          Span('末 ')
          Span(this.endTime)
          Span(' · ')
          Span(this.interval)
          Span('分钟/班')
          Span(' · ')
          Span('票价:')
          Span(this.basicPrice)
          Span('-')
          Span(this.totalPrice)
          Span('元')
        }
        .fontSize(12)
        .height(17)
        .margin({ top: 7 })
      }
      .alignItems(HorizontalAlign.Start)

      Column() {
        Image($r('app.media.route_switch'))
          .width(52)
          .height(28)
          .onClick(() => {
            this.switchDirec()
          })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width(LineCommonConstants.FULL_PERCENT)
    .padding({
      top: 8,
      bottom: 10,
      left: 12,
      right: 12
    })
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)

  }
}