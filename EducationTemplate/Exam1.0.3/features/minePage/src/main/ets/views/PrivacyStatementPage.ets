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

// 隐私声明
@ComponentV2
export struct PrivacyStatementPage {
  build() {
    Column() {
      Header({ title: '隐私声明' })
      Column() {
        Text('XX业务与隐私的声明')
          .fontSize($r('sys.float.Title_S'))
          .height($r('app.float.vp_27'))
          .fontWeight(FontWeight.Bold)
          .margin({ top: $r('app.float.vp_15'), bottom: $r('app.float.vp_15') })
          .textAlign(TextAlign.Center)
          .width('100%')

        Text('生效时间：2024-08-13 12:00:00')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .height($r('app.float.vp_19'))
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: $r('app.float.vp_16') })
          .width('100%')

        Text(' XX是（功能介绍）。华为非常重视您的个人信息和隐私保护，我们将会按照法律要求和业界成熟的安全标准，为您的个人信息提供相应的保护措施。\n\n ' +
          '1、我们如何收集和使用您的个人信息 \n\n' +
          '...... \n\n' +
          '4、对儿童的保护 \n\n' +
          '5、与第三方共享（共享） \n\n' +
          '6、管理您的数据 \n\n' +
          '7、数据存储地点及期限 \n\n' +
          '8、如何联系我们 \n\n' +
          '华为将始终遵照我们的隐私政策来收集和使用您的信息。有关我们的隐私政策，可参阅华为消费者业务隐私声明。')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .height($r('app.float.vp_19'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: $r('app.float.vp_16') })
          .textAlign(TextAlign.Start)
          .width('100%')

      }
      .width('100%')
      .padding(16)
    }.width('100%').height('100%')
  }
}

@Builder
export function PrivacyStatementPageBuilder() {
  PrivacyStatementPage()
}