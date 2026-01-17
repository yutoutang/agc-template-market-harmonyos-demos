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

import { ThirdParam, ItemDetail } from '../model/SelectCateModel'

@ComponentV2
export struct ThirdCategory {
  @Param @Require thirdParamObj: ThirdParam
  @Local thirdDataList: string[] = [];
  @Local thirdContentsData: ItemDetail[] = [];
  @Param currentColor: ResourceStr = '#4B5CC4'
  @Param contentIcon: ResourceStr = $r('app.media.icon_right');
  @Event goPage: (x: string) => void = () => {
  };
  @Event goBack: (x: ItemDetail) => void = () => {
  };

  aboutToAppear(): void {
    this.initDataSource();
  }

  initDataSource() {
    this.thirdDataList = this.thirdParamObj.list
    this.thirdContentsData = this.thirdParamObj.thirdItem.list
  }

  build() {
    Column() {
      // 三级导航标题栏
      this.thirdTitleBarBuilder()
      // 三级导航内容
      this.thirdContentBuilder()
    }
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  /**
   * 三级导航内容
   */
  @Builder
  thirdContentBuilder() {
    Column() {
      ForEach(this.thirdContentsData, (item: ItemDetail) => {
        Row() {
          Text(item.title)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_L'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .maxLines(2)
            .layoutWeight(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .wordBreak(WordBreak.BREAK_ALL)
          Image(this.contentIcon)
            .width($r('app.float.vp_16'))
            .objectFit(ImageFit.Cover)
            .height($r('app.float.vp_16'))
            .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_12') });
        }
        .onClick(() => {
          // 返回页面
          this.goBack(item)
        })
        .backgroundColor($r('sys.color.comp_background_gray'))
        .borderRadius(10)
        .padding($r('app.float.vp_12'))
        .margin({ top: $r('app.float.vp_12') })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }, (item: string , index: number) => item + index);
    }.padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
  }

  /**
   * 三级导航标题栏
   */
  @Builder
  thirdTitleBarBuilder() {
    List() {
      ForEach(this.thirdDataList, (item: string) => {
        ListItem() {
          Row() {
            Text(item)
              .fontColor(this.thirdDataList[this.thirdDataList?.length-1] === item ? this.currentColor :
              $r('sys.color.font_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(this.thirdDataList[this.thirdDataList?.length-1] === item ? FontWeight.Medium :
              FontWeight.Regular)
              .margin({ right: $r('app.float.vp_6') })
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: '30%' })
              .maxLines(1)
              .onClick(() => {
                this.goPage(item)
              })
            if (this.thirdDataList[this.thirdDataList?.length-1] !== item) {
              Image($r('app.media.icon_right'))
                .width($r('app.float.vp_14'))
                .objectFit(ImageFit.Cover)
                .height($r('app.float.vp_14'))
            }
          }.margin({ right: $r('app.float.vp_5') })
        }
      }, (item: string, idx: number) => item + idx);
    }
    .padding({ top: $r('app.float.vp_12'), left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .scrollBar(BarState.Off)
    .width('100%')
    .listDirection(Axis.Horizontal)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .height($r('app.float.vp_40'))
  }
}
