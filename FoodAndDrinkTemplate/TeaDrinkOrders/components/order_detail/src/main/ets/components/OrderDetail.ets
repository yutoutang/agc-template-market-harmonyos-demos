import { GoodsComp, GoodsOfOrder, MapLocation } from 'base_ui';
import { OrderStateEnum, OrderTypeEnum } from '../constants/Index';
import { AddressInfo, DeliveryInfo, OrderInfo } from '../models/Index';
import { copyString, getDistanceByLocation } from '../utils/Utils';
import { DetailMoreCard, MakingCard, MapCard, ReductionCard, StoreCard } from './OrderDetailCards';
import { OrderTypeComp } from './OrderTypeComp';
import { mapCommon } from '@kit.MapKit';
import { application, common } from '@kit.AbilityKit';

@ComponentV2
export struct OrderDetail {
  @Param @Require orderInfo: OrderInfo
  @Param @Require goods: Array<GoodsOfOrder>
  @Param address: AddressInfo = new AddressInfo()
  @Param delivery: DeliveryInfo = new DeliveryInfo()
  scroller: Scroller = new Scroller();
  context?: common.Context;
  @Event confirmOrder: () => void = () => {
  }
  @Event showPaySheet: () => void = () => {
  }
  @Event cancelOrderCb: () => void = () => {
  }
  @Event oneMoreOrder: () => void = () => {
  }
  @Event callTelCb: () => void = () => {
  }
  @Event goNavigation: () => void = () => {
  }

  async aboutToAppear() {
    // 获取order_list上下文
    application.createModuleContext(getContext(this), 'order_list').then((data: Context) => {
      this.context = data
    })
  }

  @Computed
  get locations() {
    let locations: Array<MapLocation> = []

    if (this.orderInfo.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {

      // 配送位置
      let location1 = new MapLocation()
      location1.id = '1'
      location1.latitude = this.address.latitude
      location1.longitude = this.address.longitude
      location1.icon = 'ic_user_location.png'
      locations.push(location1)
      // 店铺位置
      let location2 = new MapLocation()
      location1.id = '2'
      let locationArr2 = this.orderInfo.coordinates?.split(',')
      if (locationArr2?.length === 2) {
        location2.title = this.orderInfo.storeName ?? ''
        location2.latitude = Number(locationArr2[0])
        location2.longitude = Number(locationArr2[1])
      }
      locations.push(location2)
      // 外卖员位置
      if (this.orderInfo.state === OrderStateEnum.DELIVERING) {
        let location3 = new MapLocation()
        location3.id = '3'
        location3.icon = 'ic_delivery_location.png'
        location3.latitude = this.delivery.latitude
        location3.longitude = this.delivery.longitude
        // 计算坐标之间的距离
        let fromLatLng: mapCommon.LatLng = {
          latitude: this.delivery.latitude,
          longitude: this.delivery.longitude,
        };
        let toLatLng: mapCommon.LatLng = {
          latitude: location1.latitude,
          longitude: location1.longitude,
        };
        let distance = getDistanceByLocation(fromLatLng, toLatLng)
        // 通过上下文获取字符串
        location3.title = this.context?.resourceManager.getStringByNameSync('delivery_distance',
          `${distance} ${this.delivery.remainingTime}`) || ''
        locations.push(location3)
      }
    }
    return locations
  }

  build() {
    Scroll(this.scroller) {
      Column({ space: 12 }) {
        OrderTypeComp({
          orderInfo: this.orderInfo,
          orderState: this.orderInfo.state,
          estimatedTime: this.delivery.estimatedTime,
          cancelOrderCb: () => this.cancelOrderCb(),
          showPaySheet: () => this.showPaySheet(),
          oneMoreOrder: () => this.oneMoreOrder(),
        })
        if (![OrderStateEnum.TO_BE_PAID, OrderStateEnum.CANCELED].includes(this.orderInfo.state)) {
          MakingCard({
            orderState: this.orderInfo.state,
            orderType: this.orderInfo.orderType,
          })
        }
        if (this.orderInfo.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY &&
        [OrderStateEnum.MAKING, OrderStateEnum.DELIVERING].includes(this.orderInfo.state)) {
          MapCard({ locations: this.locations })
        }
        StoreCard({
          storeName: this.orderInfo.storeName,
          storeAddress: this.orderInfo.address,
          goNavigationCb: () => {
            this.goNavigation()
          },
          callTelCb: () => {
            this.callTelCb()
          },
        })
        GoodsComp({ goodsList: this.goods, bagMoney: this.orderInfo.bagMoney })
        ReductionCard({ orderInfo: this.orderInfo })
        DetailMoreCard({
          orderInfo: this.orderInfo,
          address: this.address,
          copyCb: (oid: string): void => copyString(oid),
        })
      }
    }.edgeEffect(EdgeEffect.Spring)

  }
}
