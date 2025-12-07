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
  SelectRoleModel,
  OneLevelTabContent,
  TwoLevelTabContent,
  ThreeLevelTabContent,
  RoleDetail,
} from '../model/SelectModel'

@ComponentV2
export struct RolePage {
  @Param @Require options: SelectRoleModel[] = []
  @Local oneLevelRoleList: OneLevelTabContent[] = []
  @Local twoLevelRoleList: TwoLevelTabContent[] = []
  @Local threeLevelRoleList: ThreeLevelTabContent[] = []
  @Local lastRoleList: RoleDetail[] = []
  @Local dataArr: [] = []
  @Local selectLevelNumber: number = 1
  @Local oneLevelText: string = ''
  @Local twoLevelText: string = ''
  @Local threeLevelText: string = ''
  @Event selectRoleText: (roleText: string) => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text(this.oneLevelText)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .height($r('app.float.vp_19'))
          .margin({ right: $r('app.float.vp_16'), top: $r('app.float.vp_3') })
          .visibility(this.selectLevelNumber > 1 ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.selectLevelNumber = 1
          })
        Text(this.twoLevelText)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .height($r('app.float.vp_19'))
          .margin({ right: $r('app.float.vp_16'), top: $r('app.float.vp_3') })
          .visibility(this.selectLevelNumber > 2 ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.selectLevelNumber = 2
          })
        Text(this.threeLevelText)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .height($r('app.float.vp_19'))
          .margin({ right: $r('app.float.vp_16'), top: $r('app.float.vp_3') })
          .visibility(this.selectLevelNumber > 3 ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.selectLevelNumber = 3
          })
        Column() {
          Text('请选择')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.multi_color_01'))
            .height($r('app.float.vp_19'))
          Row()
            .backgroundColor($r('sys.color.multi_color_01'))
            .width($r('app.float.vp_50'))
            .height($r('app.float.vp_1'))
            .position({ bottom: $r('app.float.vp_1') })
        }
        .width($r('app.float.vp_50'))
        .height($r('app.float.vp_30'))
        .margin({ top: $r('app.float.vp_3') })
      }
      .width('100%')
      .height($r('app.float.vp_30'))
      .alignItems(VerticalAlign.Top)

      if (this.selectLevelNumber === 1) {
        this.roleItemBuilder()
      } else if (this.selectLevelNumber === 2) {
        this.roleTwoLevelItemBuilder()
      } else if (this.selectLevelNumber === 3) {
        this.roleThreeLevelItemBuilder()
      } else if (this.selectLevelNumber === 4) {
        this.roleLastLevelItemBuilder()
      }
    }
    .padding({
      left: $r('app.float.vp_12'),
      right: $r('app.float.vp_12'),
      top: $r('app.float.vp_10'),
      bottom: $r('app.float.vp_62')
    })
  }

  @Builder
  roleItemBuilder() {
    List() {
      ForEach(this.options, ((item: SelectRoleModel) => {
        ListItem() {
          Row() {
            this.textBuilder(item.title)
          }
          .width('100%')
          .height($r('app.float.vp_48'))
          .onClick(() => {
            this.oneLevelText = item.title;
            this.selectLevelNumber = 2;
            this.oneLevelRoleList = item.list
          })
        }
        .width('100%')
        .height($r('app.float.vp_48'))

        Divider().color($r('sys.color.comp_divider'))
      }), (item: SelectRoleModel, index: number) => item.title + index)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height('auto')
  }

  @Builder
  roleTwoLevelItemBuilder() {
    List() {
      ForEach(this.oneLevelRoleList, ((item: OneLevelTabContent) => {
        ListItem() {
          Row() {
            this.textBuilder(item.title)
          }
          .width('100%')
          .height($r('app.float.vp_48'))
          .onClick(() => {
            this.twoLevelText = item.title;
            this.selectLevelNumber = 3;
            this.twoLevelRoleList = item.list
          })
        }
        .width('100%')
        .height($r('app.float.vp_48'))

        Divider().color($r('sys.color.comp_divider'))
      }), (item: SelectRoleModel, index: number) => item.title + index)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height('auto')
  }

  @Builder
  roleThreeLevelItemBuilder() {
    List() {
      ForEach(this.twoLevelRoleList, ((item: TwoLevelTabContent) => {
        ListItem() {
          Row() {
            this.textBuilder(item.title)
          }
          .width('100%')
          .height($r('app.float.vp_48'))
          .onClick(() => {
            this.threeLevelText = item.title;
            this.selectLevelNumber = 4;
            this.threeLevelRoleList = item.list
          })
        }
        .width('100%')
        .height($r('app.float.vp_48'))

        Divider().color($r('sys.color.comp_divider'))
      }), (item: SelectRoleModel, index: number) => item.title + index)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height('auto')
  }

  @Builder
  roleLastLevelItemBuilder() {
    List() {
      ForEach(this.threeLevelRoleList, ((item: ThreeLevelTabContent) => {
        ListItem() {
          Row() {
            this.textBuilder(item.title)
          }
          .width('100%')
          .height($r('app.float.vp_48'))
          .onClick(() => {
            //选中具体角色
            this.selectRoleText(item.title)
          })
        }
        .width('100%')
        .height($r('app.float.vp_48'))

        Divider().color($r('sys.color.comp_divider'))
      }), (item: SelectRoleModel, index: number) => item.title + index)
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height('auto')
  }

  @Builder
  textBuilder(title: string) {
    Text(title)
      .fontSize($r('sys.float.Subtitle_S'))
      .fontColor($r('sys.color.font_primary'))
      .fontWeight(FontWeight.Regular)
    Blank()
    Image($r('app.media.right_icon'))
      .width($r('app.float.vp_7'))
      .height($r('app.float.vp_14'))
  }
}