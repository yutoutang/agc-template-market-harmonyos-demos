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
import { PrivacyAgreementBuilder } from './PrivacyAgreementPage'


@Builder
export function LaunchPageBuilder() {
  LaunchPage()
}

@ComponentV2
struct LaunchPage {
  screenHeight: number = 0
  screenWidth: number = 0
  uiContext: UIContext = this.getUIContext()
  @Local isShow: boolean = false

  aboutToAppear(): void {
    WindowManager.setWindowSystemBarEnable([])
    setTimeout(() => {
      let privacyState = PreferenceUtil.getInstance(this.getUIContext().getHostContext())
        .get(PreferConstant.FIRSTLAUNCH, true) as boolean
      if (privacyState === false) {
        appRouter.replace({ builderName: NAV_PAGE_NAME.LaunchAdPage.name })
      } else {
        // appRouter.replace({ builderName: NAV_PAGE_NAME.PrivacyAgreementPage.name })
        this.isShow = true
      }
    }, 2000)
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Image($r('app.media.launch')).width(192).height(192)
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      }
    }
    .bindSheet($$this.isShow, PrivacyAgreementBuilder(), {
      detents: ['95%'],
      preferType: SheetType.CENTER,
      showClose: false,
      onWillDismiss: () => {
      }
    })
    .onBackPressed(() => {
      return true
    })
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}