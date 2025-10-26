import { NewsQrCode, ShareOptions } from '../model/Model'

@ComponentV2
export struct Screenshot {
  @Require @Param qrCodeInfo: ShareOptions

  handleQrCode() {
    let code: NewsQrCode = {
      articleId: this.qrCodeInfo?.id,
      type: this.qrCodeInfo?.type,
    }
    return JSON.stringify(code)
  }

  build() {
    Column() {
      Column() {
        Image(this.qrCodeInfo.coverUrl)
          .width('100%')
          .height('100%')
          .visibility(this.qrCodeInfo.coverUrl ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .layoutWeight(1)
      .borderRadius(8)

      Row() {
        Column() {
          Text(this.qrCodeInfo.title)
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
    .id(this.qrCodeInfo.id)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .width(270)
    .height(370)
    .padding(12)
  }
}