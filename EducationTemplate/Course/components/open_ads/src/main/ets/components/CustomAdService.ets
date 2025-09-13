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

import { display, window } from '@kit.ArkUI';
import { AdType } from '../common/Constant';

@ComponentV2
export struct CustomAdService {
  // 广告类型
  @Param adType?: AdType = AdType.AD_PICTURE
  @Param videoSrc?: ResourceStr = ''
  @Param previewUri?: ResourceStr = ''
  @Param imageUrl?: ResourceStr = ''
  // 应用Id（三方广告平台必传）
  @Param appId?: string = '';
  // 应用名称（三方广告平台必传）
  @Param appName?: string = '';
  // 广告关闭的回调
  @Param closeCallBack: () => void = () => {
  };
  controller: VideoController = new VideoController();
  @Local pageCountDown: number = 6;
  private timer: number = 0;
  private windowSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };

  aboutToAppear(): void {
    this.startTimer()
  }

  startTimer() {
    this.timer = setInterval(() => {
      this.pageCountDown--;
      if (this.pageCountDown === 1) {
        clearInterval(this.timer); // 关闭定时器
        this.closeCallBack()
      }
    }, 1000)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        if (this.adType === AdType.AD_PICTURE) {
          Image(this.imageUrl)
            .width('100%')
            .height('100%')
        } else {
          Video({
            src: this.videoSrc,
            previewUri: this.previewUri,
            controller: this.controller,
          })
            .controls(false)
            .autoPlay(true)
            .loop(true)
            .width('100%')
            .height('100%')
        }
      }
      .width('100%')
      .height('100%')

      Row() {
        Text('跳过')
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
        Text(`${this.pageCountDown}`)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
          .margin({ left: 2 })
      }
      .justifyContent(FlexAlign.Center)
      .width(66)
      .height(24)
      .backgroundColor($r('app.string.advertising_description_backgroundColor'))
      .borderRadius(18)
      .onClick(() => {
        this.pageCountDown = 1;
        clearInterval(this.timer); // 手动跳过时关闭定时器
        this.closeCallBack()
      })
      .margin({ top: 40, right: 16 })
    }
    .width('100%')
    .height('100%')
  }
}