import {
  CommonUrl,
  Constants,
  copyString,
  DnState,
  OrderDetailRouter,
  RouterMap,
  RouterModule,
  StoreInfoModel,
  StoreType,
} from 'common/Index'
import { common } from '@kit.AbilityKit'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { BusinessError } from '@kit.BasicServicesKit'
import { callTelSheetBuilder, paySheetBuilder } from 'base_ui'
import { HttpCode, OrderGoodsResp } from 'network'
import * as API from '../api/Index'
import { MyOrderInfo } from '../models/Index'

@ComponentV2
export struct OrderCard {
  @Param @Require orderItem: MyOrderInfo;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Consumer('currentIndex') currentIndex: number = 0
  @Local callTelSheet: boolean = false
  @Local paySheetFlag: boolean = false
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Event getMyOrder: () => void = () => {

  }

  @Computed
  get orderTypeStr() {
    if (this.orderItem.order.state === DnState.TO_BE_PAID) {
      return $r('app.string.to_be_paid')
    } else if (this.orderItem.order.state === DnState.COMPLETED) {
      return $r('app.string.completed')
    } else {
      return $r('app.string.canceled')
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Column() {
        // 店铺名称
        Row() {
          Column() {
            Row() {
              Text(this.storeModel.storeInfo.name)
                .fontColor($r('sys.color.font_primary'))
                .fontSize($r('sys.float.Body_L'))
              Image($r('app.media.right_arrow')).width(16)
            }

            // 订单时间
            Text(this.orderItem.order?.time)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 2 })
          }.alignItems(HorizontalAlign.Start)


          Text(this.orderTypeStr)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.orderItem.order?.state === DnState.TO_BE_PAID ? $r('sys.color.multi_color_09') :
            $r('sys.color.font_secondary'))
            .width(72)
            .height(28)
            .textAlign(TextAlign.Center)
            .borderRadius(8)
            .backgroundColor(this.orderItem.order?.state === DnState.TO_BE_PAID ? 'rgba(237,111,33,0.2) ' :
            $r('sys.color.background_secondary'))
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)


