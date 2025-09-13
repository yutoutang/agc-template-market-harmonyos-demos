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

import { CourseCatalogModel } from 'http';

@ComponentV2
export struct CourseCatalogComponents {
  @Param selectedIndex: number = -1;
  @Param @Require catalogList: CourseCatalogModel[] = [];
  @Event clickCatalog: (indexNumber: number) => void;

  build() {
    Column() {
      List() {
        ForEach(this.catalogList, ((item: CourseCatalogModel, index: number) => {
          ListItem() {
            Row() {
              Text(index < 10 ? '0' + (index + 1) : index + '')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor(index === this.selectedIndex ? $r('sys.color.multi_color_01') :
                $r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Medium)
                .margin({ right: $r('app.float.vp_8') })

              Column() {
                Row() {
                  Text(item.catalogTitle)
                    .fontSize($r('sys.float.Subtitle_M'))
                    .fontColor(index === this.selectedIndex ? $r('sys.color.multi_color_01') :
                    $r('sys.color.font_primary'))
                    .fontWeight(FontWeight.Medium)
                  Blank()
                    .layoutWeight(1)
                  Image($r('app.media.right_icon'))
                    .width($r('app.float.vp_7'))
                    .height($r('app.float.vp_14'))
                }
                .layoutWeight(1)

                Text(`学习进度${item.isStudyEnd ? 100 : item.learnProgress}%`)
                  .fontSize($r('sys.float.Caption_L'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Regular)
                  .height($r('app.float.vp_18'))
                  .margin({ top: $r('app.float.vp_4') })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .padding({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
            .width('100%')
            .height($r('app.float.vp_64'))
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Top)
            .onClick(() => {
              // 点击时切换该项的选中状态
              this.clickCatalog(index)
            })
          }
          .width('100%')
          .height($r('app.float.vp_64'))

          Divider().color($r('sys.color.comp_divider'))
        }), (item: CourseCatalogModel, index: number) => item.catalogTitle + index)
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('auto')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding($r('app.float.vp_12'))
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
  }
}