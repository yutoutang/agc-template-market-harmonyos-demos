import { AvModel } from 'lib_news_api'
import { VipBadge } from './VipBadge'

@ComponentV2
export struct AudioIntroduce {
  @Param curAudioInfo: AvModel = new AvModel()
  @Param fontSizeRatio: number = 1
  @Event onSubscribe: (curAudioInfo: AvModel) => void = () => {
  }

  build() {
    Column({ space: 12 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row({ space: 12 }) {
          Stack() {
            Image(this.curAudioInfo.coverUrl)
              .width(74)
              .height(74)
              .borderRadius(8)
              .clip(true)
            VipBadge({ isSquareStyle: false, customRadius: 8 })
          }
          .alignContent(Alignment.TopEnd)

          Column({ space: 4 }) {
            Text(this.curAudioInfo.title)
              .fontWeight(FontWeight.Medium)
              .fontSize(18 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
            Text(`共${this.curAudioInfo.section.length}期`)
              .fontSize(14 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }

        Button(this.curAudioInfo.isFollow ? '已订阅' : '订阅')
          .fontColor(this.curAudioInfo.isFollow ? $r('sys.color.font_emphasize') : $r('sys.color.font_on_primary'))
          .fontSize(14 * this.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.curAudioInfo.isFollow ? $r('sys.color.comp_background_tertiary') : '#5C79D9')
          .width(72)
          .height(28)
          .padding(0)
          .onClick(() => {
            this.onSubscribe(this.curAudioInfo)
          })
      }

      Text(this.curAudioInfo.description)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize(14 * this.fontSizeRatio)
        .lineHeight(19)
    }
    .width('100%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
  }
}