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
export struct CourseStudyComponent {
  // 课程名
  @Require @Param courseTitle: string;
  // 进度
  @Param learnProgress: number = 0;
  // 封面
  @Require @Param courseCover: ResourceStr;

  build() {
    Row() {
      Image(this.courseCover)
        .height($r('app.float.vp_54'))
        .width($r('app.float.vp_96'))
        .borderRadius(8)
      Column() {
        Row() {
          Text(this.courseTitle)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
        }
        .height($r('app.float.vp_42'))
        .alignItems(VerticalAlign.Top)

        Row() {
          Text(`已学习${this.learnProgress}%`)
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Caption_L'))
            .fontColor($r('sys.color.font_tertiary'))
            .height($r('app.float.vp_16'))
        }
        Divider().color($r('sys.color.comp_divider')).margin({ top: $r('app.float.vp_16') })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: $r('app.float.vp_12'), top: $r('app.float.vp_16') })
    }
    .width('100%')
    .height($r('app.float.vp_92'))
  }
}
