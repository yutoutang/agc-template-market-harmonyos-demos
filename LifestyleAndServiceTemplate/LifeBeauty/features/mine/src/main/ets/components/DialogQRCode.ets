import { CommonConstants, PopViewUtils } from 'foundation';

export class QRCodeParams {
  qrcode: string = '';

  constructor(qrcode?: string) {
    this.qrcode = qrcode ?? '';
  }
}

@Builder
export function DialogQRCodeBuilder(params: QRCodeParams) {
  Column() {
    Column() {
      QRCode(params.qrcode).width(200).height(200).margin({top: 8, bottom: 32})
      Text(params.qrcode).fontSize(16)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      top: 24,
      bottom: 24,
    })
    .borderRadius(32)
    .backgroundColor(Color.White)
  }
  .padding({ left: 12, right: 12 })
  .width(320)
}