import { CommonLoading, CommonScroll, ContainerColumn } from 'lib_widget'
import { DiscountItem, OrderInfo, OrderItem, OrderSkuItem } from 'lib_network'
import { CallButton } from 'lib_foundation';
import { OrderFormItem } from '../components/OrderFormItem'
import { buildButtonList, buildOrderBaseInfoCard } from '../components/OrderInfoCard'
import { formatFullDate } from '../utils'
import { OrderUtil } from '../utils/OrderUtil'
import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM'
import { buildAddressInfo } from '../components/AddressInfoCard';
import { OrderActionMap, OrderStatusMap } from '../common/Enums';

@Builder
export function buildOrderInfoPage() {
  OrderInfoPageNew()
}

@ComponentV2
export struct OrderInfoPageNew {
  vm: OrderInfoPageVM = new OrderInfoPageVM()

  build() {
    NavDestination() {
      CommonScroll({ bgColor: $r('app.color.background_color_grey') }) {
        if (this.vm.isLoading) {
          CommonLoading()
        } else {
          if (this.vm.orderItem) {
            Column() {
              this.buildStatusLabel(this.vm.orderItem.orderInfo)
              if (this.vm.orderItem.orderInfo.status !== OrderStatusMap.REFUNDED) {
                this.buildAddressCard()
              }
              this.buildOrderInfo(this.vm.orderItem)
            }
          }
        }
      }

      if (!this.vm.isLoading) {
        this.buildBottomButton()
      }

    }
    .title('订单详情')
    .onReady((context) => {
      const param = context.pathInfo.param as string | undefined
      if (param) {
        this.vm.getOrderItem(param)
      }
    })
  }

  @Builder
  buildStatusLabel(orderInfo: OrderInfo) {
    Column() {
      Text() {
        Span(OrderUtil.getStatusLabel(orderInfo.status))
        if (orderInfo.status === OrderStatusMap.REFUNDED) {
          Span(' ').letterSpacing(2)
          Span('¥').fontSize(16)
          Span(orderInfo.finalPrice.toString())
        }
      }
      .fontSize($r('app.float.font_size_24'))
      .fontColor($r('app.color.font_color_level1'))
      .fontWeight(FontWeight.Medium)

      if (orderInfo.status === OrderStatusMap.PENDING_PAYMENT) {
        Text() {
          Span('订单将在 ')
          Span(this.vm.countdown).fontColor($r('app.color.theme_color'))
          Span(' 后取消，请尽快支付')
        }
        .fontColor($r('app.color.font_color_level2'))
        .fontSize($r('app.float.font_size_12'))
        .margin({ top: $r('app.float.space_s') })
      }
    }
    .width($r('app.string.size_percent_full'))
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: $r('app.float.space_l'),
      bottom: $r('app.float.space_l'),
    })
  }

  @Builder
  buildAddressCard() {
    ContainerColumn() {
      buildAddressInfo(this.vm.orderItem!.orderInfo.addressInfo, this.vm.enableEditAddress, () => {
        this.vm.handleOrderItem(OrderActionMap.UPDATE_ADDRESS)
      })
    }
  }

  @Builder
  buildOrderInfo(orderItem: OrderItem) {
    ContainerColumn() {
      if (orderItem.orderInfo.status === OrderStatusMap.REFUNDED) {
        Column({ space: 12 }) {
          OrderFormItem({
            label: '退回华为支付',
            labelColor: $r('app.color.font_color_level1'),
            content: '¥' + orderItem.orderInfo.finalPrice,
          })

          ForEach(orderItem.orderInfo.discounts, (discount: DiscountItem) => {
            OrderFormItem({
              labelColor: $r('app.color.font_color_level1'),
              label: '退回优惠券包',
              content: '¥' + discount.discountPrice,
            })
          }, (discount: DiscountItem, index: number) => index + '_' + discount.type)
          Divider()
            .color($r('sys.color.comp_divider'))
            .margin({
              bottom: $r('app.float.space_l'),
            })
        }

      }
      Column({ space: 12 }) {
        ForEach(orderItem.skuInfo, (skuItem: OrderSkuItem) => {
          buildOrderBaseInfoCard(skuItem)
        }, (item: OrderSkuItem, index: number) => index + '__' + item.skuCode)
      }

      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({
          top: $r('app.float.space_l'),
          bottom: $r('app.float.space_l'),
        })
      Row() {
        Image($r('app.media.tel'))
          .width(16)
          .height(16)
          .margin({ right: $r('app.float.space_s') })
        CallButton() {
          Text('联系客服')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('sys.color.font_primary'))
        }
      }
    }

    ContainerColumn() {
      Column({ space: 16 }) {
        OrderFormItem({ label: '商品金额' }) {
          Text('¥' + orderItem.orderInfo.originalPrice)
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
        }

        OrderFormItem({ label: '优惠' }) {
          Text(`- ¥${(orderItem.orderInfo.finalPrice - orderItem.orderInfo.originalPrice).toFixed(2)}`)
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.theme_color'))
        }

        OrderFormItem({ label: '实付金额' }) {
          Text() {
            Span('¥').fontSize($r('app.float.font_size_12'))
            Span(orderItem.orderInfo.finalPrice.toString())
          }
          .fontSize($r('app.float.font_size_18'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
        }
      }
    }

    ContainerColumn({ title: '订单信息' }) {
      Column({ space: 16 }) {
        OrderFormItem({ label: '订单号码' }) {
          Text(orderItem.orderInfo.orderNo)
            .fontSize($r('app.float.font_size_12'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ right: $r('app.float.space_m') })
          Button('复制')
            .controlSize(ControlSize.SMALL)
            .width(44)
            .height(20)
            .fontSize($r('app.float.font_size_10'))
            .borderWidth(1)
            .borderColor($r('app.color.theme_color'))
            .fontColor($r('app.color.theme_color'))
            .backgroundColor($r('app.color.background_color_white'))
            .onClick(() => {
              OrderUtil.copyOrderNumber(orderItem.orderInfo.orderNo)
            })
        }

        OrderFormItem({ label: '下单时间', content: formatFullDate(new Date(orderItem.orderInfo.orderTime)) })
        OrderFormItem({
          label: '配送方式',
          content: OrderUtil.getReceiveMethodLabel(orderItem.orderInfo.receivingMethod),
        })
        OrderFormItem({ label: '用户备注', content: orderItem.orderInfo.remark ?? '' })
      }

    }

  }

  @Builder
  buildBottomButton() {
    Row() {
      if (this.vm.orderItem) {
        buildButtonList(this.vm.orderItem.orderInfo, ControlSize.NORMAL, (action) => {
          this.vm.handleOrderItem(action)
        })
      }
    }
    .width($r('app.string.size_percent_full'))
    .backgroundColor($r('app.color.background_color_white'))
    .padding({
      left: $r('app.float.space_m'),
      right: $r('app.float.space_m'),
      top: $r('app.float.space_l'),
    })
  }

  @Builder
  buildDivider() {
    Divider()
      .color($r('sys.color.comp_divider'))
      .margin({
        top: $r('app.float.space_l'),
        bottom: $r('app.float.space_l'),
      })
  }
}
