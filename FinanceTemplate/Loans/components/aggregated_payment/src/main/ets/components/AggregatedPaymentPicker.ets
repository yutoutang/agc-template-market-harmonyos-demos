/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import { ChannelType, WxExtraInfo } from '../common/Constant';
import { OnWXResp, wxEventHandler as WXEventHandler } from '../model/WXApiWrap';
import { AggregatedPaymentVM } from '../viewmodel/AggregatedPaymentVM';
import { ChannelInfo } from '../model/Index';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct AggregatedPaymentPicker {
  vm: AggregatedPaymentVM = AggregatedPaymentVM.instance;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Local isShow: boolean = false;
  @Local checkedType: number = 0;
  @Local currentType: number = 0;
  @Local wxPayResultText: string = '';
  @Local preOrderInfo: string | WxExtraInfo = '';
  @Local appId: string = '';
  @Param price: string = '';
  @Param goodsName: string = '';
  /**
   * 支付渠道及支付渠道信息
   */
  @Param channelInfo: ChannelInfo[] = [];
  private wxHandler = WXEventHandler;

  /**
   * 支付宝支付成功跳转页面Name
   */
  @Param paySuccessEvent: (type: ChannelType) => void = () => {
  };

  /**
   * 支付宝支付失败跳转页面Name
   */
  @Param payFailEvent: (type: ChannelType) => void = () => {
  };

  aboutToAppear(): void {
    this.wxHandler.registerOnWXRespCallback(this.onWXResp);
    this.checkedType = this.channelInfo[0].channelType;
    if (this.channelInfo.length > 0) {
      this.channelInfo.forEach((payInfo: ChannelInfo) => {
        if (!payInfo.icon) {
          if (payInfo.channelType === ChannelType.HUAWEI_PAY) {
            payInfo.icon = $r('app.media.hw_pay')
          } else if (payInfo.channelType === ChannelType.ALI_PAY) {
            payInfo.icon = $r('app.media.alipay')
          } else {
            payInfo.icon = $r('app.media.wechat')
          }
        }
      })
    }
  }

  aboutToDisappear(): void {
    this.wxHandler.unregisterOnWXRespCallback(this.onWXResp);
  }

  @Builder
  paymentChannelPicker() {
    Column({ space: 5 }) {
      Column() {
        Text(this.goodsName)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: 8 })
        Text() {
          Span('¥')
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(700)
          Span(this.price)
            .fontSize($r('sys.float.Title_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(700)
        }
      }
      .width('100%')
      .height(72)

      Column() {
        ForEach(this.channelInfo, (item: ChannelInfo, index: number) => {
          Row() {
            Image(item.icon).size({ width: 48, height: 48 }).margin({ right: 12 });

            Column() {
              Row() {
                Text(item.name)
                  .fontSize($r('sys.float.Subtitle_M'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
                  .select(this.currentType === item.channelType)
                  .selectedColor($r('sys.color.comp_background_emphasize'))
                  .shape(CheckBoxShape.CIRCLE)
                  .onClick(()=>{
                    this.currentType = index;
                  })
                  .onChange((value: boolean) => {
                    if (value) {
                      this.checkedType = item.channelType;
                      this.preOrderInfo = item.preOrderInfo;
                      if (item.appId) {
                        this.appId = item.appId;
                      }
                    }
                  });
              }
              .width('100%')
              .height(48)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)

              Blank()
                .width('100%')
                .height(10)

            }
            .justifyContent(FlexAlign.Center)
            .layoutWeight(1)
          }
          .width('100%')
          .height(72)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(12)

          if (index !== this.channelInfo.length - 1) {
            Blank()
              .width('90%')
              .height(0.5)
              .backgroundColor($r('sys.color.comp_divider'))

          }

        }, (item: ChannelInfo) => item.channelType.toString());
      }.width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)

      Button('确认付款')
        .width('100%')
        .backgroundColor('#317AF7')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (this.checkedType === ChannelType.ALI_PAY || this.checkedType === ChannelType.WECHAT_PAY ||
            this.checkedType === ChannelType.HUAWEI_PAY) {
            if (this.checkedType === ChannelType.ALI_PAY) {
              this.vm.aliPay(this.paySuccessEvent, this.payFailEvent, this.preOrderInfo);
            } else if (this.checkedType === ChannelType.WECHAT_PAY) {
              this.vm.weChatPay(this.paySuccessEvent, this.payFailEvent, this.preOrderInfo, this.appId);
            } else {
              this.vm.huaweiPay(this.paySuccessEvent, this.payFailEvent, this.context, this.preOrderInfo);
            }
          } else {
            promptAction.showToast({ message: '请先选择支付方式' })
          }
        })
        .margin({ top: 30 });
    }.padding(12).margin({ top: 16 });
  }

  build() {
    Column() {
      this.paymentChannelPicker();
    }
    .justifyContent(FlexAlign.Center);
  }

  private onWXResp: OnWXResp = (resp) => {
    this.wxPayResultText = JSON.stringify(resp ?? {}, null, 2);
  };
}
