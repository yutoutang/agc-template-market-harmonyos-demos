import { Constants, OrderStateEnum, OrderTypeEnum } from '../constants/Index';
import { OrderInfo } from '../models/Index';
import { copyString } from '../utils/Utils';

@Styles
function cardStyle() {
  .width('100%')
  .constraintSize({ maxWidth: '100%' })
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(12)
  .padding(12)
  .margin({
    left: 16,
    right: 16,
  });
}

@ComponentV2
export struct OrderTypeComp {
  @Param @Require orderInfo: OrderInfo
  @Param orderState: number = OrderStateEnum.TO_BE_PAID
  @Param estimatedTime: string = ''
  @Local timer: number = 0
  @Local countdownMin: number = 0
  @Local countdownSec: number = 0
  @Event cancelOrderCb: () => void = () => {
  }
  @Event showPaySheet: () => void = () => {
  }
  @Event oneMoreOrder: () => void = () => {
  }

  aboutToAppear(): void {
    if (this.orderState === OrderStateEnum.TO_BE_PAID) {
      this.openTimer()
    }
  }

  aboutToDisappear(): void {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }

  openTimer() {
    if (this.timer) {
      clearInterval(this.timer)
    }
    let orderTime = new Date(this.orderInfo.time!)
    orderTime.setMinutes(orderTime.getMinutes() + 30)
    let countdownSec = Math.floor((orderTime.getTime() - new Date().getTime()) / 1000)
    this.countdownSec = countdownSec >= 0 ? countdownSec : 0
    this.countdownMin = Math.floor(this.countdownSec / Constants.SECOND_TO_MIN)
    this.timer = setInterval(() => {
      if (this.countdownSec <= 0) {
        clearInterval(this.timer)
        this.cancelOrderCb()
        return
      }
      this.countdownSec--
      if (this.countdownSec > Constants.SECOND_TO_MIN) {
        this.countdownMin = Math.floor(this.countdownSec / Constants.SECOND_TO_MIN)
      } else {
        this.countdownMin = 0
      }
    }, Constants.DELAY_TIME_1000)
  }

  @Builder
  waitPayBuilder() {
    Column() {
      Text($r('app.string.to_be_paid'))
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Text() {
        Span($r('app.string.please')).fontColor($r('sys.color.font_secondary'))
        if (this.countdownMin) {
          Span($r('app.string.minute_params', `${this.countdownMin}`)).fontColor('#FF0000')
        }
        Span($r('app.string.second_params', `${this.countdownSec % 60}`)).fontColor('#FF0000')
        Span($r('app.string.timeout_cancel')).fontColor($r('sys.color.font_secondary'))
      }.fontSize(14).margin({ top: 8, bottom: 16 })

      Row({ space: 12 }) {
        Text($r('app.string.pay'))
          .fontSize(12)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#486602')
          .borderRadius(23)
          .padding({
            left: 16,
            right: 16,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.showPaySheet()
          })
        Text($r('app.string.cancel'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(16)
          .borderRadius(23)
          .borderWidth(1)
          .borderColor('#4D000000')
          .padding({
            left: 16,
            right: 16,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.cancelOrderCb()
          })
      }.width('100%').justifyContent(FlexAlign.Center)
    }
    .cardStyle()
    .width('100%')

  }

  @Builder
  makingBuilder(title: ResourceStr, isCompleted: boolean = false) {
    Column() {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      if (this.orderInfo.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {
        if (isCompleted) {
          Row({ space: 12 }) {
            Text($r('app.string.one_more_order'))
              .fontSize(12)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#486602')
              .borderRadius(23)
              .padding({
                left: 16,
                right: 16,
                top: 4,
                bottom: 4,
              })
              .onClick(() => {
                this.oneMoreOrder()
              })
          }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 12 })
        }
        Row() {
          Text($r('app.string.order_id_prefix'))
            .fontSize(14)
            .fontColor($r('sys.color.black'))
          Text(this.orderInfo.orderNum)
            .fontSize(14)
            .fontColor($r('sys.color.black'))
          Image($r('app.media.ic_copy')).width(16).margin({ left: 10 })
        }
        .borderRadius(12)
        .padding({ left: 12, right: 12 })
        .justifyContent(FlexAlign.Center)
        .margin({ top: 15 })
        .height(32)
        .backgroundColor('#0D000000')
        .onClick(() => {
          copyString(this.orderInfo.orderNum)
        })
      } else {
        Row() {
          Text(this.orderInfo.oid)
            .fontSize(24)
            .fontColor($r('sys.color.black'))
            .height(30)
          Text($r('app.string.pick_order_id'))
            .fontSize(14)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundImage($r('app.media.bg_pick_num'))
            .backgroundImageSize({ width: 82, height: 30 })
            .height(30)
            .padding({ left: 20, right: 20 })
            .margin({ left: 4 })
        }.width('100%').justifyContent(FlexAlign.Center).height(30).margin({ top: 15 })
      }

    }
    .cardStyle()
    .width('100%')
  }

  @Builder
  deliveringBuilder() {
    Column() {
      Text($r('app.string.delivering_title'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        Text($r('app.string.estimated_delivery_pre'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Text(this.estimatedTime)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#486602')
        Text($r('app.string.estimated_delivery_post'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 15 })

      Row() {
        Text($r('app.string.order_id_prefix'))
          .fontSize(14)
          .fontColor($r('sys.color.black'))
        Text(this.orderInfo.orderNum)
          .fontSize(14)
          .fontColor($r('sys.color.black'))
        Image($r('app.media.ic_copy')).width(16).margin({ left: 10 })
      }
      .justifyContent(FlexAlign.Center)
      .margin({ top: 15 })
      .height(32)
      .borderRadius(12)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#0D000000')
      .onClick(() => {
        copyString(this.orderInfo.orderNum)
      })
    }
    .cardStyle()
    .width('100%')
  }

  @Builder
  canceledBuilder() {
    Column() {
      Text($r('app.string.canceled')).fontSize(20).fontWeight(500).fontColor($r('sys.color.font_primary'))

      Text($r('app.string.use_close_order'))
        .fontSize(10)
        .fontWeight(400)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 15 })
    }.cardStyle()
    .width('100%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }

  build() {
    Column() {
      if (this.orderState === OrderStateEnum.TO_BE_PAID) {
        this.waitPayBuilder()
      } else if (this.orderState === OrderStateEnum.MAKING) {
        this.makingBuilder($r('app.string.making'))
      } else if (this.orderState === OrderStateEnum.DELIVERING) {
        this.deliveringBuilder()
      } else if (this.orderState === OrderStateEnum.COMPLETED) {
        this.makingBuilder($r('app.string.order_completed'), true)
      } else if (this.orderState === OrderStateEnum.CANCELED) {
        this.canceledBuilder()
      }
    }.margin({ top: 12 })
  }
}