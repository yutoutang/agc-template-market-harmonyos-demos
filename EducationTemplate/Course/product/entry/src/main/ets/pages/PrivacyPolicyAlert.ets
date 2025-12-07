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

import { common } from '@kit.AbilityKit'
import { PreferConstant, PreferenceUtil, RouterMap, RouterModule } from 'commonlib'

@ComponentV2
export struct PrivacyPolicyAlert {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明、权限使用说明。'
  private context = getContext(this) as common.UIAbilityContext

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.mask_fourth'))
      .opacity(0.4)

      Column() {
        Text('您需要同意协议才能体验功能')
          .lineHeight(27)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .margin({
            left: $r('app.float.vp_24'),
            right: $r('app.float.vp_24'),
            top: $r('app.float.vp_15'),
            bottom: $r('app.float.vp_15')
          })
        Column() {
          Text() {
            Span('本应用需')
            Span('联网')
              .fontColor($r('sys.color.font_primary'))
            Span('，调用')
            Span('XX')
              .fontColor($r('sys.color.font_primary'))
            Span('、')
            Span('XX')
              .fontColor($r('sys.color.font_primary'))
            Span('获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
            Span(this.business)
              .onClick(() => {
                RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })
              })
              .fontColor('#4B5CC4')
          }
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))

          Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_secondary'))
            .margin({ top: $r('app.float.vp_15') })
        }
        .height($r('app.float.vp_92'))
        .margin({ left: $r('app.float.vp_24'), right: $r('app.float.vp_24'), bottom: $r('app.float.vp_24') })

        Row() {
          Button('退出应用')
            .onClick(() => {
              this.context.terminateSelf()
            })
            .width($r('app.float.vp_140'))
            .height($r('app.float.vp_40'))
            .fontColor($r('sys.color.font_emphasize'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .margin({ right: $r('app.float.vp_16') })
          Button('同意并继续')
            .onClick(() => {
              PreferenceUtil.getInstance().put(PreferConstant.PRIVACY_POLICY_KEY, '1')
              RouterModule.replace({ url: RouterMap.LAUNCH_AD_PAGE })
            })
            .width($r('app.float.vp_140'))
            .height($r('app.float.vp_40'))
            .fontColor('sys.color.font_on_primary')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#4B5CC4')
        }
        .margin({ bottom: $r('app.float.vp_15') })
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.White)
      .borderRadius($r('app.float.vp_16'))
      .width('90%')
    }
    .height('100%').width('100%')
  }
}

@Builder
export function PrivacyPolicyAlertBuilder() {
  PrivacyPolicyAlert()
}