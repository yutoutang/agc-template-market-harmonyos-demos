import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { AddressUtils, CarGoodsInfo, CouponItem, SubmitOrderItem } from 'lib_takeaway_api';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';
import { NavHeaderBar } from 'lib_widget';
import { buildSubmitOrderGoodsCard } from '../components/OrderInfoCard';
import { OrderSubmitVM } from '../viewModels/OrderSubmitVM';
import { builderSelectAddress, CommonTextInputBuilder, SelectDeliveryTimeBuilder } from 'lib_native_components';
import { RECEIVING_METHOD_LIST } from '../common/Constants';
import { promptAction } from '@kit.ArkUI';
import { SelectCouponBuilder } from 'business_coupons';

import { paymentChannelSheet } from '../components/PaymentChannelSheet';
import { ChannelType } from 'aggregated_payment';
import { StoreMapInfo } from 'module_store_map';

@Builder
export function OrderSubmitBuilder() {
  OrderSubmitPage()
}

@ComponentV2
struct OrderSubmitPage {
  @Local vm: OrderSubmitVM = new OrderSubmitVM();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '立即下单',
        onBack: () => {
          RouterUtils.pop(1)
        },
      })
      Column({ space: 8 }) {
        // 配送方式和配送信息
        Column() {
          // 配送方式切换
          Stack() {
            Image(this.vm.receivingMethod === 0 ? $r('app.media.group_takeout') : $r('app.media.group_pickup'))
              .width(CommonConstants.FULL_PERCENT)
              .objectFit(ImageFit.Cover)
            Row() {
              ForEach(RECEIVING_METHOD_LIST, (item: string, index: number) => {
                Column() {
                  // 外卖
                  Text(item)
                    .fontSize(16)
                    .fontWeight(600)
                    .lineHeight(22)
                    .textAlign(TextAlign.Center)
                    .fontColor(this.vm.receivingMethod === index ? $r('app.color.orange_yellow') : '#777777')
                  Row() {
                  }.width(15).height(2).backgroundColor(this.vm.receivingMethod === index ? $r('app.color.orange_yellow') : '#777777')
                  .visibility(this.vm.receivingMethod === index ? Visibility.Visible : Visibility.None)
                }
                .height(CommonConstants.FULL_PERCENT)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .width(CommonConstants.HALF_PERCENT)
                .onClick(() => {
                  this.vm.receivingMethod = index
                  if (index === 1) {
                    // 自取
                    this.vm.payMoney = this.vm.payMoney - this.vm.deliveryFee
                    this.vm.address = this.vm.storeInfo?.address || ''
                    this.vm.receivingMethod = 1
                  } else {
                    this.vm.payMoney = this.vm.payMoney + this.vm.deliveryFee
                    this.vm.address = ((this.vm.addressInfo?.province || '') + (this.vm.addressInfo?.city ||
                      '') + (this.vm.addressInfo?.area || '') + (this.vm.addressInfo?.detailAddress || '')) || ''
                    this.vm.receivingMethod = 0
                  }
                })
              }, (item: string, index: number) => index + '__' + item)
            }
            .width(CommonConstants.FULL_PERCENT)
          }
          .height(44)

          // 配送信息
          Column() {
            // 地址
            Row() {
              Text(this.vm.address ? this.vm.address : '请选择地址')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .lineHeight(22)
                .fontColor('#333333')
                .textAlign(TextAlign.Start)
                .margin({
                  right: 12
                })
                .layoutWeight(1)
              Image($r('app.media.ic_right'))
                .height(24)
                .objectFit(ImageFit.Cover)

            }
            .padding(10)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Top)
            .onClick(() => {
              if (this.vm.receivingMethod === 0) {
                // 自取切换收获地址
                this.vm.isShowAddress = true
              } else {
                // 外卖展示地图组件
                RouterUtils.pushPathByName(RouterMap.ORDER_MAP, {
                  shopName: this.vm.storeInfo?.name,
                  latitude: this.vm.storeInfo?.latitude,
                  longitude: this.vm.storeInfo?.longitude,
                  address: this.vm.address
                } as StoreMapInfo)
              }
            })
            .bindSheet(this.vm.isShowAddress, builderSelectAddress(
              this.vm.addressInfo?.id || 0,
              (address: IAddrInfo) => {
                this.vm.addressInfo = address
                this.vm.name = address.name
                this.vm.phone = address.cellphone
                this.vm.address = ((address.province || '') + (address.city || '') + (address.area || '') +
                  (address.detailAddress || ''))
                this.vm.isShowAddress = false
              }
            ),
              {
                title: { title: '选择地址' },
                height: SheetSize.MEDIUM,
                preferType: SheetType.CENTER,
                showClose: true,
                keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
                onWillDismiss: () => {
                  this.vm.isShowAddress = false
                }
              })

            // 收货人信息
            Row() {
              Text() {
                Span(this.vm.name + '  ')
                Span(AddressUtils.encryptPhoneNo(this.vm.phone))
              }
              .fontSize(14)
              .fontWeight(400)
              .fontColor('#888888')
              .textAlign(TextAlign.Start)
              .visibility(this.vm.receivingMethod === 0 ? Visibility.Visible : Visibility.None)

              Image($r('app.media.local_fill'))
                .width(18)
                .objectFit(ImageFit.Cover)
                .visibility(this.vm.receivingMethod === 1 ? Visibility.Visible : Visibility.None)
                .margin({
                  right: 8
                })
              Text(`距您${this.vm.distance}km`)
                .fontSize(14)
                .fontWeight(400)
                .fontColor('#888888')
                .textAlign(TextAlign.Start)
                .visibility(this.vm.receivingMethod === 1 ? Visibility.Visible : Visibility.None)

            }
            .padding(10)
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.Start)

            Divider()

            // 配送时间
            Row() {
              Text(this.vm.sendTime ? this.vm.sendTime : '立即配送')
                .fontSize(14)
                .fontWeight(400)
                .fontColor($r('app.color.orange_yellow'))
              Image($r('app.media.ic_right'))
                .height(24)
                .objectFit(ImageFit.Cover)
            }
            .height(36)
            .padding({
              left: 10,
              right: 10
            })
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .visibility(this.vm.receivingMethod === 0 ? Visibility.Visible : Visibility.None)
            .onClick(() => {
              this.vm.isShowDeliveryTime = true
            })
            .bindSheet(this.vm.isShowDeliveryTime,
              SelectDeliveryTimeBuilder(this.vm.sendTime, (deliveryTime: string) => {
                this.vm.sendTime = deliveryTime
                this.vm.isShowDeliveryTime = false
              }), {
                title: { title: '选择配送时间' },
                height: SheetSize.MEDIUM,
                preferType: SheetType.CENTER,
                showClose: true,
                keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
                onWillDismiss: () => {
                  this.vm.isShowDeliveryTime = false
                }
              })

          }
          // .padding(10)
          .width(CommonConstants.FULL_WIDTH)

        }
        .width(CommonConstants.FULL_WIDTH)
        .borderRadius(8)
        .backgroundColor($r('sys.color.comp_background_list_card'))

        Scroll() {
          Column() {
            // 下单商品列表
            Column({ space: 10 }) {
              Text(this.vm.storeInfo?.name)
                .fontSize(16)
                .fontWeight(600)
                .lineHeight(22)
                .fontColor('#333333')
              Divider()

              ForEach(this.vm.goodsInfoList, (carGoodsInfo: CarGoodsInfo) => {
                buildSubmitOrderGoodsCard(carGoodsInfo)
              }, (item: CarGoodsInfo, index: number) => index + '__' + item.id)

              // 配送费
              Row() {
                Text('配送费')
                  .fontColor('#121212')
                  .fontSize(16)
                  .fontWeight(500);
                Text() {
                  Span($r('app.string.currency_symbol'))
                    .fontSize(12)
                  Span(`${this.vm.storeInfo?.deliveryFee}`)
                    .fontSize(16)
                }
                .fontColor('#121212')
                .fontWeight(500)
                .margin({
                  right: 8
                })
              }
              .width(CommonConstants.FULL_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)
              .visibility(this.vm.receivingMethod === 0 ? Visibility.Visible : Visibility.None)

              // 配送费
              Row() {
                Row() {
                  Text('红包')
                    .fontColor('#121212')
                    .fontSize(16)
                    .fontWeight(500);
                  if (this.vm.couponMoney > 0) {
                    Text() {
                      Span($r('app.string.sub_symbol'))
                        .fontSize(12)
                      Span(`${this.vm.couponMoney}`)
                        .fontSize(16)
                    }
                    .textAlign(TextAlign.Center)
                    .fontColor('#FF2D19')
                    .fontWeight(500)
                    .margin({
                      right: 6
                    })
                  } else {
                    Text('请选择红包')
                      .textAlign(TextAlign.Center)
                      .fontSize(12)
                      .fontColor('#909399')
                      .margin({
                        right: 6
                      })
                  }

                }
                .layoutWeight(1)
                .justifyContent(FlexAlign.SpaceBetween)

                Image($r('app.media.ic_right'))
                  .height(24)
                  .objectFit(ImageFit.Cover)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                // 选择红包
                this.vm.isShowCoupon = true
              })
              .bindSheet(this.vm.isShowCoupon,
                SelectCouponBuilder(this.vm.couponId, this.vm.storeInfo?.type, this.vm.totalPrice + this.vm.deliveryFee,
                  (couponItem: CouponItem | undefined) => {
                    if (couponItem === undefined) {
                      this.vm.couponMoney = 0
                      this.vm.couponId = ''
                    } else {
                      this.vm.couponMoney = Number(couponItem.amountRule.discountAmount)
                      this.vm.couponId = couponItem.couponID
                    }
                    if (this.vm.receivingMethod === 0) {
                      this.vm.payMoney = this.vm.totalPrice + this.vm.deliveryFee - this.vm.couponMoney
                    } else {
                      this.vm.payMoney = this.vm.totalPrice - this.vm.couponMoney
                    }
                    this.vm.isShowCoupon = false
                  }), {
                  title: { title: '选择红包' },
                  preferType: SheetType.CENTER,
                  height: SheetSize.MEDIUM,
                  showClose: true,
                  keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
                  onWillDismiss: () => {
                    this.vm.isShowCoupon = false
                  }
                })

              Divider()
              Row() {
                Text() {
                  Span($r('app.string.small_count'))
                    .fontColor('#555555')
                  Span($r('app.string.currency_symbol'))
                    .fontColor('#333333')
                  Span(`${this.vm.payMoney.toFixed(2)}`)
                    .fontSize(18)
                    .fontColor($r('sys.color.black'))
                }
                .fontWeight(500)
                .fontSize(12)
              }
              .width(CommonConstants.FULL_WIDTH)
              .justifyContent(FlexAlign.End)

            }
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .alignItems(HorizontalAlign.Start)
            .padding(10)
            .width(CommonConstants.FULL_WIDTH)
            .borderRadius(6)

            // 订单备注
            Row() {
              Row() {
                Text('订单备注')
                  .fontSize(16)
                  .fontColor('#121212')
                  .fontWeight(400)
                Text(this.vm.remark ? this.vm.remark : '口味、偏好')
                  .fontColor('#909399')
                  .fontSize(12)
                  .fontWeight(400)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.End)
                  .maxLines(1)
                  .width('74%')
              }
              .margin({
                right: 8
              })
              .justifyContent(FlexAlign.SpaceBetween)
              .layoutWeight(1)

              Image($r('app.media.ic_right'))
                .height(24)
                .objectFit(ImageFit.Cover)
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .borderRadius(6)
            .padding(10)
            .margin({
              top: 8
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .width(CommonConstants.FULL_WIDTH)
            .height(50)
            .onClick(() => {
              // 更新订单备注
              this.vm.isShowRemark = true
            })
            .bindSheet(this.vm.isShowRemark,
              CommonTextInputBuilder(this.vm.remark, '请输入口味偏好等要求', 50, (text: string) => {
                this.vm.remark = text
                this.vm.isShowRemark = false
              }), {
                title: { title: '订单备注' },
                preferType: SheetType.CENTER,
                height: SheetSize.MEDIUM,
                showClose: true,
                keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
                onWillDismiss: () => {
                  this.vm.isShowRemark = false
                }
              });
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .width(CommonConstants.FULL_WIDTH)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

      }
      .padding(10)
      .alignItems(HorizontalAlign.End)
      .layoutWeight(1)

      this.buildSubmitRow()

    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let param = context.pathInfo.param as SubmitOrderItem
      this.vm.initSubmitOrder(param as SubmitOrderItem)

    })
    .linearGradient({
      colors: [['#FEA338', 0], ['#F1F3F5', 0.5]],
    })
  }

  @Builder
  buildSubmitRow() {
    // 购物车
    Row() {
      Column() {
        Text() {
          Span($r('app.string.currency_symbol'))
            .fontSize(14)
          Span((this.vm.payMoney || 0).toFixed(2))
            .fontSize(22)
        }
        .fontColor('#121212')
        .fontWeight(500);
      }
      .height(44)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center);

      Button('确认支付')
        .width(100)
        .height(40)
        .linearGradient(
          { angle: 90, colors: [[$r('app.color.app_theme'), 1], ['#F1F3F5', 1]] }
        )
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .onClick(() => {
          this.vm.isShowPay = true
        })
        .bindSheet(this.vm.isShowPay, paymentChannelSheet(
          (this.vm.payMoney || 0).toFixed(2),
          (type: ChannelType) => {
            // 支付成功回调
            this.vm.createOrder(0, true, this.vm.receivingMethod)
            this.vm.isShowPay = false
            promptAction.showToast({ message: '支付成功!' })
            RouterUtils.pushPathByName(RouterMap.ORDER_LIST)
          },
          (type: ChannelType) => {
            // 支付失败回调
            this.vm.createOrder(0, true, this.vm.receivingMethod)
            this.vm.isShowPay = false
            promptAction.showToast({ message: '支付成功!' })
            RouterUtils.pushPathByName(RouterMap.ORDER_LIST)
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
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 8,
      left: 16,
      right: 15,
      bottom: this.vm.windowModel.windowBottomPadding,
    })
    .border({
      width: {
        top: 0.5
      },
      color: '#EBEBEB'
    })
    .width(CommonConstants.FULL_WIDTH)
    .backgroundColor($r('app.color.font_color_level1_invert'))
  }
}
