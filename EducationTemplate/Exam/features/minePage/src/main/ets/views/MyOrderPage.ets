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

import { Header } from '../components/Header';
import { OrderListPage, OrderListType } from './OrderListPage';

@Builder
export function MyOrderBuilder() {
  MyOrderPage();
}

@ComponentV2
export struct MyOrderPage {
  @Local currentIndex: number = 0;
  @Local selectedIndex: number = 0;
  private controller: TabsController = new TabsController();

  //订单的tabBar
  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.selectedIndex === index ? $r('sys.color.multi_color_08') : $r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(this.selectedIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .margin({ top: 17, bottom: 7 })
      Divider()
        .strokeWidth(2)
        .width(20)
        .color($r('sys.color.multi_color_08'))
        .opacity(this.selectedIndex === index ? 1 : 0)
    }
    .width('100%')
    .height(44)
  }

  build() {
    Column() {
      Header({ title: '我的订单' })
      Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          OrderListPage({ orderType: OrderListType.All, currentIndex: this.currentIndex })
        }.tabBar(this.tabBuilder(0, '全部'))

        TabContent() {
          OrderListPage({ orderType: OrderListType.WaitToPay, currentIndex: this.currentIndex })
        }.tabBar(this.tabBuilder(1, '待支付'))

        TabContent() {
          OrderListPage({ orderType: OrderListType.Paid, currentIndex: this.currentIndex })
        }.tabBar(this.tabBuilder(2, '已支付'))

        TabContent() {
          OrderListPage({ orderType: OrderListType.Cancelled, currentIndex: this.currentIndex })
        }.tabBar(this.tabBuilder(3, '已取消'))
      }
      .vertical(false)
      .barMode(BarMode.Fixed) //超过总宽度后可滑动
      .barHeight(44)
      .animationDuration(400)
      .onChange((index: number) => {
        // currentIndex控制TabContent显示页签
        this.currentIndex = index;
        this.selectedIndex = index;
      })
    }
    .width('100%')
    .height('100%')
  }
}
