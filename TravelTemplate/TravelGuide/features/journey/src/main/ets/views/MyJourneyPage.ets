import { AppStorageV2 } from '@kit.ArkUI';
import { CommonEmpty, RouterMap } from 'common';
import { MyOrderList, OrderInfo, OrderStatus, OrderType, TourOrderRouterParam } from 'common_travel_guide';
import { OHPage, phoneRouterControl } from 'oh_router'
import { JourneyCard } from '../components/JourneyCard';
import { JourneyFootprintPageBuilder } from './JourneyFootprintPage';

@Builder
export function MyJourneyPageBuilder() {
  MyJourneyPage();
}

@ComponentV2
export struct MyJourneyPage {
  @Local allOrderList: MyOrderList = AppStorageV2.connect(MyOrderList, () => new MyOrderList())!
  @Local journeyList: OrderInfo[] = []

  @Monitor('allOrderList.list.length')
  onListChange() {
    this.getData()
  }

  aboutToAppear() {
    this.getData()
  }

  getData() {
    if (!this.allOrderList.list.length) {
      return
    }
    let statusList = this.allOrderList.list.filter(item => [OrderStatus.FINISHED, OrderStatus.ISSUED,
      OrderStatus.BOOKED].includes(item.status))
    this.journeyList =
      statusList.filter(item => [OrderType.AIRPLANE, OrderType.TRAIN, OrderType.BUS].includes(item.type))
  }

  jumpPage(item: OrderInfo){
    let param: TourOrderRouterParam = {
      orderInfo: item,
      isPulUpPay: false
    }
    if (item.type === OrderType.AIRPLANE) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.TICKET_PENDING_PAYMENT_PAGE,
        param: param
      })
    }
    if (item.type === OrderType.TRAIN) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.PLANE_PENDING_PAYMENT_PAGE,
        param:param
      })
    }
    if (item.type === OrderType.BUS) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CAR_PENDING_PAYMENT_PAGE,
        param: param
      })
    }
  }

  @Builder
  footprintRow() {
    Row() {
      Row({ space: 8 }) {
        Image($r('app.media.ic_footprint'))
          .height(24)
          .width(24)
        Text('旅行足迹')
          .fontSize(16)
          .fontWeight(500)
      }

      Text('记录美好时刻 >')
        .fontSize(14)
        .fontColor('rgba(0, 0, 0, 0.50)')
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.JOURNEY_FOOTPRINT_PAGE,
            builder: wrapBuilder(JourneyFootprintPageBuilder)
          })
        })
    }
    .width('100%')
    .padding({ left: 12, right: 12 })
    .backgroundColor('#fff')
    .height(56)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(16)
    .border({ width: 1, color: 'rgba(0,0,0,0.1)' })
  }

  @Builder
  journeyListBuilder() {
    ForEach(this.journeyList, (item: OrderInfo) => {
      JourneyCard({ data: item })
        .onClick(() => {
          this.jumpPage(item)
        })
    },(item: OrderInfo)=>JSON.stringify(item))
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Row() {
        Text('我的行程')
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .height(36)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          this.footprintRow()
          if (this.journeyList.length) {
            this.journeyListBuilder()
          } else {
            CommonEmpty()
          }
        }
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true,
      isFullScreen: true,
    })
  }
}

