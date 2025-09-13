/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { LengthMetrics } from '@kit.ArkUI';
import { CommonConstants, UIOrderPart, } from 'lib_foundation';
import { IServiceDetail, IServiceDetailItem } from 'module_base';
import { FormItem, FormType } from 'module_form';
import { TimeSelect } from 'module_time_select';
import { ServiceText } from '../components/ServiceText';
import { OrderVM } from '../viewmodel/OrderVM';

@Builder
export function OrderPageBuilder() {
  OrderPage()
}

@Extend(Column)
function cardContainer() {
  .width(CommonConstants.FULL_PERCENT)
  .padding(10)
  .borderRadius(8)
  .backgroundColor(Color.White)
}

@ComponentV2
export struct OrderPage {
  orderVM: OrderVM = OrderVM.instance(true);

  aboutToAppear(): void {
    const context = this.getUIContext();
    this.orderVM.init(context);
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 10 }) {
            this.CardCore()
            if (this.orderVM.showGoodCard()) {
              this.CardGood()
            }
            this.CardPay()
          }.width(CommonConstants.FULL_PERCENT)
        }
        .layoutWeight(1)
        .padding(10)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        this.BottomBar()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .title('下单', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  CardCore() {
    Column() {
      this.FormAddr()
      if (this.orderVM.showServiceSelect()) {
        Divider()
        this.SelectService()
      }

      if (this.orderVM.showTimeSelect()) {
        Divider()
        this.ServiceTime()
      }
    }
    .cardContainer()
  }

  @Builder
  CardGood() {
    Column() {
      UIOrderPart({ simpleGoodInfo: this.orderVM.goodInfo })
    }
    .cardContainer()
  }

  @Builder
  CardPay() {
    Column() {
      FormItem({
        param: {
          type: FormType.OTHER,
          label: '支付方式',
        },
      }) {
        Row({ space: 4 }) {
          Image($r('app.media.ic_huawei_pay')).width(16).height(16).borderRadius(4)
          Text('华为支付').fontSize(14)
        }
      }

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '备注',
          last: true,
        },
        value: this.orderVM.remark!!,
      })

    }
    .cardContainer()
  }

  @Builder
  BottomBar() {
    Row() {
      Text() {
        Span('￥').fontSize(12)
        Span(this.orderVM.getTotalCash()).fontSize(20)
      }
      .fontWeight(500)
      .fontColor($r('app.color.common_red'))

      Blank()
      Button() {
        Text('支付并预约')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(500)
          .fontColor($r('sys.color.font_on_primary'))
      }
      .backgroundColor($r('app.color.common_theme_color'))
      .padding({
        top: 9,
        bottom: 9,
        left: 16,
        right: 16
      })
      .onClick(() => {
        this.orderVM.onSubmit();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding(10)
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  FormAddr() {
    Row() {
      Image($r('app.media.ic_public_position')).width(14)
      Text(this.orderVM.getAddressName())
        .fontSize(14)
        .fontWeight(500)
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ left: 8, right: 16 })
      Image($r('app.media.ic_public_arrow_right')).width(12)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(this.orderVM.showServiceSelect() || this.orderVM.showTimeSelect() ? 48 : 24)
    .onClick(() => {
      this.orderVM.jumpAddressManage();
    })
  }

  @Builder
  ServiceContentDetailCard() {
    Column() {
      ForEach(this.orderVM.goodInfo.serviceDetailList, (v: IServiceDetail, indexOut: number) => {
        Column({ space: 10 }) {
          Row({ space: 10 }) {
            Text(v.title).fontSize(12).fontWeight(400)
            Text(v.subTitle).fontSize(10).fontColor($r('app.color.common_grey'))
          }
          .alignSelf(ItemAlign.Start)

          Grid() {
            ForEach(v.prices, (item: IServiceDetailItem, indexInside: number) => {
              GridItem() {
                Column() {
                  ServiceText({ content: item })
                }
                .width(CommonConstants.FULL_PERCENT)
                .padding(6)
                .borderRadius(4)
                .backgroundColor(this.orderVM.isServiceItemSelected(indexOut, indexInside) ?
                $r('app.color.common_theme_color_5') : Color.White)
                .borderWidth(1)
                .borderColor(this.orderVM.isServiceItemSelected(indexOut, indexInside) ?
                $r('app.color.common_theme_color_90') : Color.Transparent)
                .onClick(() => {
                  this.orderVM.onClickServiceItem(indexOut, indexInside);
                })
              }
            }, (item: number) => item.toString())
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(4)

          if (indexOut !== this.orderVM.goodInfo.serviceDetailList!.length - 1) {
            Divider().margin({ bottom: 10 })
          }
        }
      }, (v: IServiceDetail) => v.title + v.subTitle)
    }
    .backgroundColor('#F1F3F5')
    .borderRadius(4)
    .padding(10)
  }

  @Builder
  SelectService() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_teams')).width(14)
        Text('选择服务')
          .fontSize(14)
          .fontWeight(500)
          .margin({ left: 8 })
        Blank()
        Image(this.orderVM.showServiceDetail ? $r('app.media.ic_public_arrow_down') :
        $r('app.media.ic_public_arrow_right'))
          .width(this.orderVM.showServiceDetail ? 24 : 12)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(48)
      .onClick(() => {
        this.orderVM.showServiceDetail = !this.orderVM.showServiceDetail;
      })

      if (this.orderVM.showServiceDetail) {
        Column() {
          this.ServiceContentDetailCard()
        }
        .margin({ left: 18, bottom: 10 })
      }
    }
  }

  @Builder
  ServiceTime() {
    Row() {
      Image($r('app.media.ic_public_clock')).width(14)
      Text('上门时间')
        .fontSize(14)
        .fontWeight(500)
        .margin({ left: 8 })
      Blank()
      TimeSelect({
        label: this.orderVM.getTimeText(),
        timeOptions: {
          days: 7,
          startTime: '06:59:00',
          endTime: '19:30:00',
        },
        styleOptions: {
          dayFgSelected: $r('app.color.common_theme_color'),
          timeBgSelected: $r('app.color.common_theme_color_5'),
          timeBorderSelected: $r('app.color.common_theme_color_90'),
        },
        onTimeSelect: (dateTime: Date) => {
          this.orderVM.selectedDateTime = dateTime;
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(48)
  }
}
