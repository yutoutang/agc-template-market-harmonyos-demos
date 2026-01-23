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
export function PrivacyPolicyBuilder() {
  PrivacyPolicy()
}

@ComponentV2
struct PrivacyPolicy {
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

  aboutToAppear(): void {
    this.getCurrentScreen()
  }

  /**
   * 获取当前屏幕宽高
   */
  getCurrentScreen() {
    this.contentHeight = this.uiContext.px2vp(this.windowSize.screenHeight)
  }

  @Builder
  splitScreen() {
    Scroll() {
      Column() {
        Image($r('app.media.ic_launch'))
          .width($r('app.float.vp_72'))
          .height($r('app.float.vp_72'))
          .borderRadius($r('app.float.vp_16'))
          .margin({ top: $r('app.float.vp_158') })
        Text('拍照美化')
          .fontSize($r('sys.float.Title_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('app.float.vp_24') })
        Text('业务描述')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') })
        Blank()
          .layoutWeight(1)
        Image($r('app.media.ic_me_security_shield'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
        Text('隐私协议') {
          Span('本应用需')
          Span('联网').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
          Span('，调用')
          Span('XX').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
          Span('、')
          Span('XX').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
          Span('权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
          Span('XX业务与隐私的声明、权限使用说明').fontWeight(FontWeight.Medium).fontColor('#4B5CC4').onClick(() => {
            RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE, param: true })
          })
          Span('。')
        }
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_secondary')).margin({ top: 16 })

        Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: 4 })

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_ALERT_PAGE }, false)
            })
          Button('同意')
            .layoutWeight(1)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.multi_color_aux_01'))
            .onClick(() => {
              PreferenceUtil.getInstance().put(PreferConstant.PRIVACY_POLICY_KEY, '1')
              RouterModule.replace({ url: RouterMap.MAIN_ENTRY })
            })
        }.margin({ top: $r('app.float.vp_16') })
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .width('100%')
      .height(this.getUIContext().px2vp(this.pageSize.height))
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(this.windowSize.windowStatusType === 5 ? EdgeEffect.Spring : EdgeEffect.None)
    .width('100%')
    .height(this.contentHeight)
  }

  @Builder
  otherScreen() {
    Column() {
      Image($r('app.media.icon'))
        .height($r('app.float.vp_72'))
        .width($r('app.float.vp_72'))
        .borderRadius($r('app.float.vp_16'))
        .margin({ top: $r('app.float.vp_158') })
      Text('拍照美化')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Title_L'))
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: $r('app.float.vp_24') })
      Text('业务描述')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: $r('app.float.vp_2') })
      Blank()
        .layoutWeight(1)
      Image($r('app.media.ic_me_security_shield'))
        .height($r('app.float.vp_24'))
        .width($r('app.float.vp_24'))
      Text('隐私协议') {
        Span('本应用需')
        Span('联网')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Span('，调用')
        Span('XX')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Span('、')
        Span('XX')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Span('权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
        Span('XX业务与隐私的声明、权限使用说明')
          .fontWeight(FontWeight.Medium)
          .fontColor('#4B5CC4')
          .onClick(() => {
            RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE, param: true })
          })
        Span('。')
      }
      .fontColor($r('sys.color.font_secondary')).margin({ top: 16 })
      .fontSize($r('sys.float.Caption_M'))

      Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Caption_M'))
        .margin({ top: 4 })

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_ALERT_PAGE }, false)
          })
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .fontColor($r('sys.color.font_on_primary'))
        Button('同意')
          .layoutWeight(1)
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .onClick(() => {
            PreferenceUtil.getInstance().put(PreferConstant.PRIVACY_POLICY_KEY, '1')
            RouterModule.replace({ url: RouterMap.MAIN_ENTRY })
          })
          .backgroundColor($r('sys.color.multi_color_aux_01'))
          .fontColor($r('sys.color.font_on_primary'))
      }.margin({ top: $r('app.float.vp_16') })
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_44') })
    .width('100%')
    .height(this.getUIContext().px2vp(this.pageSize.height))
  }

  build() {
    NavDestination(){
      Column() {
        if (this.windowSize.windowStatusType === 5) {
          this.splitScreen()
        } else {
          this.otherScreen()
        }
      }
      .width('100%')
      .height('100%')
    }.backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}