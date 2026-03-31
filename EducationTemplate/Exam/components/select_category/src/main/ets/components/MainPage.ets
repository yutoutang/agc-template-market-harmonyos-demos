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

import { SecondParam, ThirdItemModel, ThirdParam } from '../model/SelectCateModel';

@ComponentV2
export struct SelectCategory {
  @Param @Require secondParamObj: SecondParam;
  @Local secondDataList: string[] = [];
  @Local contentData?: ThirdItemModel[];
  @Param currentColor: ResourceStr = '#4B5CC4';
  @Param contentIcon: ResourceStr = $r('app.media.icon_right');
  @Event goPage: (x: string) => void = () => {
  };
  @Event goThird: (x: ThirdItemModel) => void = () => {
  };

  aboutToAppear(): void {
    this.initDataSource();
  }

  initDataSource() {
    this.secondDataList = this.secondParamObj.list;
    this.contentData = this.secondParamObj.secondItem.list;
  }

  build() {
    Column() {
      // 二级导航标题栏
      this.titleBarBuilder();
      // 二级导航内容
      this.contentBuilder();
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .layoutWeight(1);
  }

  /**
   * 内容
   */
  @Builder
  contentBuilder() {
    Column() {
      ForEach(this.contentData, (item: ThirdItemModel) => {
        Row() {
          Text(item.title)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Image(this.contentIcon)
            .objectFit(ImageFit.Cover)
            .width($r('app.float.vp_16'))
            .height($r('app.float.vp_16'))
            .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_12') });
        }
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding($r('app.float.vp_12'))
        .borderRadius(10)
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: $r('app.float.vp_12') })
        .onClick(() => {
          // 跳转三级列表页
          this.goThird(item);
        });
      }, (item: string, index: number) => item + index);
    }
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .layoutWeight(1)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 二级导航标题栏
   */
  @Builder
  titleBarBuilder() {
    List() {
      ForEach(this.secondDataList, (item: string) => {
        ListItem() {
          Row() {
            Text(item)
              .fontColor(this.secondDataList[this.secondDataList.length-1] === item ? this.currentColor :
                $r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(this.secondDataList[this.secondDataList.length-1] === item ? FontWeight.Medium :
                FontWeight.Regular)
              .textAlign(TextAlign.Start)
              .margin({ right: $r('app.float.vp_6') })
              .wordBreak(WordBreak.BREAK_ALL)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: '30%' })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => {
                this.goPage(item);
              });
            if (this.secondDataList[this.secondDataList?.length-1] !== item) {
              Image($r('app.media.icon_right'))
                .objectFit(ImageFit.Cover)
                .width($r('app.float.vp_14'))
                .height($r('app.float.vp_14'));
            }
          }.margin({ right: $r('app.float.vp_5') });
        };
      }, (item: string, idx: number) => item + idx);
    }
    .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .height($r('app.float.vp_40'))
    .width('100%');
  }
}

export { ThirdParam, ThirdItemModel };
