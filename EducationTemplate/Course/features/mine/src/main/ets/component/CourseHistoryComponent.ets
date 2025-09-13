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

@ComponentV2
export struct CourseHistoryComponent {
  // 课程封面
  @Require @Param cover: ResourceStr;
  // 学习进度
  @Param learnProgress: number = 0;
  // 课程名称
  @Require @Param courseTitle: string;

  build() {
    Row() {
      Image(this.cover)
        .width($r('app.float.vp_96'))
        .height($r('app.float.vp_54'))
        .borderRadius(8)
      Column() {
        Row() {
          Text(this.courseTitle)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(VerticalAlign.Top)
        .height($r('app.float.vp_42'))

        Row() {
          Text(`已学习${this.learnProgress}%`)
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Caption_L'))
            .height($r('app.float.vp_16'))
        }

        Divider().color($r('sys.color.comp_divider')).margin({ top: $r('app.float.vp_16') })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: $r('app.float.vp_12'), top: $r('app.float.vp_16') })
      .layoutWeight(1)
    }
    .width('100%')
    .height($r('app.float.vp_92'))
  }
}
