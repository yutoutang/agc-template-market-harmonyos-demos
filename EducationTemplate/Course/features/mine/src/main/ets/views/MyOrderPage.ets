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

import { OrderListPage, OrderListType } from './OrderListPage';
import { TopBar, MyScrollModifier } from 'commonlib';

@Builder
export function MyOrderBuilder() {
  MyOrderPage();
}

@ComponentV2
export struct MyOrderPage {
  @Local currentIndex: number = 0;
  @Local selectedIndex: number = 0;
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  private controller: TabsController = new TabsController();

  //订单的tabBar
  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(this.selectedIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .margin({ top: $r('app.float.vp_17'), bottom: $r('app.float.vp_7') })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r('sys.color.comp_background_emphasize'))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
    .height(45)
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      TopBar({ title: $r('app.string.my_order') })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
      Column() {
        this.topBuilder()
        Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
          TabContent() {
            OrderListPage({ orderType: OrderListType.ALL, currentIndex: this.currentIndex })
          }.tabBar(this.tabBuilder(0, '全部'))

          TabContent() {
            OrderListPage({ orderType: OrderListType.WAIT_TO_PAY, currentIndex: this.currentIndex })
          }.tabBar(this.tabBuilder(1, '待支付'))

          TabContent() {
            OrderListPage({ orderType: OrderListType.PAID, currentIndex: this.currentIndex })
          }.tabBar(this.tabBuilder(2, '已支付'))

          TabContent() {
            OrderListPage({ orderType: OrderListType.CANCELLED, currentIndex: this.currentIndex })
          }.tabBar(this.tabBuilder(3, '已取消'))
        }
        .vertical(false)
        .barMode(BarMode.Fixed) //超过总宽度后可滑动
        .barHeight(44)
        .animationDuration(0)
        .backgroundColor($r('sys.color.background_secondary'))
        .onChange((index: number) => {
          // currentIndex控制TabContent显示页签
          this.currentIndex = index;
          this.selectedIndex = index;
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
  }
}