        // 订单商品
        Row() {
          List({ space: 8 }) {
            ForEach(this.orderItem.goods, (item: OrderGoodsResp) => {
              ListItem() {
                Row() {
                  Image(`${CommonUrl.CLOUD_STORAGE_URL}${item.logo}`)
                    .width(52)
                    .height(52)
                    .borderRadius(8)
                  if (this.orderItem.goods?.length === 1) {
                    Column() {
                      Text(item.name).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'))
                      Text(item.spec?.split(',').join(' | '))
                        .fontSize($r('sys.float.Caption_M'))
                        .fontColor($r('sys.color.font_secondary'))
                        .margin({ top: 4 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis });
                    }.height(52).margin({ left: 8 }).alignItems(HorizontalAlign.Start)
                  }
                }

              }
            }, (item: OrderGoodsResp) => JSON.stringify(item))
          }
          .listDirection(Axis.Horizontal)
          .scrollBar(BarState.Off)
          .layoutWeight(1)

          Column() {
            Text() {
              Span($r('app.string.currency_symbol')).fontSize($r('sys.float.Caption_S'))
              Span(`${Number(this.orderItem.order?.money)}`).fontSize($r('sys.float.Body_M'))
            }
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)

            Text($r('app.string.total_num', `${this.orderItem.goods.length}`))
              .fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Caption_M'))
          }
          .width(82)
          .height(82)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.End)
        }
        .width(Constants.FULL_SIZE)
      }.alignItems(HorizontalAlign.Start)
      .onClick(() => {
        RouterModule.push(RouterMap.ORDER_DETAIL_PAGE,
          { orderId: this.orderItem.order?.id } as OrderDetailRouter, (popInfo) => {
            this.currentIndex = popInfo.result as number
          })
      })

      // 订单号
      Row() {
        Text($r('app.string.order_id_label', `${this.orderItem.order?.orderNum}`))
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
        Image($r('app.media.copy'))
          .width(16)
          .height(16)
          .margin({ left: 4 })
          .onClick(() => {
            copyString(this.orderItem.order?.orderNum ?? '')
          })
      }
      .padding(4)
      .width(Constants.FULL_SIZE)
      .borderRadius(4)
      .backgroundColor($r('sys.color.background_secondary'))

      Row() {
        if (this.storeModel.storeType === StoreType.PICK_NUM_TYPE &&
          this.orderItem.order?.state === DnState.COMPLETED) {
          Text() {
            Span($r('app.string.pick_good_id'))
            Span(`${this.orderItem.order?.oid}`)
          }.fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'))
        }
        // 订单操作按钮
        Row({ space: 8 }) {
          if (this.orderItem.order?.state === DnState.TO_BE_PAID) {
            Text($r('app.string.pay'))
              .border({
                width: 1,
                color: $r('sys.color.multi_color_09'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.multi_color_09'))
              .borderRadius(14)
              .onClick(() => {
                this.paySheetFlag = true
              })
              .bindSheet($$this.paySheetFlag,
                paySheetBuilder(Number(this.orderItem.order?.money ?? 0), (flag: boolean) => {
                  if (flag) {
                    this.confirmOrder()
                  }
                  this.paySheetFlag = false
                }), {
                  height: 397,
                  blurStyle: BlurStyle.Thick,
                  showClose: false,
                })
            Text($r('app.string.add_good'))
              .border({
                width: 1,
                color: $r('sys.color.multi_color_09'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.multi_color_09'))
              .borderRadius(14)
              .onClick(() => {
                if (this.orderItem.order?.id) {
                  API.addGoods(this.orderItem.order.id).then((resp: number) => {
                    if (resp === 1) {
                      RouterModule.replace(RouterMap.HOME_PAGE)
                    } else if (resp === 2) {
                      promptAction.showToast({ message: $r('app.string.order_statue_error') })
                      this.getMyOrder()
                    }
                  })
                } else {
                  promptAction.showToast({ message: $r('app.string.order_not_exist') })
                }
              })
            Text($r('app.string.cancel'))
              .border({
                width: 1,
                color: $r('sys.color.font_secondary'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.font_secondary'))
              .borderRadius(14)
              .onClick(() => {
                API.cancelOrder(this.orderItem.order?.id || '').then((resp: number) => {
                  let msg: Resource = $r('app.string.cancel_success')
                  if (resp === 1) {
                    this.getMyOrder()
                  } else if (resp === HttpCode.STATUE_ERROR) {
                    promptAction.showToast({ message: $r('app.string.order_statue_error') })
                    this.getMyOrder()
                    return
                  } else {
                    msg = $r('app.string.cancel_failed')
                  }
                  promptAction.showToast({ message: msg })
                })

              })
          } else if (this.orderItem.order?.state === DnState.COMPLETED) {
            Text($r('app.string.delete_order'))
              .border({
                width: 1,
                color: $r('sys.color.font_secondary'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.font_secondary'))
              .borderRadius(14)
              .onClick(() => {

                promptAction.showDialog({
                  title: $r('app.string.delete_order'),
                  message: $r('app.string.delete_confirm'),
                  buttons: [
                    {
                      text: $r('app.string.cancel'),
                      color: $r('sys.color.font_primary'),
                    },
                    {
                      text: $r('app.string.confirm'),
                      color: $r('sys.color.multi_color_09'),
                    },
                  ],
                }, (err, data) => {
                  if (err) {
                    console.error('showDialog err: ' + err);
                    return;
                  }
                  if (data.index === 1) {
                    if (this.orderItem.order?.id) {
                      API.deleteOrder(this.orderItem.order.id).then(() => {
                        this.getMyOrder()
                      })
                    } else {
                      promptAction.showToast({ message: $r('app.string.order_not_exist') })
                    }
                  }
                  console.info('showDialog success callback, click button: ' + data.index);
                });

              })
            Text($r('app.string.one_more_order'))
              .border({
                width: 1,
                color: $r('sys.color.multi_color_09'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.multi_color_09'))
              .borderRadius(14)
              .onClick(() => {
                this.currentIndex = 0
              })
          } else {
            Text($r('app.string.contact_store'))
              .border({
                width: 1,
                color: $r('sys.color.multi_color_09'),
              })
              .height(28)
              .width(72)
              .fontSize($r('sys.float.Body_M'))
              .textAlign(TextAlign.Center)
              .fontColor($r('sys.color.multi_color_09'))
              .borderRadius(14)
              .onClick(() => {
                this.callTelSheet = true
              })
              .bindSheet($$this.callTelSheet, callTelSheetBuilder(this.storeModel.storeInfo.tel!, () => {
                this.callTelSheet = false
              }), {
                height: 309,
                blurStyle: BlurStyle.Thick,
                showClose: false,
              });
          }
        }.layoutWeight(1).justifyContent(FlexAlign.End)
      }
      .width(Constants.FULL_SIZE)
      .margin({ top: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(Constants.FULL_SIZE)
    .margin({ left: 12, right: 12 })
    .constraintSize({ maxWidth: Constants.FULL_SIZE })
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
  }

  confirmOrder() {
    // 拉华为支付
    API.getHuaweiPayInfo(this.orderItem.order?.id ?? '').then((resp: number) => {
      if (resp === 1) {
        promptAction.showToast({ message: $r('app.string.pay_success') })
        this.getMyOrder()
      } else if (resp === HttpCode.STATUE_ERROR) {
        promptAction.showToast({ message: $r('app.string.order_statue_error') })
        this.getMyOrder()
      } else {
        promptAction.showToast({ message: $r('app.string.pay_failed') })
      }
    }).catch((e: BusinessError) => {
      console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.pay_failed_msg', JSON.stringify(e)) })
    })
  }
}

