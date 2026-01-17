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

import { TopTabsBuilder } from 'commonlib';
import { RouterMap, RouterModule } from 'router_module';
import {
  BaseSelect,
  ContentItemModel,
  SelectItemModel,
  ThirdItemModel,
  SecondItemModel,
  ItemDetail,
  SecondParam
} from 'base_select';
import { LeftTab } from '../model/CommonTopic';
import { tabDataList } from '../model/TopicModel';

@ComponentV2
export struct TopicHomePage {
  @Local leftTabList: Array<LeftTab> = [];
  @Local baseSelectModel: Array<SelectItemModel> = [];

  aboutToAppear() {
    this.initDataSource();
  }

  // 初始化数据
  initDataSource() {
    this.leftTabList = tabDataList;
    // 数据结构封装，给到基础组件想要结构 -- 通用组件
    for (let index = 0; index < this.leftTabList.length; index++) {
      let selectContentModel: SelectItemModel = new SelectItemModel()
      let element = this.leftTabList[index];
      selectContentModel.id = element.id;
      selectContentModel.title = element.title
      let leftTabContentList: ContentItemModel[] = [];
      for (let index = 0; index < element.list.length; index++) {
        let elem = element.list[index];
        let item: ContentItemModel = new ContentItemModel()
        item.title = elem.title
        item.id = elem.id
        let secondList: SecondItemModel[] = []
        for (let index = 0; index < elem.list.length; index++) {
          let secondElem = elem.list[index]
          let item: SecondItemModel = new SecondItemModel()
          item.title = secondElem.title
          item.id = secondElem.id
          let thirdList: ThirdItemModel[] = [];
          for (let index = 0; index < secondElem.list.length; index++) {
            let thirdElem = secondElem.list[index]
            let item: ThirdItemModel = new ThirdItemModel()
            item.title = thirdElem.title
            item.id = thirdElem.id
            let detailList: ItemDetail[] = [];
            for (let index = 0; index < thirdElem.list.length; index++) {
              let detailElem = thirdElem.list[index]
              let item: ItemDetail = new ItemDetail()
              item.title = detailElem.title
              item.id = detailElem.id
              detailList.push(item)
            }
            item.list = detailList
            thirdList.push(item)
          }
          item.list = thirdList
          secondList.push(item)
        }
        item.list = secondList
        leftTabContentList.push(item)
      }
      selectContentModel.list = leftTabContentList
      this.baseSelectModel.push(selectContentModel)
    }
  }

  build() {
    Column() {
      // 题库标题组件
      TopTabsBuilder({ title: '题库', bgColor: $r('sys.color.background_primary'), showBackButton: true })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      Divider().color($r('sys.color.comp_divider'))
      //通用组件
      BaseSelect({
        modelList: this.baseSelectModel,
        selectIndex: (val: number) => {
        },
        goSecond: (val: SecondParam) => {
          //跳转到二级分类的数据
          RouterModule.push({ url: RouterMap.Level_TWO_PAGE, param: val })
        },
        selectLeftBgc: $r('sys.color.background_primary'),
        defaultLeftBgc: $r('sys.color.comp_background_gray'),
        contentIcon: $r('app.media.icon_right')
      })
        .layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
  }
}

@Component
export struct TopicPage {
  build() {
    Row() {
      Column() {
        TopicHomePage()
      }
      .width('100%')
    }
    .backgroundColor($r('sys.color.background_primary'))
    .height('100%')
  }
}

@Builder
export function TopicHomePageBuilder() {
  TopicPage()
}
