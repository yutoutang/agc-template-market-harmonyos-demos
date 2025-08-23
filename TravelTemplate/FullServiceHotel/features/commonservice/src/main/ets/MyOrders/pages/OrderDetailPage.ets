import { CommonButton } from 'componentlib';
import { HotelOrderDetail } from '../components/HotelOrderDetail';
import { MealOrderDetail } from '../components/MealOrderDetail';
import { OrderClassLabel, OrderType } from '../types';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@Builder
export function orderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
export struct OrderDetailPage {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          this.titleBuilder();
          if (this.vm.orderType === OrderType.HOTEL) {
            HotelOrderDetail()
          } else if (this.vm.orderType === OrderType.MEAL) {
            MealOrderDetail()
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
        bottom: $r('app.string.padding_l'),
      })

      if (this.vm.getOrderTitleLabel() === OrderClassLabel.PENDING_PAYMENT) {
        this.bottomBarBuilder()
      }
    }
    .title('订单详情')
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady(() => {
      this.vm.getOrderDetail();
    })
  }

  @Builder
  titleBuilder() {
    Column() {
      Text(this.vm.getOrderTitleLabel())
        .fontSize($r('app.string.font_size_18'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.vm.getOrderStatusColor())
      if (this.vm.getSubTitleLabel()) {
        Text(this.vm.getSubTitleLabel())
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
          .margin({ top: $r('app.string.margin_xs') })
      }
    }
    .width($r('app.string.width_percent_full'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  bottomBarBuilder() {
    Flex() {
      CommonButton({
        bgColor: $r('app.color.background_color_white'),
        fontColor: $r('app.color.theme_color'),
        customBorderColor: $r('app.color.theme_color'),
        containerPadding: 0,
        title: '取消订单',
        handleClick: () => {
          this.vm.cancelPayment();
        },
      })
      Blank().width($r('app.string.margin_l'))

      CommonButton({
        title: '继续支付',
        containerPadding: 0,
        handleClick: () => {
          this.vm.continuePayment();
        },
      })
    }
    .width($r('app.string.width_percent_full'))
    .padding({
      top: $r('app.string.padding_m'),
      left: $r('app.string.padding_m'),
      right: $r('app.string.padding_s'),
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor($r('app.color.background_color_white'))
  }
}
