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

import { BusinessError } from '@ohos.base';
import measure from '@ohos.measure';
import curves from '@ohos.curves';
import display from '@ohos.display';

@ComponentV2
export struct MultiLineText {
  @Param @Require content: string;
  @Param fontSize: ResourceColor = $r('sys.float.Body_M');
  @Param lineHeight: ResourceColor = $r('app.float.vp_19');
  @Param fontColor: ResourceColor = $r('sys.color.font_secondary');
  @Param widthRatio: number = 0.9;
  @Local lines: number = 3;
  @Local collapseText: string | Resource = '...全文'
  @Local isExpandable: boolean = false;

  aboutToAppear() {
    this.performPreciseMeasurement();
  }

  private performPreciseMeasurement() {
    const textWidth = measure.measureText({
      textContent: this.content,
      fontSize: this.fontSize
    });
    display.getAllDisplays().then((data: Array<display.Display>) => {
      const screenWidth = data[0].width;
      // 屏幕宽度 * 最大行数 * 组件宽度比例 和 文字测量宽度
      this.isExpandable = (screenWidth) * this.lines * this.widthRatio <= textWidth
    }).catch((err: BusinessError) => {
      console.error(`[ExpandableText] Failed to obtain display info: ${JSON.stringify(err)}`);
    });
  }

  build() {
    Column() {
      if (this.isExpandable) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Text(this.content)
            .fontSize(this.fontSize)
            .lineHeight(this.lineHeight)
            .fontColor(this.fontColor)
            .fontWeight(FontWeight.Regular)
            .maxLines(this.lines)
            .margin({
              top: $r('app.float.vp_8'),
              left: $r('app.float.vp_12'),
              right: $r('app.float.vp_12'),
            })
          Row() {
            Text(this.collapseText)
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .fontWeight(FontWeight.Regular)
              .backgroundColor(Color.White)
          }.margin({
            right: $r('app.float.vp_12'),
          })
          .justifyContent(FlexAlign.End)
          .onClick(() => {
            if (this.collapseText === '...全文') {
              this.collapseText = '...收起';
              // 展开动画
              animateTo({
                duration: 150,
                curve: curves.springMotion(0.5, 0.8),
              }, () => {
                this.lines = -1; // 使得设置的最大行属性无效
              })
            } else {
              this.collapseText = '...全文';
              // 收起动画
              animateTo({
                duration: 100,
                curve: Curve.Friction,
              }, () => {
                this.lines = 3; // 只显示3行
              })
            }
          })
        }
        .margin({
          bottom: $r('app.float.vp_16')
        })

      } else {
        Text(this.content)
          .fontSize(this.fontSize)
          .lineHeight(this.lineHeight)
          .fontColor(this.fontColor)
          .margin({
            top: $r('app.float.vp_8'),
            left: $r('app.float.vp_12'),
            right: $r('app.float.vp_12'),
            bottom: $r('app.float.vp_16')
          })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)

  }
}