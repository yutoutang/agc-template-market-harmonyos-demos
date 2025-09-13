/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import display from '@ohos.display'
import { TopBar, MyScrollModifier } from 'commonlib';
import { MessageItem, NumbObj } from '../models/MessageModel';
import { SystemMessageModel, SystemMessageObj } from '../models/SystemMessageModel';
import { MultiLineText } from '../views/MultiLineText';

@ComponentV2
export struct SystemMessage {
  @Local isSelectDelete: boolean = false;
  @Local swiperSystemLeft: boolean = false
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local systemNumbObj: SystemMessageObj = AppStorageV2.connect(SystemMessageObj, () => new SystemMessageObj())!;

  build() {
    Column() {
      TopBar({ title: $r('app.string.system_message') })
      Scroll() {
        Column() {
          List({ space: 12 }) {
            ForEach(this.systemNumbObj.listArr, ((item: SystemMessageModel, index: number) => {
              ListItem() {
                SystemMessageItem({ info: item })
              }
              .swipeAction({
                edgeEffect: SwipeEdgeEffect.None,
                end: {
                  builder: () => {
                    this.systemItemEnd(index)
                  },
                  actionAreaDistance: 26,
                  onStateChange: (state: SwipeActionState) => {
                    if (state === SwipeActionState.EXPANDED) {
                      this.swiperSystemLeft = true
                      this.isSelectDelete = false
                    } else if (state === SwipeActionState.COLLAPSED) {
                      this.swiperSystemLeft = false
                    }
                  },
                }
              })
            }), (item: SystemMessageModel, index: number) => item.id + index)
          }
          .width('100%')
          .height('auto')
          .margin({ top: $r('app.float.vp_12') })
        }.width('100%')

      }.attributeModifier(this.scrollModifier)

    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
  }

  //更新角标
  refreshData() {
    let propNumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
    propNumbObj.listArr.forEach((item: MessageItem) => {
      if (item.title === '系统消息') {
        item.unreadMessageCount = this.systemNumbObj.listArr.length
      }
    })
  }

  @Builder
  systemItemEnd(index: number) {
    Row() {
      Image($r('app.media.icon_envelope_delete'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.systemNumbObj.listArr.splice(index, 1)
          this.refreshData()
        })
    }.padding($r('app.float.vp_4')).justifyContent(FlexAlign.SpaceEvenly)
  }
}

@ComponentV2
struct SystemMessageItem {
  @Param info: SystemMessageModel = new SystemMessageModel('', '', '', '', '', '', 3)
  @Param screenWidth: number = display.getDefaultDisplaySync().width / display.getDefaultDisplaySync().scaledDensity;

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.icon_envelope'))
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ left: $r('app.float.vp_12') })
          Text(this.info.messageType)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: $r('app.float.vp_4') })
        }

        Text(this.info.time)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .margin({ right: $r('app.float.vp_12') })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .margin({ top: $r('app.float.vp_16') })

      Text(this.info.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: $r('app.float.vp_12'), top: $r('app.float.vp_12') })

      // 多行内容
      Column() {
        MultiLineText({
          content: this.info.subtitle.toString(),
          fontSize: $r('sys.float.Body_M'),
          lineHeight: $r('app.float.vp_19'),
          fontColor: $r('sys.color.font_secondary'),
          widthRatio: 0.9
        })
      }
      .width(this.screenWidth - 32)

    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .borderRadius($r('app.float.vp_16'))
  }
}

@Builder
export function SystemMessageBuilder() {
  SystemMessage()
}