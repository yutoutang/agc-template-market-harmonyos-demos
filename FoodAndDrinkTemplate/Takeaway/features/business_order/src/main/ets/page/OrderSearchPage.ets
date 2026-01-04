import { CommonScroll, ContainerColumn, NavHeaderBar } from 'lib_widget';
import { buildButtonList, buildOrderInfoCard, buildShopOrderInfoCard } from '../components/OrderInfoCard';
import { buildNoOrderCard } from '../components/NoOrderCard';

import { OrderListPageVM } from '../viewModels/OrderListPageVM';
import { OrderItem } from 'lib_takeaway_api';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
struct OrderSearchPage {
  vm: OrderListPageVM = new OrderListPageVM();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '订单搜索'
      })

      this.buildSearch();

      CommonScroll({ bgColor: $r('app.color.background_color_grey') }) {
        if (this.vm.isLoading) {
          LoadingProgress().width($r('app.float.loading_icon_size'))
        } else {
          Column() {
            if (!this.vm.orderList.totalCount()) {
              buildNoOrderCard()
            } else {
              List() {
                LazyForEach(this.vm.orderList, (order: OrderItem) => {
                  ListItem() {
                    ContainerColumn() {
                      buildShopOrderInfoCard(order)
                      buildOrderInfoCard(order)
                      buildButtonList(order.orderInfo, ControlSize.SMALL, this.vm, (actionType) => {
                        this.vm.handleOrderItem(order, actionType)
                      })
                    }
                  }
                }, (item: OrderItem, index: number) => index + '__' + item.orderInfo.orderNo + item.orderInfo.status)
              }
              .layoutWeight(1)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .scrollBar(BarState.Off)
              .onReachEnd(() => {
                this.vm.getOrderList()
              })
            }
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
  }

  @Builder
  buildSearch() {
    Row() {
      Search({
        value: $$this.vm.searchKey,
        controller: this.vm.searchController,
        placeholder: '搜索订单号/店铺名/商品名',
      })
        .width('100%')
        .backgroundColor($r('app.color.background_color_white'))
        .borderColor($r('sys.color.font_fourth'))
        .defaultFocus(true)
        .placeholderColor($r('sys.color.font_secondary'))
        .caretStyle({ color: $r('sys.color.font_emphasize') })
        .onSubmit((value) => {
          if ((value === '' || value.trim() === '')) {
            //弹出提示
            promptAction.showToast({ message: '请输入搜索内容' })
          } else {
            this.vm.searchOrder(value);
          }
        })
    }
    .width($r('app.string.size_percent_full'))
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
    })
  }
}

@Builder
export function buildOrderSearchPage() {
  OrderSearchPage()
}


