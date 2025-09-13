import { CommonScroll, ContainerColumn, NavTitleBar } from 'lib_widget';
import { buildButtonList, buildOrderInfoCard } from '../components/OrderInfoCard';
import { buildNoOrderCard } from '../components/NoOrderCard';
import { OrderItem } from 'lib_network';
import { OrderListPageVM } from '../viewModels/OrderListPageVM';

@ComponentV2
struct OrderSearchPage {
  vm: OrderListPageVM = new OrderListPageVM();

  build() {
    NavDestination() {
      NavTitleBar({
        title: '订单搜索',
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
                      buildOrderInfoCard(order)
                      buildButtonList(order.orderInfo, ControlSize.SMALL, (actionType) => {
                        this.vm.handleOrderItem(order, actionType)
                      })
                    }
                  }
                }, (item: OrderItem, index: number) => index + '__' + item.orderInfo.orderNo + item.orderInfo.status)
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
        placeholder: '输入商品名称',
      })
        .width('100%')
        .backgroundColor($r('app.color.background_color_white'))
        .borderColor($r('sys.color.font_fourth'))
        .defaultFocus(true)
        .placeholderColor($r('sys.color.mask_secondary'))
        .caretStyle({ color: $r('app.color.theme_color') })
        .onSubmit((value) => {
          this.vm.searchOrder(value);
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


