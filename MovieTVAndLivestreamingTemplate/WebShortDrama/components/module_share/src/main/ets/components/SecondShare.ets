import { PosterShare } from '../utils/SystemShare'
import { ScreenShot } from './ScreenShot'

@ComponentV2
export struct SecondShare {

  @Local posterShare: PosterShare = new PosterShare()
  @Event onCancel: Function = (): void => {
  }

  build() {
    Column() {
      Column() {
        ScreenShot()
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      Column() {
        Row({ space: 9}) {
          Column({ space:8 }) {
            Image($r('app.media.wechat'))
              .width(48)
              .height(48)
            Text('微信')
              .height(16)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_primary'))
          }
          .width(68)
          .height(88)

          Column({ space:8 }) {
            Image($r('app.media.friend_circle'))
              .width(48)
              .height(48)
            Text('朋友圈')
              .height(16)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_primary'))
          }
          .width(68)
          .height(88)


          Column({ space:8 }) {
            Image($r('app.media.save'))
              .width(48)
              .height(48)
            Text('保存图片')
              .height(16)
              .fontSize(12)
              .fontWeight(400)
              .fontColor($r('sys.color.font_primary'))
          }
          .width(68)
          .height(88)
          .onClick(() => {
            this.posterShare.saveImage()
          })
        }
        .width(328)
        .height(88)
        .margin({ top: 32 })

        Text('取消')
          .width(328)
          .height(40)
          .borderRadius(20)
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .fontSize(16)
          .fontWeight(500)
          .margin({ top: 16 })
          .textAlign(TextAlign.Center)
          .fontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.onCancel()
          })
      }
      .width('100%')
      .height(212)
      .backgroundColor('#F1F3F5')
      .borderRadius({ topLeft: 32, topRight: 32 })
    }
    .width('100%')
    .height('100%')
  }
}


@Builder
export function secondShareBuilder(onCancel: Function) {
  SecondShare({ onCancel: onCancel })
}