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

import {
  RolePage,
  SelectRoleModel,
  OneLevelTabContent,
  TwoLevelTabContent,
  ThreeLevelTabContent,
  RoleDetail
} from 'classification';
import { RouterMap, RouterModule } from 'commonlib'
import { ROLE_DATA, LeftTab } from '../models/SelectRoleModel'

@ComponentV2
export struct HomeTop {
  @Param type: string = '建造师';
  @Event selectRole: () => void = () => {
  };

  build() {
    Row() {
      Select([])
        .value(this.type)
        .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
        .space(8)
        .arrowPosition(ArrowPosition.END)
        .onClick(() => {
          // 角色切换
          this.selectRole();
        })

      Image($r('app.media.icon_search_home'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .onClick(() => {
          // 搜索
          RouterModule.push({ url: RouterMap.SEARCH_PAGE })
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_56'))
    .width('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }
}

@ComponentV2
export struct SelectRoleItem {
  @Local roleList: Array<LeftTab> = [];
  @Local baseSelectModel: Array<SelectRoleModel> = [];
  @Local dataArr: [] = []
  @Local selectLevelNumber: number = 1
  @Local oneLevelText: string = ''
  @Local twoLevelText: string = ''
  @Local threeLevelText: string = ''
  @Event changeRoleText: (roleText: string) => void = () => {
  };

  aboutToAppear() {
    this.initDataSource();
  }

  // 初始化数据
  initDataSource() {
    this.roleList = ROLE_DATA;
    // 数据结构封装，给到基础组件想要结构 -- 通用组件
    for (let index = 0; index < this.roleList.length; index++) {
      let selectContentModel: SelectRoleModel = new SelectRoleModel()
      let element = this.roleList[index];
      selectContentModel.id = element.id;
      selectContentModel.title = element.title
      let leftTabContentList: OneLevelTabContent[] = [];
      for (let index = 0; index < element.list.length; index++) {
        let elem = element.list[index];
        let item: OneLevelTabContent = new OneLevelTabContent()
        item.title = elem.title
        item.id = elem.id
        let secondList: TwoLevelTabContent[] = []
        for (let index = 0; index < elem.list.length; index++) {
          let secondElem = elem.list[index]
          let item: TwoLevelTabContent = new TwoLevelTabContent()
          item.title = secondElem.title
          item.id = secondElem.id
          let thirdList: ThreeLevelTabContent[] = [];
          for (let index = 0; index < secondElem.list.length; index++) {
            let thirdElem = secondElem.list[index]
            let item: ThreeLevelTabContent = new ThreeLevelTabContent()
            item.title = thirdElem.title
            item.id = thirdElem.id
            let detailList: RoleDetail[] = [];
            for (let index = 0; index < thirdElem.list.length; index++) {
              let detailElem = thirdElem.list[index]
              let item: RoleDetail = new RoleDetail()
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
      RolePage({
        options: this.baseSelectModel,
        selectRoleText: (roleText: string) => { //角色切换
          this.changeRoleText(roleText)
        }
      })
    }
  }
}