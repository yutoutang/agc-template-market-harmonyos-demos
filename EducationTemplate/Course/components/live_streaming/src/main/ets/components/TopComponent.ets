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

import { batteryInfo, BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { ChatViewVM } from '../viewModels/ChatViewVM';

// 定义订阅者，用于保存创建成功的订阅者对象，后续使用其完成订阅及退订的动作
let subscriber: commonEventManager.CommonEventSubscriber;
// 订阅者信息
let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
  events: ['usual.event.POWER_CONNECTED', 'usual.event.POWER_DISCONNECTED']
};

@ComponentV2
export struct TopComponent {
  @Param isLock: boolean = false;
  @Param currentTime: string = '';
  @Local vm: ChatViewVM = ChatViewVM.instance;
  @Param backClick: () => void = () => {
  };

  @Builder
  topBuilder() {
    if (this.isLock) {
      Row() {
        Image($r('app.media.icon_chevron_backward_dark'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.backClick();
          });
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding({ top: 20, left: 24 });
    } else {
      Row() {
        Image($r('app.media.icon_chevron_backward_dark'))
          .width(40)
          .height(40)
          .margin({ right: 8 })
          .onClick(() => {
            this.backClick();
          });

        Row({ space: 4 }) {
          Row({ space: 5 }) {
            Image($r('app.media.ic_live_streaming04'))
              .width(28)
              .height(28)
              .margin({ left: 2 });
            Column() {
              Text('苏苏')
                .fontSize($r('sys.float.Caption_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_on_primary'))
                .margin({ bottom: 4 });
              Row() {
                Image($r('app.media.illustration'))
                  .width(10)
                  .height(10)
                  .opacity(0.6);
                Text('1.8w')
                  .fontSize($r('sys.float.Caption_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_on_secondary'))
                  .margin({ left: 2 });
              };
            }
            .alignItems(HorizontalAlign.Start);
          }
          .backgroundColor($r('sys.color.font_secondary'))
          .opacity(0.8)
          .width(82)
          .height(32)
          .borderRadius(40);

          Blank()
            .layoutWeight(1);
          Image($r('app.media.ic_live_streaming01'))
            .width(24)
            .height(24);
          Image($r('app.media.ic_live_streaming02'))
            .width(24)
            .height(24);
          Image($r('app.media.ic_live_streaming03'))
            .width(24)
            .height(24);
          Text('2383')
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.font_secondary'))
            .opacity(0.8)
            .padding({
              top: 5,
              bottom: 5,
              left: 10,
              right: 10
            })
            .borderRadius(10);
          Image(this.vm.isCharge ? $r('app.media.battery_bolt') : $r('app.media.battery_60percent'))
            .width(24)
            .height(12)
            .margin({ left: 10 });
          Text(this.currentTime)
            .fontSize($r('sys.float.Body_S'))
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 5, right: 24 });
        }
        .layoutWeight(1);
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding({ top: 20, left: 24, right: 24 });
    }
  }

  aboutToAppear(): void {
    try {
      commonEventManager.createSubscriber(subscribeInfo, createCB);
    } catch (error) {
    }
    getBatteryInfo();
  }

  build() {
    this.topBuilder();
  }
}

function getBatteryInfo() {
  let batterySOCInfo: number = batteryInfo.batterySOC;
  let chargingStatusInfo = batteryInfo.chargingStatus;
  if (chargingStatusInfo === 1 || chargingStatusInfo === 3) {
    ChatViewVM.instance.isCharge = true;
  } else {
    ChatViewVM.instance.isCharge = false;
  }
  ChatViewVM.instance.charge = batterySOCInfo;
}

function createCB(err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) {
  if (!err) {
    subscriber = commonEventSubscriber;
    try {
      commonEventManager.subscribe(subscriber, subscribeCB);
    } catch (error) {
    }
  }
}

// 订阅公共事件回调
function subscribeCB(err: BusinessError, data: commonEventManager.CommonEventData) {
  getBatteryInfo();
}
