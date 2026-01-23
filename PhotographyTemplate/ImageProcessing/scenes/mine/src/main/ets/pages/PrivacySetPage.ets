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

import { TopBar } from 'commonlib';
import { RouterMap, RouterModule } from 'commonlib'

@ComponentV2
export struct PrivacySetPage {
  build() {
    NavDestination(){
      Column() {
        TopBar({ title: $r('app.string.privacy_set') })
        setPrivacyItem()
        setInformationItem()
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .height('100%')
    } .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }
}

//用户协议+隐私政策
@ComponentV2
struct setPrivacyItem {
  build() {
    Column() {
      Row() {
        Text($r('app.string.user_agreement'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.forward'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        // 跳转用户协议
        RouterModule.push({ url: RouterMap.USER_AGREEMENT })
      })

      Row() {
        Text($r('app.string.privacy_policy'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.forward'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        //  跳转隐私政策
        RouterModule.push({ url: RouterMap.PRIVACY_STATEMENT_PAGE })

      })
    }
    .width('100%')
    .height('auto')
    .margin({ bottom: $r('app.float.vp_12') })
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .borderRadius(16)
  }
}

//第三方信息共享清单+个人信息收集清单
@ComponentV2
struct setInformationItem {
  build() {
    Column() {
      Row() {
        Text($r('app.string.third_party_information_sharing'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.forward'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        //  跳转第三方信息共享清单
        RouterModule.push({ url: RouterMap.DATA_SHARING_PAGE })
      })

      Row() {
        Text($r('app.string.personal_information_collection_checklist'))
          .fontSize($r('sys.float.Subtitle_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Blank()
        Image($r('app.media.forward'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_24'))
      }
      .width('100%')
      .height($r('app.float.vp_48'))
      .onClick(() => {
        // 跳转个人信息收集清单
        RouterModule.push({ url: RouterMap.PERSONAL_INFORMATION_PAGE })

      })
    }
    .width('100%')
    .height('auto')
    .margin({ bottom: $r('app.float.vp_12') })
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
    .borderRadius(16)
  }
}

@Builder
export function PrivacySetPageBuilder() {
  PrivacySetPage()
}