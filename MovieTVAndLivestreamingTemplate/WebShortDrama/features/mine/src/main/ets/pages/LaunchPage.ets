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

import { NAV_PAGE_NAME } from '@agctemplate/resources'
import { appRouter, PreferConstant, PreferenceUtil, WindowManager } from '@agctemplate/utils'


@Builder
export function LaunchPageBuilder() {
  LaunchPage()
}

@ComponentV2
struct LaunchPage {
  screenHeight: number = 0
  screenWidth: number = 0
  uiContext: UIContext = this.getUIContext()


  aboutToAppear(): void {
    WindowManager.setWindowSystemBarEnable([])
    setTimeout(() => {
      let privacyState = PreferenceUtil.getInstance(getContext()).get(PreferConstant.FIRSTLAUNCH, true) as boolean
      if (privacyState === false) {
        appRouter.replace({ builderName: NAV_PAGE_NAME.LaunchAdPage.name })
      } else {
        appRouter.replace({ builderName: NAV_PAGE_NAME.PrivacyAgreementPage.name })
      }
    }, 2000)
  }

  build() {
    NavDestination() {
    Column() {
        Column() {
          Image($r('app.media.ic_launch')).width(116).height(116)
            .margin({ top: 215 })
          Column() {
            Text('短剧模板')
              .fontSize($r('sys.float.Title_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#EC6E45')
            Text('海量短剧 如此精彩')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Regular)
              .fontColor('#EC6E45')
              .opacity(0.9)
          }.margin({ top: 258 })
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
      }
    }
    .onBackPressed(() => {
      return true
    })
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}