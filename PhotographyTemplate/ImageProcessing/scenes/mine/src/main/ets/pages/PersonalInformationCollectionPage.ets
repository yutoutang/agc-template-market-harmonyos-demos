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

@ComponentV2
export struct PersonalInformationCollectionPage {

  build() {
    NavDestination(){
      Column() {
        TopBar({ title: $r('app.string.personal_information_collection_checklist') })
        Column(){
          Text($r('app.string.personal_information_collection_checklist'))
            .fontSize($r('sys.float.Title_S'))
            .height($r('app.float.vp_27'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: $r('app.float.vp_15'), bottom: $r('app.float.vp_15') })
          Text('华为 (以下简称我们) 会严格遵从国家的法规要求，将合法合规融入产品设计和业务流程中，' +
            '并采用业界先进的安全技术保证数据安全。\n' +
            '在新的服务需求及业务功能变更时，我们可能会调整我们收集信息的范围，并及时在本说明中向您说明情况。')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .height($r('app.float.vp_21'))
            .fontWeight(FontWeight.Regular)
        }
        .width('100%')
        .height('auto')

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

@Builder
export function PersonalInformationCollectionBuilder() {
  PersonalInformationCollectionPage()
}