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

import { AppStorageV2 } from '@kit.ArkUI';
import { RouterMap, RouterModule } from 'router_module'
import { ThirdParam, ThirdCategory, ItemDetail } from 'select_category'
import { TopTabsBuilder } from 'commonlib';
import { Sample } from '../model/Course';

@ComponentV2
export struct ThirdListPage {
  @Local thirdParamObj?: ThirdParam;
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local prop: Sample = AppStorageV2.connect(Sample, () => new Sample())!;

  aboutToAppear(): void {
    this.thirdParamObj = (RouterModule.getNavParam({ url: RouterMap.Level_THREE_PAGE })) as ThirdParam
  }

  build() {
    Column() {
      // 标题组件
      TopTabsBuilder({ showBackButton: true, bgColor: $r('sys.color.background_primary') })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      Divider().color($r('sys.color.comp_divider'))
      // 三级分类组件
      ThirdCategory({
        thirdParamObj: this.thirdParamObj,
        currentColor: '#4B5CC4',
        contentIcon: $r('app.media.icon_right'),
        goPage: (val: string) => {
        },
        // 返回最后的对象 包含标题/id
        goBack: (val: ItemDetail) => {
          // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
          this.prop = AppStorageV2.connect(Sample, 'Sample', () => new Sample())!;
          this.prop.title = val.title
          this.prop.id = val.id
          RouterModule.popToName('MainPage')
        }
      })
    }
    .height('100%')
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function ThirdListBuilder() {
  ThirdListPage()
}