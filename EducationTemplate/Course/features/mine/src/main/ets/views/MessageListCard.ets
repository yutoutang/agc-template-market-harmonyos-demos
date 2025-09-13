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

import { AppStorageV2 } from '@kit.ArkUI'
import display from '@ohos.display'
import { MessageItem } from '../models/MessageModel';
import { CourseMessageObj, SystemMessageObj } from '../models/SystemMessageModel';

/**
 * 消息通知card
 */
@ComponentV2
export struct MessageListCard {
  @Param info: MessageItem = new MessageItem('', '', '', '', '', false, 0)
  @Param screenWidth: number = display.getDefaultDisplaySync().width / display.getDefaultDisplaySync().scaledDensity;
  @Local courseNumbObj: CourseMessageObj = AppStorageV2.connect(CourseMessageObj, () => new CourseMessageObj())!;
  @Local systemNumbObj: SystemMessageObj = AppStorageV2.connect(SystemMessageObj, () => new SystemMessageObj())!;

  build() {
    Row() {
      Row() {
        Badge({
          count: !this.info.isClearMessage ? this.info.unreadMessageCount : 0,
          style: {},
          position: BadgePosition.RightTop,
        }) {
          Image(this.info.icon)
            .width($r('app.float.vp_48'))
            .height($r('app.float.vp_48'))

        }
        .width($r('app.float.vp_50'))
        .margin({
          left: $r('app.float.vp_16'),
          top: $r('app.float.vp_12'),
          bottom: $r('app.float.vp_12'),
          right: $r('app.float.vp_12')
        })

        Column() {
          Row() {
            Text(this.info.title)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
            Text(this.info.time)
              .fontColor($r('sys.color.font_tertiary'))
              .fontSize($r('sys.float.Body_S'))
              .fontWeight(FontWeight.Regular)
              .margin({ right: $r('app.float.vp_16') })
          }.justifyContent(FlexAlign.SpaceBetween)
          .width('100%')

          Text(this.info.subtitle)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize($r('sys.float.Body_S'))
            .margin({ top: $r('app.float.vp_4'), right: $r('app.float.vp_16') })
        }
        .alignItems(HorizontalAlign.Start)
        .width(this.screenWidth - 76)
      }
    }
  }
}