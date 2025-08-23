import { ComponentContent, componentSnapshot } from '@kit.ArkUI'
import { secondShareBuilder } from './SecondShare'
import { image } from '@kit.ImageKit'
import { SheetShowVM } from '../viewModel/SheetShowVM'
import { PosterShare } from '../utils/SystemShare'

@ComponentV2
export struct FirstShare {

  @Local shareShowVM: SheetShowVM = SheetShowVM.instance
  @Local posterShare: PosterShare = new PosterShare()
  @Event close: () => void
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.getUIContext(), wrapBuilder(secondShareBuilder), () => {
      this.getUIContext().getPromptAction().closeCustomDialog(this.contentNode)
      this.close()
    })


  build() {
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
      }
      .width(328)
      .height(88)
      .margin({ top: 16 })

      Row({ space: 9}) {
        Column({ space:8 }) {
          Image($r('app.media.create_poster'))
            .width(48)
            .height(48)
          Text('生成海报')
            .height(16)
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_primary'))
        }
        .width(68)
        .height(88)
        .onClick(() => {
          this.close()
          this.getUIContext().getPromptAction().openCustomDialog(this.contentNode, {
            onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
              if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
                dismissDialogAction.dismiss()
              }
              if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
                dismissDialogAction.dismiss()
              }
            },
            alignment: DialogAlignment.Bottom
          }).then(() => {
            componentSnapshot.get('Screenshot', ((err: Error, pixmap: image.PixelMap) => {
              if (err) {
                return
              }
              this.shareShowVM.setPosterImage(pixmap)
            }))
          })
        })

        Column({ space:8 }) {
          Image($r('app.media.copy_link'))
            .width(48)
            .height(48)
          Text('复制链接')
            .height(16)
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_primary'))
        }
        .width(68)
        .height(88)
        .onClick(() => {
          this.posterShare.copy()
        })
        Column({ space:8 }) {
          Image($r('app.media.system_share'))
            .width(48)
            .height(48)
          Text('系统分享')
            .height(16)
            .fontSize(12)
            .fontWeight(400)
            .fontColor($r('sys.color.font_primary'))
        }
        .width(68)
        .height(88)
        .onClick(() => {
          this.posterShare.share()
        })
      }
      .width(328)
      .height(88)
      .margin({ top: 16 })

      Text('取消')
        .width(328)
        .height(40)
        .borderRadius(20)
        .backgroundColor('rgba(0, 0, 0, 0.1)')
        .fontSize(16)
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .fontColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.close()
        })
    }
    .width(328)
    .height(352)
  }
}