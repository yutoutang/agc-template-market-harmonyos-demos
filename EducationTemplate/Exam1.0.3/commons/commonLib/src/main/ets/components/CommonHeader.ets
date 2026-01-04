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

import { RouterMap, RouterModule } from 'router_module';

@ComponentV2
export struct TopTabsBuilder {
  // 需要传入title标题,bgColor背景颜色,是否有返回键showBackButton
  @Param title: string = '';
  @Param bgColor: ResourceStr = $r('sys.color.background_secondary');
  @Param showBackButton: boolean = false;
  @Param type: string = '一级建造师';
  @Local index: number = 0;
  private topHeight: number = 56;

  build() {
    Row() {
      Row() {
        // 是否有返回键判断
        if (this.showBackButton) {
          Image($r('app.media.ic_backward')).height('40vp').width('40vp').margin({ right: '8vp' })
            .onClick(() => {
              RouterModule.pop()
            })
        }
        if (this.title === '练习') {
          Select([])
            .value(this.type)
            .font({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .space(8)
            .arrowPosition(ArrowPosition.END)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.Level_ONE_PAGE })
            })
        } else {
          Text(this.title)
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('60%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Row() {
          // 搜索
          Image($r('app.media.ic_search_01'))
            .height('24vp')
            .width('24vp')
            .onClick(() => {
              RouterModule.push({ url: RouterMap.SEARCH_PAGE, param: '' })
            })
        }
        .height('40vp')
        .width('40vp')
        .borderRadius(20)
        .margin({ right: '8vp' })
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('40%')
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor(this.bgColor)
    .height(this.topHeight)
    .width('100%')
  }
}