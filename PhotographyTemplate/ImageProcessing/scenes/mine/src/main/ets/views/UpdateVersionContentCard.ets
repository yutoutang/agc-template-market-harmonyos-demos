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

@ComponentV2
export struct UpdateContentCard {
  build() {
    Column() {
      Text($r('app.string.new_version'))
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .height($r('app.float.vp_26'))
        .padding({
          bottom: $r('app.float.vp_15')
        })
      Column() {
        Row({ space: 8 }) {
          Text('应用')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
          Text('图像美化应用模板')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        Row({ space: 8 }) {
          Text('版本')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
          Text('10.15.1')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
        Row({ space: 8 }) {
          Text('大小')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Regular)
          Text('50MB')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: $r('app.float.vp_12'),
        bottom: $r('app.float.vp_12')
      })
      Column() {
        Text('详情')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.float.vp_12') })
        Text('1、新增 发布添加xxx\n' +
          '2、优化 xxx问题\n' +
          '3、修复 若干bug')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({
        top: $r('app.float.vp_12'),
        bottom: $r('app.float.vp_12')
      })
    }
  }
}