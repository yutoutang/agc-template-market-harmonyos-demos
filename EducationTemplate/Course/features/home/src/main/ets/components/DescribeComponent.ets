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

@ComponentV2
export struct DescribeComponent {
  @Param description: string = ''

  build() {
    Column() {
      Text(this.description)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .margin({ top: 24 })

      Column() {
        Text('课程详情')
          .fontWeight(FontWeight.Bold)
          .fontSize($r('sys.float.Subtitle_L'))
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 12 })

        Image($r('app.media.ic_course_detail'))
          .aspectRatio(0.7)
          .borderRadius(16)
          .width('100%')
      }
      .margin({ top: 24, bottom: 24 })
    }
  }
}