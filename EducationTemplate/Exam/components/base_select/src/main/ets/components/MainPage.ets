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
  ContentItemModel,
  SelectItemModel,
  ThirdItemModel,
  SecondItemModel,
  ItemDetail,
  SecondParam
} from '../model/SelectModel';

@ComponentV2
struct BaseSelect {
  @Param @Require modelList: SelectItemModel[] = [];
  @Local modelContentList: ContentItemModel[] = [];
  @Local selectedLeft: number = 0;
  @Event selectIndex: (x: number) => void = () => {
  };
  @Event goSecond: (x: SecondParam) => void = () => {
  };
  @Param defaultLeftBgc: ResourceStr = $r('sys.color.background_secondary');
  @Param contentIcon: ResourceStr = $r('app.media.icon_right');

  aboutToAppear(): void {
    this.modelContentList = this.modelList[this.selectedLeft].list;
  }

  build() {
    Column() {
      Row() {
        this.buildLeftTabBar();
        this.buildLeftTabContentView();
      }
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width('100%')
      .height('100%');
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .layoutWeight(1);
  }

  @Builder
  buildLeftTabBar() {
    if (this.modelList && this.modelList.length > 0) {
      List() {
        ForEach(this.modelList, (leftTab: SelectItemModel, idx: number) => {
          ListItem() {
            Row() {
              Row() {
              }
              .width(4)
              .height('80%')
              .margin({ right: $r('app.float.vp_25') })
              .borderWidth({ left: this.selectedLeft === idx ? 4 : 0 })
              .borderColor('#4B5CC4')
              .borderRadius({ topRight: $r('app.float.vp_4'), bottomRight: $r('app.float.vp_4') });

              Text(leftTab.title)
                .textAlign(TextAlign.Start)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_ALL)
                .maxLines(2)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
                .fontSize($r('sys.float.Caption_L'))
                .layoutWeight(1);
            }
            .width('100%')
            .height($r('app.float.vp_40'))
            .backgroundColor(this.selectedLeft === idx ?
              $r('sys.color.comp_background_primary') : this.defaultLeftBgc)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.refreshRightDate(leftTab, idx);
              // 抛出选中索引
              this.selectIndex(this.selectedLeft);
            });
          }
          .width('100%');
        }, (leftTab: SelectItemModel, idx: number) => leftTab.title + idx);
      }
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.Off)
      .width('30%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
  }

  @Builder
  buildLeftTabContentView() {
    if (this.modelContentList && this.modelContentList.length > 0) {
      List({ space: 2 }) {
        ForEach(this.modelContentList, (leftTabContent: ContentItemModel) => {
          ListItem() {
            Column() {
              Text(leftTabContent.title)
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: $r('app.float.vp_10'), left: $r('app.float.vp_10'), bottom: $r('app.float.vp_10') })
                .fontWeight(FontWeight.Medium)
                .fontSize($r('sys.float.Body_L'));

              ForEach(leftTabContent.list, (secondItem: SecondItemModel) => {
                Row() {
                  Text(secondItem.title)
                    .fontColor($r('sys.color.font_primary'))
                    .fontSize($r('sys.float.Caption_L'))
                    .fontWeight(FontWeight.Regular)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .textAlign(TextAlign.Start);

                  Image(this.contentIcon)
                    .width($r('app.float.vp_16'))
                    .height($r('app.float.vp_16'))
                    .objectFit(ImageFit.Cover)
                    .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_12') });
                }
                .backgroundColor($r('sys.color.comp_background_tertiary'))
                .borderRadius($r('app.float.vp_10'))
                .width('100%')
                .padding($r('app.float.vp_12'))
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: $r('app.float.vp_12') })
                .onClick(() => {
                  // 跳转二级列表页
                  let list: string[] = [];
                  list.push(this.modelList[this.selectedLeft].title);
                  list.push(leftTabContent.title);
                  list.push(secondItem.title);
                  let secondParamObj: SecondParam = new SecondParam(list, secondItem);
                  this.goSecond(secondParamObj);
                });
              }, (secondItem: SecondItemModel) => secondItem.id);
            }
            .padding({
              left: $r('app.float.vp_8'),
              right: $r('app.float.vp_16'),
              top: $r('app.float.vp_2'),
              bottom: $r('app.float.vp_2')
            })
            .width('100%')
            .alignItems(HorizontalAlign.Start);
          }
          .width('100%');
        }, (leftTabContent: ContentItemModel, idx: number) => leftTabContent.title + idx);
      }
      .layoutWeight(1)
      .borderRadius({
        topLeft: 0,
        topRight: $r('app.float.vp_16'),
        bottomRight: $r('app.float.vp_16'),
        bottomLeft: $r('app.float.vp_16'),
      })
      .backgroundColor($r('sys.color.comp_background_primary'))
      .width('auto')
      .height('auto')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
  }

  // 切换左侧tabBar
  refreshRightDate(leftTab: SelectItemModel, index: number) {
    this.selectedLeft = index;
    this.modelContentList = leftTab.list;
  }
}

export { BaseSelect, ContentItemModel, SelectItemModel, ThirdItemModel, SecondItemModel, ItemDetail, SecondParam };