import { RouterType } from '../model/FormCardConstant'

let localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct TicketWidgetCard {
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('qrcode') qrcode: string = '';

  aboutToAppear(): void {
  }

  build() {
    Column() {
      if (this.qrcode) {
        QRCode(this.qrcode)
          .width(100)
          .height(100)
          .padding(8)
          .border({
            width: 1,
            color: 'rgb(242, 64, 61)',
            radius: 6
          })
          .margin({ top: 4 })
        Text('我的门票')
          .margin({ top: 4 })
          .fontSize(14)
          .fontColor('#606162')
      } else {
        Image($r('app.media.entrance_card_bg')).width(40)
        Image($r('app.media.ticket_widget')).width(48)
        Text('我的门票')
          .fontSize(14)
          .lineHeight(20)
          .fontColor('#606162')
      }
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .alignItems(this.qrcode ? HorizontalAlign.Center : HorizontalAlign.Start)
    .justifyContent(this.qrcode ? FlexAlign.Center : FlexAlign.SpaceBetween)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          type: RouterType.TICKET,
        }
      });
    })
  }
}