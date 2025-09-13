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

import { AppStorageV2, display, window } from '@kit.ArkUI'
import { PreferConstant, PreferenceUtil, RouterMap, RouterModule, WindowSize } from 'commonlib'

@Builder
export function LaunchPageBuilder() {
  LaunchPage()
}

@ComponentV2
struct LaunchPage {
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
  @Local contentHeight: number = 0
  screenHeight: number = 0
  screenWidth: number = 0
  uiContext: UIContext = this.getUIContext()
  private pageSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };

  @Monitor('windowSize.screenHeight')
  onNameChange() {
    this.getCurrentScreen()
  }

  /**
   * 获取当前屏幕宽高
   */
  getCurrentScreen() {
    this.contentHeight = this.uiContext.px2vp(this.windowSize.screenHeight - this.windowSize.statusHeight -
    this.windowSize.bottomHeight)
  }

  aboutToAppear(): void {
    this.getCurrentScreen()
    setTimeout(() => {
      let privacyState = PreferenceUtil.getInstance().get(PreferConstant.PRIVACY_POLICY_KEY, '0')
      if (privacyState === '1') {
        RouterModule.replace({ url: RouterMap.LAUNCH_AD_PAGE })
      } else {
        RouterModule.replace({ url: RouterMap.PRIVACY_POLICY_PAGE })
      }
    }, 500)
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Image($r('app.media.ic_launch')).width($r('app.float.vp_116')).height($r('app.float.vp_116'))
            .margin({ top: $r('app.float.vp_215') })
          Column() {
            Text('课堂模板')
              .fontSize($r('sys.float.Title_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#483AD5')
            Text('直播也是如此精彩')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor('#564AF7')
              .opacity(0.9)
          }.margin({ top: $r('app.float.vp_258') })
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .height(this.getUIContext()
          .px2vp(this.pageSize.height - this.windowSize.statusHeight - this.windowSize.bottomHeight))
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(this.windowSize.windowStatusType === 5 ? EdgeEffect.Spring : EdgeEffect.None)
      .width('100%')
      .height(this.contentHeight)
    }
    .width('100%')
    .height('100%')
  }
}