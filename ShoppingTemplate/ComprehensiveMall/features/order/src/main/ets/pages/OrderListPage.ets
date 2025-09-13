import { RouterMap, routerStack } from 'lib_foundation'
import { ContainerColumn, NavTitleBar } from 'lib_widget';
import { OrderItem } from 'lib_network';
import { ORDER_TAB_LIST } from '../common/Constants';
import { OrderTabsMap } from '../common/Enums';
import { OrderType } from '../common/Types';
import { buildNoOrderCard } from '../components/NoOrderCard';
import { buildButtonList, buildOrderInfoCard } from '../components/OrderInfoCard';
import { OrderListPageVM } from '../viewModels/OrderListPageVM';

@Builder
export function buildOrderListPage() {
  OrderListPageNew()
}

@ComponentV2
export struct OrderListPageNew {
  vm: OrderListPageVM = new OrderListPageVM();

  build() {
    NavDestination() {
      NavTitleBar({
        title: '我的订单',
        showSearchIcon: true,
        bgColor: $r('app.color.background_color_white'),
        onSearchClick: () => {
          routerStack.pushPath({ name: RouterMap.ORDER_SEARCH })
        },
      })
      this.buildSearchBar()
      this.buildOrderTab()
    }
    .hideTitleBar(true)
    .onReady((context) => {
      const index = context.pathInfo.param as number|undefined
      this.vm.initOrderTab(index??0)
    })
  }

  @Builder
  buildSearchBar() {
    Row() {
      Row() {
        Image($r('app.media.ic_search'))
          .width(16)
          .fillColor($r('app.color.font_color_level2'))
          .margin({ right: $r('app.float.space_s') })
        Text('搜索订单')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
      }
      .width($r('app.string.size_percent_full'))
      .backgroundColor($r('app.color.background_color_grey'))
      .borderRadius($r('app.float.border_radius_capsule'))
      .padding({
        top: $r('app.float.space_s'),
        bottom: $r('app.float.space_s'),
        left: $r('app.float.space_m'),
        right: $r('app.float.space_m'),
      })
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
      bottom: $r('app.float.space_m'),
      top: $r('app.float.space_m'),
    })
    .onClick(() => {
      routerStack.pushPath({ name: RouterMap.ORDER_SEARCH })
    })
  }

  @Builder
  buildOrderTab() {
    Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
      ForEach(ORDER_TAB_LIST, (tab: OrderType, index: number) => {
        TabContent() {
          Column() {
            if (this.vm.isLoading) {
              LoadingProgress().width(32)
            } else if (this.vm.currentIndex === index && !this.vm.isLoading) {
              if (index === OrderTabsMap.REVIEW) {
                this.buildReviewOrderList()
              } else {
                this.buildCommonOrderList(index)
              }
            }
          }
          .layoutWeight(1)
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .tabBar(this.buildTabBarItem(tab.label, index))
        .layoutWeight(1)
        .align(Alignment.Top)
        .width($r('app.string.size_percent_full'))
        .backgroundColor($r('app.color.background_color_grey'))
        .padding({
          left: $r('app.float.space_l'),
          right: $r('app.float.space_l'),
          top: $r('app.float.space_l'),
        })
      }, (_tab: OrderType, index: number) => index.toString())
    }
    .width($r('app.string.size_percent_full'))
    .layoutWeight(1)
    .vertical(false)
    .barHeight(42)
    .animationDuration(0)
    .barMode(BarMode.Scrollable)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onChange((index) => {
      this.vm.changeTab(index)
    })
  }

  @Builder
  buildCommonOrderList(tabIndex: number) {
    Refresh({ refreshing: this.vm.isRefreshing }) {
      Column() {
        if (!this.vm.orderList.totalCount() && !this.vm.isRefreshing) {
          buildNoOrderCard(tabIndex === 0)
        } else {
          List() {
            LazyForEach(this.vm.orderList, (order: OrderItem) => {
              ListItem() {
                ContainerColumn() {
                  buildOrderInfoCard(order)
                  buildButtonList(order.orderInfo, ControlSize.SMALL, (actionType) => {
                    this.vm.handleOrderItem(order, actionType)
                  })
                }
              }
            }, (item: OrderItem, index: number) => index + '__' + JSON.stringify(item.orderInfo))
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .scrollBar(BarState.Off)
          .onReachEnd(() => {
            this.vm.getOrderList()
          })
        }
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onRefreshing(() => {
      this.vm.refreshOrderList()
    })
  }

  @Builder
  buildReviewOrderList() {
    Column() {
      Row() {
        Text('待评价')
          .reviewTabStyle(this.vm.reviewTabIndex === 0)
          .onClick(() => {
            this.vm.switchReviewTab(0)
          })
        Text('已评价')
          .reviewTabStyle(this.vm.reviewTabIndex === 1)
          .onClick(() => {
            this.vm.switchReviewTab(1)
          })
      }
      .width($r('app.string.size_percent_full'))
      .margin({ bottom: $r('app.float.space_m') })
      .justifyContent(FlexAlign.End)

      this.buildCommonOrderList(OrderTabsMap.REVIEW)
    }
  }

  @Builder
  buildTabBarItem(name: string, index: number) {
    Column() {
      Text(name)
        .fontColor(this.vm.currentIndex === index ? $r('app.color.theme_color') :
          $r('app.color.font_color_level1'))
        .fontSize($r('app.float.font_size_14'))
        .fontWeight(400)
        .lineHeight(22)
        .margin({ top: $r('app.float.space_s'), bottom: $r('app.float.space_s') });
      Row()
        .height(3)
        .width(20)
        .backgroundColor($r('app.color.theme_color'))
        .borderRadius($r('app.float.border_radius_capsule'))
        .opacity(this.vm.currentIndex === index ? 1 : 0);
    }
    .backgroundColor($r('app.color.background_color_white'))
    .padding({
      left: $r('app.float.space_m'),
      right: $r('app.float.space_m'),
    })
  }
}

@Extend(Text)
function reviewTabStyle(isSelected: boolean) {
  .fontSize($r('app.float.font_size_14'))
  .fontWeight(FontWeight.Medium)
  .margin({ left: $r('app.float.space_m') })
  .fontColor(isSelected ? $r('app.color.theme_color') : $r('app.color.font_color_level1'))
}