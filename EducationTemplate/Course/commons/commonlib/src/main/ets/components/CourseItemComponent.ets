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

import { NumberUtil } from '../utils/NumberUtil';

@ComponentV2
export struct CourseItemComponent {
  // 课程名称
  @Require @Param courseTitle: string;
  // 课程时长
  @Require @Param courseDuration: number;
  // 学习进度
  @Param learnProgress: number = 0;
  // 课程封面
  @Require @Param cover: ResourceStr;
  // 课程类别
  @Param category: number = 1;
  // 讲师
  @Param lecturer: string = '';
  // 学习人数
  @Param learnNumber: number = 0;

  build() {
    Row() {
      Image(this.cover)
        .width($r('app.float.vp_96'))
        .height($r('app.float.vp_54'))
        .borderRadius(8)
      Column() {
        Row() {
          Text(this.courseTitle)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
        }
        .height($r('app.float.vp_42'))
        .alignItems(VerticalAlign.Top)

        Row() {
          Image($r('app.media.icon_time'))
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ right: $r('app.float.vp_2') })
            .visibility(this.learnProgress > 0 ? Visibility.None : Visibility.Visible)
          Text(this.learnProgress > 0 ? `已学习${this.learnProgress}%` :
          NumberUtil.getHourAndMinuteFormat(this.courseDuration))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .height($r('app.float.vp_16'))
        }.visibility(this.category === 1 ? Visibility.Visible : Visibility.None)

        Row() {
          Text('讲师：' + this.lecturer)
            .fontSize($r('sys.float.Caption_L'))
            .fontColor($r('sys.color.font_secondary'))
          Text(NumberUtil.getCountFormat(this.learnNumber) + '人学过')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height($r('app.float.vp_16'))
        .visibility(this.category === 3 ? Visibility.Visible : Visibility.None)

        Divider().color($r('sys.color.comp_divider')).margin({ top: $r('app.float.vp_16') })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .padding({ left: $r('app.float.vp_12'), top: $r('app.float.vp_16') })
    }
    .width('100%')
    .height($r('app.float.vp_92'))
  }
}
 