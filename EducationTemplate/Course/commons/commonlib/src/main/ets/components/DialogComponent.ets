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

import { AppStorageV2 } from '@kit.ArkUI';
import { WindowSize } from '../models/WindowSize';
import { DialogParams, DialogUtil } from '../utils/DialogUtil'
import { Logger } from '../utils/Logger';

@Builder
export function DialogComponent(param: DialogParams) {
  AlertComponent({ params: param })
}

@ComponentV2
struct AlertComponent {
  @Param params: DialogParams = { title: '' }
  @Local contentHeight: number = 0
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
  // 最大高度
  @Local maxHeight: number = 500
  // 最小高度
  minHeight = 150
  screenHeight: number = 0
  screenWidth: number = 0
  fontSize: string = '16fp'
  lineHeight = 16
  uiContext: UIContext = this.getUIContext()
  textSize: SizeOptions = {};

  @Monitor('windowSize.screenHeight')
  onNameChange() {
    this.onWindowSizeChange()
  }

  aboutToAppear(): void {
    this.onWindowSizeChange()
  }

  aboutToDisappear(): void {
    DialogUtil.close()
  }

  onWindowSizeChange() {
    this.getCurrentScreen();
    this.textSize = this.uiContext.getMeasureUtils().measureTextSize({
      textContent: this.params.title,
      fontSize: this.fontSize,
      lineHeight: this.lineHeight,
      fontWeight: 500,
      constraintWidth: (this.screenWidth * 0.8 - 32)
    });
    this.contentHeight = this.uiContext.px2vp(Number(this.textSize.height));
    this.minHeight = 150;
    this.maxHeight = this.screenHeight * 0.8;
  }

  build() {
    Column() {
      Scroll() {
        Text(this.params.title)
          .fontSize(this.fontSize)
          .lineHeight(this.lineHeight)
          .fontWeight(500)
          .width('100%')
          .padding(16)
          .textAlign(this.contentHeight > 16 ? TextAlign.Start : TextAlign.Center)
          .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
            Logger.info('Test Text isExpanding: ' + isExpanding + ', currentRatio:' + currentRatio)
            if (isExpanding && currentRatio >= 1.0) {
              Logger.info('Test Text is fully visible. currentRatio:' + currentRatio)
            }
            if (!isExpanding && currentRatio <= 0.0) {
              Logger.info('Test Text is completely invisible.')
            }
            Logger.info(`The width of 'Hello World': ${(Number(this.textSize.height))}`)
          })
      }
      .scrollBar(BarState.Off)
      .edgeEffect((this.contentHeight + 48 + 32) > this.minHeight ? EdgeEffect.Spring : EdgeEffect.None)
      .layoutWeight(1)

      Row() {
        Text(!this.params.cancelTitle ? '取消' : this.params.cancelTitle)
          .fontWeight(500)
          .opacity(0.6)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .onClick(() => {
            DialogUtil.close()
            if (this.params.cancelFunc) {
              this.params.cancelFunc();
            }
          });
        Row()
          .backgroundColor($r('sys.color.background_secondary'))
          .width(1)
          .height(24)
        Text(!this.params.confirmTitle ? '删除' : this.params.confirmTitle)
          .fontWeight(500)
          .fontColor('#E84026')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .onClick(() => {
            DialogUtil.close()
            if (this.params.confirmFunc) {
              this.params.confirmFunc();
            }
          });
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .size({ width: '80%', height: Math.min(this.contentHeight + 48 + 32, this.maxHeight) })
    .constraintSize({ minHeight: this.minHeight })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .clip(true)
  }

  /**
   * 获取当前屏幕宽高
   */
  getCurrentScreen() {
    this.screenWidth = this.uiContext.px2vp(this.windowSize.screenWidth);
    this.screenHeight = this.uiContext.px2vp(this.windowSize.screenHeight);
  }
}