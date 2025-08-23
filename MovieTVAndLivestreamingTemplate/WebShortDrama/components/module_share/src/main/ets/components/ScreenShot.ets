import { NewsQrCode } from '../model/ShareData'
import { SheetShowVM } from '../viewModel/SheetShowVM'

@ComponentV2
export struct ScreenShot {

  @Local shareShowVM: SheetShowVM = SheetShowVM.instance

  handleQrCode() {
    let code:NewsQrCode = {
      articleId:this.shareShowVM.qrCodeInfo?.id,
      type:this.shareShowVM.qrCodeInfo?.type,
      authorId:this.shareShowVM.qrCodeInfo?.author?.authorId
    }
    return JSON.stringify(code)
  }

  build() {
    Column() {
      Column() {
        Image(this.shareShowVM.coverUrl)
          .width('100%')
          .height('100%')
          .visibility(this.shareShowVM.coverUrl ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .layoutWeight(1)
      .borderRadius(8)

      Row() {
        Column() {
          Text(this.shareShowVM.title)
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(21)
            .fontSize('#000')
          Text('长按二维码查看详情')
            .fontSize(12)
            .lineHeight(16)
            .fontColor($r('sys.color.font_secondary'))
        }
        .height(41)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)

        QRCode(this.handleQrCode())
          .width(64)
          .height(64)
      }
      .width('100%')
      .margin({ top: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .id('Screenshot')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .width(270)
    .height(370)
    .padding(12)
  }
}