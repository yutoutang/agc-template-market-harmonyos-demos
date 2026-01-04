import { buildButtonList, buildOrderBaseInfoCard, buildShopOrderInfoCard } from '../components/OrderInfoCard';
import { formatFullDate } from '../utils/FormatUtils';
import { OrderUtil } from '../utils/OrderUtil';
import { OrderStatusMap } from '../common/Enums';
import { CommonLoading, CommonScroll, ContainerColumn, NavHeaderBar } from 'lib_widget';
import { CarGoodsInfo, DiscountItem, OrderInfo, OrderItem, OrderServiceApi } from 'lib_takeaway_api';
import { OrderFormItem } from '../components/OrderFormItem';
import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM';
import { promptAction } from '@kit.ArkUI';
import { RouterMap, RouterUtils } from 'lib_common';
import { OrderListPageVM } from '../viewModels/OrderListPageVM';

import { paymentChannelSheet } from '../components/PaymentChannelSheet';
import { ChannelType } from 'aggregated_payment';

@Builder
export function buildOrderInfoPage() {
  OrderInfoPageNew()
}

@ComponentV2
export struct OrderInfoPageNew {
  vm: OrderInfoPageVM = new OrderInfoPageVM()

  @Monitor('vm.countdown')
  countdownPop() {
    //倒计时结束退回上个页面
    if (this.vm.countdown === '--') {
      RouterUtils.pop()
    }
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '订单详情',
        bgColor: $r('app.color.background_color_white')
      })

      CommonScroll({ bgColor: $r('app.color.background_color_grey') }) {
        if (this.vm.isLoading) {
          CommonLoading()
        } else {
          if (this.vm.orderItem) {
            Column() {
              this.buildStatusLabel(this.vm.orderItem.orderInfo)
              this.buildOrderInfo(this.vm.orderItem)
            }
          }
        }
      }

      if (!this.vm.isLoading) {
        this.buildBottomButton()
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .padding({ bottom: $r('app.float.space_l') })
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
  buildOrderInfo(orderItem: OrderItem) {
    ContainerColumn() {
      buildShopOrderInfoCard(orderItem)
      if (orderItem.orderInfo.status === OrderStatusMap.REFUNDED) {
        Column({ space: 12 }) {
          OrderFormItem({
            label: '原路退回',
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
        ForEach(orderItem.carGoodsInfo, (carGoodsInfo: CarGoodsInfo) => {
          buildOrderBaseInfoCard(carGoodsInfo)
        }, (item: CarGoodsInfo, index: number) => index + '__' + item.id)
      }

      Divider()
        .color($r('sys.color.comp_divider'))
        .margin({
          top: $r('app.float.space_l'),
          bottom: $r('app.float.space_l'),
        })
      Column({ space: 16 }) {
        if (orderItem.orderInfo.receivingMethod === 0) {
          OrderFormItem({ label: '配送费', contentFontSize: $r('app.float.font_size_14') }) {
            Text('¥' + orderItem.orderInfo.deliveryFee)
              .fontSize($r('app.float.font_size_14'))
          }
        }

        OrderFormItem({ label: '红包', contentFontSize: $r('app.float.font_size_14') }) {
          Text(`¥${(orderItem.orderInfo.finalPrice - orderItem.orderInfo.originalPrice).toFixed(2)}`)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.theme_color'))
        }

        Divider()
          .color($r('sys.color.comp_divider'))
        OrderFormItem() {
          Text() {
            Span('小计：').fontSize($r('app.float.font_size_14'))
            Span('¥').fontSize($r('app.float.font_size_14'))
            Span(orderItem.orderInfo.finalPrice.toFixed(2).toString())
          }
          .fontSize($r('app.float.font_size_18'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
        }
      }

    }

    ContainerColumn({ title: '配送信息' }) {
      Column({ space: 16 }) {
        if (orderItem.orderInfo.receivingMethod === 0) {

          OrderFormItem({
            label: '配送时间',
            content: orderItem.orderInfo.deliveryTime.includes('今天') ?
              `${new Date().getFullYear()}年${new Date().getMonth() + 1}月${new Date().getDate()}日` +
              orderItem.orderInfo.deliveryTime.replace('今天', '') :
              `${new Date().getFullYear()}年${new Date().getMonth() + 1}月${new Date().getDate() + 1}日` +
              orderItem.orderInfo.deliveryTime.replace('明天', ''),
            contentColor: $r('app.color.font_color_level2'),
            contentFontSize: $r('app.float.font_size_14'),
          })
          Divider()
            .color($r('sys.color.comp_divider'))
          OrderFormItem({
            label: '收货地址',
            contentList: [orderItem.orderInfo.addressInfo ?
              (orderItem.orderInfo.addressInfo?.area + orderItem.orderInfo.addressInfo?.city +
                orderItem.orderInfo.addressInfo?.detailAddress) : '',
              orderItem.orderInfo.addressInfo ?
                (orderItem.orderInfo.addressInfo?.name + ' ' +
                orderItem.orderInfo.addressInfo.cellphone.substring(0, 3) + '****' +
                orderItem.orderInfo.addressInfo.cellphone.substring(7)
                ) : ''
            ],
            contentColor: $r('app.color.font_color_level2'),
            contentFontSize: $r('app.float.font_size_14'),
          })

        } else {
          OrderFormItem({
            label: '配送时间',
            content: '自取',
            contentColor: $r('app.color.font_color_level2'),
            contentFontSize: $r('app.float.font_size_14'),
          })
        }
        Divider()
          .color($r('sys.color.comp_divider'))
        OrderFormItem({
          label: '备注',
          content: orderItem.orderInfo.remark ?? '',
          contentColor: $r('app.color.font_color_level2'),
          contentFontSize: $r('app.float.font_size_14'),
        })
      }
    }

    ContainerColumn({ title: '订单信息' }) {
      Column({ space: 16 }) {
        OrderFormItem({
          label: '订单号码',
          contentColor: $r('app.color.font_color_level2'),
          contentFontSize: $r('app.float.font_size_14'),
        }) {
          Text(orderItem.orderInfo.orderNo)
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
            .margin({ right: $r('app.float.space_m') })
          Button('复制')
            .controlSize(ControlSize.SMALL)
            .width(50)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .borderWidth(1)
            .borderColor($r('sys.color.font_tertiary'))
            .fontColor($r('sys.color.font_tertiary'))
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor($r('app.color.background_color_white'))
            .onClick(() => {
              OrderUtil.copyOrderNumber(orderItem.orderInfo.orderNo)
            })
        }

        Divider()
          .color($r('sys.color.comp_divider'))
        OrderFormItem({
          label: '支付方式',
          content: orderItem.orderInfo.payModel,
          contentColor: $r('app.color.font_color_level2'),
          contentFontSize: $r('app.float.font_size_14'),
        })
        Divider()
          .color($r('sys.color.comp_divider'))
        OrderFormItem({
          label: '下单时间',
          content: formatFullDate(new Date(orderItem.orderInfo.orderTime)),
          contentColor: $r('app.color.font_color_level2'),
          contentFontSize: $r('app.float.font_size_14'),
        })

      }

    }
  }

  @Builder
  buildBottomButton() {
    Row() {
      if (this.vm.orderItem) {
        buildButtonList(this.vm.orderItem.orderInfo, ControlSize.NORMAL, new OrderListPageVM(), (action) => {
          this.vm.handleOrderItem(action)
        })
      }
    }
    .alignItems(VerticalAlign.Center)
    .width($r('app.string.size_percent_full'))
    .backgroundColor($r('app.color.background_color_white'))
    .padding({
      left: $r('app.float.space_m'),
      right: $r('app.float.space_m'),
      top: $r('app.float.space_m'),
      bottom: $r('app.float.space_m')
    })
    .bindSheet(this.vm.isShowPay, paymentChannelSheet(
      (this.vm.orderItem?.orderInfo.finalPrice || 0).toFixed(2),
      (type: ChannelType) => {
        // 支付成功回调
        OrderServiceApi.updateOrderStatus(this.vm.orderItem?.orderInfo.orderNo || '', OrderStatusMap.PENDING_SHIPMENT)
        this.vm.isShowPay = false
        promptAction.showToast({ message: '支付成功' })
        RouterUtils.replacePathByName(RouterMap.ORDER_LIST)
      },
      (type: ChannelType) => {
        // 支付失败回调
        OrderServiceApi.updateOrderStatus(this.vm.orderItem?.orderInfo.orderNo || '', OrderStatusMap.PENDING_SHIPMENT)
        this.vm.isShowPay = false
        promptAction.showToast({ message: '支付成功' })
        RouterUtils.replacePathByName(RouterMap.ORDER_LIST)
      }
    ),
      {
        height: '60%',
        preferType: SheetType.CENTER,
        title: { title: '确认支付' },
        onDisappear: () => {
          this.vm.isShowPay = false
        }
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
