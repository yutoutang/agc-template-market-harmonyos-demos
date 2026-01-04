import { CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common';
import { CarGoodsInfo, OrderInfo, OrderItem } from 'lib_takeaway_api';
import { OrderActionMap, OrderShipmentMap, OrderStatusMap } from '../common/Enums';
import { MyButtonModifier, OrderAction } from '../common/Types';
import { OrderUtil } from '../utils/OrderUtil';
import { OrderListPageVM } from '../viewModels/OrderListPageVM';
import { OrderCountdown } from './OrderCountdown';

/**
 * 订单中单个商品信息卡片
 * @param skuInfo
 */
@Builder
export function buildOrderBaseInfoCard(carGoodsInfo: CarGoodsInfo) {
  Row() {
    Image(`https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/${carGoodsInfo.logo}`)
      .width(60)
      .height(60)
      .borderRadius($r('app.float.border_radius_s'))
      .margin({ right: $r('app.float.space_m') })
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        Text(carGoodsInfo.name)
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('app.float.font_size_14'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (carGoodsInfo.isMust) {
          Text('必选')
            .fontSize(10)
            .fontWeight(500)
            .fontColor($r('sys.color.comp_background_list_card'))
            .backgroundColor($r('app.color.app_theme'))
            .width(26)
            .margin({ left: 6 })
            .textAlign(TextAlign.Center)
        }
      }

      Text(carGoodsInfo.spec)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)

    Column({ space: 4 }) {
      Text('¥' + carGoodsInfo.money)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
      Text('x' + carGoodsInfo.num)
        .fontSize($r('app.float.font_size_14'))
        .fontColor($r('app.color.font_color_level2'))
    }
    .width(48)
    .alignItems(HorizontalAlign.End)
  }
  .alignItems(VerticalAlign.Top)
  .width($r('app.string.size_percent_full'))
}

/**
 * 订单操作按钮列表
 * @param orderInfo
 * @param buttonSize
 */
@Builder
export function buildButtonList(orderInfo: OrderInfo, buttonSize: ControlSize = ControlSize.NORMAL, vm: OrderListPageVM,
  callback?: (action: OrderActionMap) => void) {
  Row({ space: buttonSize === ControlSize.NORMAL ? 12 : 8 }) {
    if (orderInfo.status === OrderStatusMap.PENDING_PAYMENT) {
      OrderCountdown({ vm: vm, orderInfo: orderInfo })
    }
    ForEach(OrderUtil.getButtonList(orderInfo.status), (action: OrderAction) => {
      if (buttonSize === ControlSize.SMALL || (buttonSize === ControlSize.NORMAL && !action.enableHide)) {
        if (!(orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP &&
          action.actionType === OrderActionMap.UPDATE_ADDRESS)) {
          Button(action.label)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .attributeModifier(new MyButtonModifier(action.style, buttonSize, action.fountColor, action.borderColor,
              action.backgroundColor))
            .onClick(() => {
              callback?.(action.actionType)
            })
        }
      }
    }, (action: OrderAction, index: number) => index + action.label)
  }
  .width($r('app.string.size_percent_full'))
  .justifyContent(FlexAlign.End)
}

/**
 * 订单列表页卡片
 * @param order
 */
@Builder
export function buildOrderInfoCard(order: OrderItem) {
  Column({ space: 12 }) {
    ForEach(order.carGoodsInfo, (carGoodsInfo: CarGoodsInfo) => {
      Column() {
        buildOrderBaseInfoCard(carGoodsInfo)
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.ORDER_INFO_PAGE, order.orderInfo.orderNo)
      })
    }, (item: CarGoodsInfo, index: number) => index + '__' + item.id)
    Row() {
      Text(TimeUtils.formatDate(order.orderInfo.orderTime, 'YYYY.MM.DD HH:mm'))
        .textAlign(TextAlign.End)
        .fontSize($r('app.float.font_size_12'))
        .fontColor($r('app.color.font_color_level3'))
      Text('¥' + order.orderInfo.finalPrice)
        .fontSize($r('app.float.font_size_16'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(FontWeight.Medium)
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .margin({ bottom: $r('app.float.space_l') })

  if (order.logisticInfo.length) {
  }
}

@Builder
export function buildSubmitOrderGoodsCard(carGoodsInfo: CarGoodsInfo) {
  Row() {
    Image(`https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/${carGoodsInfo.logo}`)
      .width(60)
      .height(60)
      .borderRadius(8)
      .margin({
        right: 12
      })
    Column() {
      Row() {
        Row() {
          Text(carGoodsInfo.name)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#121212')
          if (carGoodsInfo.isMust) {
            Text('必选')
              .fontSize(10)
              .fontWeight(500)
              .fontColor($r('sys.color.comp_background_list_card'))
              .backgroundColor($r('app.color.app_theme'))
              .width(26)
              .margin({ left: 6 })
              .textAlign(TextAlign.Center)
          }
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Text() {
          Span($r('app.string.currency_symbol'))
            .fontColor('#121212')
            .fontWeight(500)
            .fontSize(12)
          Span(`${carGoodsInfo.money}`)
            .fontColor('#121212')
            .fontWeight(500)
            .fontSize(16)
        }.margin({
          right: 8
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text(carGoodsInfo.spec)
          .fontSize(12)
          .fontWeight(400)
          .fontColor('#909399')
        // 非编辑状态下
        Text(`x${carGoodsInfo.num}`)
          .fontSize(12)
          .fontWeight(400)
          .fontColor('#909399')
          .margin({
            right: 8
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(60)
    .layoutWeight(1)
    .padding({
      top: 8,
      bottom: 8,
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  .width(CommonConstants.FULL_PERCENT)
}

/**
 * 店铺订单页卡片
 */
@Builder
export function buildShopOrderInfoCard(order: OrderItem) {
  Row() {
    Text(order.storeInfo.name)
      .fontSize($r('app.float.font_size_16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.font_color_level1'));

    Image($r('app.media.ic_right'))
      .width($r('app.float.arrow_right_w'))
      .draggable(false)
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.STORE_PAGE, order.storeInfo.id)
      })

    Blank()
    Text(OrderUtil.getStatusLabel(order.orderInfo.status))
      .fontColor(getOrderStatusLabel(order.orderInfo.status))
      .fontSize($r('app.float.font_size_14'))
  }
  .width($r('app.string.size_percent_full'))
  .justifyContent(FlexAlign.SpaceBetween)

  Divider()
    .margin({ top: $r('app.float.space_m'), bottom: $r('app.float.space_m') })
    .color($r('sys.color.comp_divider'))
}

function getOrderStatusLabel(status: number): string | Resource {
  switch (status) {
    case OrderStatusMap.PENDING_PAYMENT:
      return '#FFFF2D19'
    case OrderStatusMap.PENDING_SHIPMENT:
    case OrderStatusMap.PENDING_RECEIPT:
      return '#FFF17D00'
    default:
      return $r('sys.color.black')
  }
}


