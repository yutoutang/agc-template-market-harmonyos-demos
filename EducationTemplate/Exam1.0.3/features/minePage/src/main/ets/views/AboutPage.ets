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

import { Header } from '../components/Header'

// 关于
@ComponentV2
export struct AboutPage {
  @Local information: string = 'XX'
  @Local service: string = 'XX'
  @Local business: string = 'XX业务与隐私声明'

  build() {
    Column() {
      Header({ title: '关于' })
      Column() {
        Image($r('app.media.exam_icon_login'))
          .width($r('app.float.vp_72'))
          .height($r('app.float.vp_72'))
          .margin({ top: 141, bottom: $r('app.float.vp_24') })
        Text('备考')
          .fontSize($r('sys.float.Title_L'))
          .height($r('app.float.vp_40'))
          .fontWeight(FontWeight.Medium)
        Text('版本: 1.0.1')
          .fontSize($r('sys.float.Body_M'))
          .height($r('app.float.vp_19'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') })
      }
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))
      .width('100%')
      .height('100%')
    }
    .width('100%').height('100%')
  }
}

@Builder
export function AboutPageBuilder() {
  AboutPage()
}