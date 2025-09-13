import { OrderCard } from './OrderCard';
import { Constants, OrderStateEnum, TabBarType } from 'common/Index';
import { MyOrderResp } from 'network';
import * as API from '../api/Index';
import { orderInfoMapper } from '../mapper/Index';
import { MyOrderInfo } from '../models/Index';

@ComponentV2
export struct CommonTab {
  @Consumer('currentIndex') currentIndex: number = 0
  @Consumer('refreshData') refreshData: boolean = false
  @Local currentState: OrderStateEnum = OrderStateEnum.All;
  @Local orderList: Array<MyOrderInfo> = [];
  scroller: Scroller = new Scroller()
  @Local pageNum: number = 0

  @Monitor('currentIndex')
  currentIndexChange(monitor: IMonitor) {
    if (monitor.value()?.now === 1) {
      this.getMyOrder()
    }
  }

  @Monitor('refreshData')
  refreshOrderList(monitor: IMonitor) {
    if (monitor.value()?.now && this.currentIndex === TabBarType.ORDER) {
      this.getMyOrder()
      this.refreshData = false
    }
  }

  getMyOrder() {
    let tabIndex = [this.currentState]
    if (this.currentState === OrderStateEnum.All) {
      tabIndex = [OrderStateEnum.noFinished, OrderStateEnum.finished, OrderStateEnum.AfterSales]
    }
    API.getMyOrder(this.pageNum, tabIndex).then((resp: Array<MyOrderResp>) => {
      this.orderList = resp.map(item => orderInfoMapper(item))
    })
  }

  aboutToAppear(): void {
    this.getMyOrder()
  }

  @Builder
  tabBuilder(index: number, name: Resource) {
    Column() {
      Text(name)
        .fontColor(this.currentState === index ? $r('sys.color.multi_color_09') : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
      if (this.currentState === index) {
        Row()
          .width(42)
          .height(0)
          .borderWidth({ bottom: 2 })
          .borderColor($r('sys.color.multi_color_09'))
          .margin({ top: 4 })
      }
    }
    .width(Constants.FULL_SIZE)
    .height(50)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  tabOrderList() {
    List({ space: 12 }) {
      ForEach(this.orderList, (item: MyOrderInfo) => {
        OrderCard({
          orderItem: item, getMyOrder: () => {
            this.getMyOrder()
          },
        })
      }, (item: MyOrderInfo) => JSON.stringify(item))
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .height(Constants.FULL_SIZE)
    .margin({ top: 12 })
    .constraintSize({ maxHeight: Constants.FULL_SIZE })
  }

  build() {
    Column() {
      Tabs({ index: this.currentState }) {
        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.All, $r('app.string.all')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.noFinished, $r('app.string.not_complete')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.finished, $r('app.string.completed')))

        TabContent() {
          this.tabOrderList()
        }.tabBar(this.tabBuilder(OrderStateEnum.AfterSales, $r('app.string.other')))
      }
      .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
        this.currentState = targetIndex
      })
      .width(Constants.FULL_SIZE)
      .barHeight(50)
      .layoutWeight(1)
      .onChange((index) => {
        this.currentState = index;
        this.getMyOrder()
      })
    }.justifyContent(FlexAlign.Start)
  }
}