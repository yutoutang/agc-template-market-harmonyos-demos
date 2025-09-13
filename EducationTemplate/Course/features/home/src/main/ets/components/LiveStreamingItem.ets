/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { display } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { Course } from 'http';
import { LiveBroadcastSign } from './LiveBroadcastSign';
import { LiveNumberOverlay } from './LiveNumberOverlay';

@ComponentV2
export struct LiveStreamingItem {
  @Require @Param course: Course;
  // 屏幕宽度
  screenWidth: number = display.getDefaultDisplaySync().width / display.getDefaultDisplaySync().scaledDensity;

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image(this.course.cover)
          .width('100%')
          .height($r('app.float.vp_90'))
        LiveNumberOverlay({ liveNumber: this.course.liveNumber })
          .visibility(this.course.liveState! === 1 ? Visibility.Visible : Visibility.None)
      }

      // 直播中标志
      LiveBroadcastSign()
        .position({ x: $r('app.float.vp_2'), y: $r('app.float.vp_2') })
        .visibility(this.course.liveState! === 1 ? Visibility.Visible : Visibility.None)
      // 精彩回顾标志
      this.highlightsSign()
      Column() {
        Text(this.course.courseTitle)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.BREAK_ALL)
        Column() {
          Text(dayjs().year() === dayjs(this.course.reservationTime).year() ?
          dayjs(this.course.reservationTime).format('MM/DD HH:mm') :
          dayjs(this.course.reservationTime).format('YYYY/MM/DD HH:mm'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .height($r('app.float.vp_13'))
            .margin({ bottom: $r('app.float.vp_2') })

          Text('主讲老师: ' + this.course.lecturer)
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .height($r('app.float.vp_13'))
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
      .padding($r('app.float.vp_8'))
      .width('100%')
      .height($r('app.float.vp_84'))
    }
    .height($r('app.float.vp_174'))
    .width('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .clip(true)
    .onClick(() => {
      // 跳转直播或者直播回顾
      if (this.course.liveState! === 1) {
        //直播间
      } else if (this.course.liveState! === 0) {
        //精彩回顾
      }
    })
  }

  /**
   * 精彩回顾标志
   */
  @Builder
  highlightsSign() {
    Row() {
      Image($r('app.media.highlights_icon'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_12'))
        .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_2') })
      Text($r('app.string.highlights'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .position({ x: $r('app.float.vp_2'), y: $r('app.float.vp_2') })
    .backgroundColor($r('sys.color.mask_fourth'))
    .width($r('app.float.vp_62'))
    .height($r('app.float.vp_16'))
    .visibility(this.course.liveState! === 0 ? Visibility.Visible : Visibility.None)
    .borderRadius({
      topLeft: $r('app.float.vp_6'),
      topRight: $r('app.float.vp_2'),
      bottomLeft: $r('app.float.vp_2'),
      bottomRight: $r('app.float.vp_6')
    })
  }
}
 