import {
  BaseResponse,
  CallTelSheetBuilder,
  CardManager,
  FormDataClass,
  HttpCode,
  HttpRequest,
  HttpRequestApi,
  HwMapModel,
  IndexPageRouter,
  MapLocation,
  MyOrderInfo,
  NavHeaderBar,
  OrderDetailRouter,
  PayTypeSheetBuilder,
  RouterMap,
  StoreInfo,
  StoreInfoModel,
  TabBarType,
  Utils,
  WindowModel,
} from 'common/Index'
import { BusinessError } from '@kit.BasicServicesKit'
import { mapCommon } from '@kit.MapKit'
import { application, common } from '@kit.AbilityKit'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { OrderDetail, OrderStateEnum, OrderTypeEnum } from 'order_detail'

@Builder
export function OrderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
struct OrderDetailPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local orderId: string = ''
  @Local isOrderJump: boolean = false
  @Local orderDetailInfo: MyOrderInfo = new MyOrderInfo()
  @Local storeInfo: StoreInfo = new StoreInfo()
  @Local selectStore: MapLocation = new MapLocation()
  @Local locations: Array<MapLocation> = []
  @Local callTelSheet: boolean = false
  @Local paySheetFlag: boolean = false
  uiContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  context?: common.Context;
  timer: number = 0

  async aboutToAppear() {
    // 获取order_list上下文
    application.createModuleContext(this.uiContext, 'order_list').then((data: Context) => {
      this.context = data
    })
    this.getRouteParams()
    this.getOrderInfo()
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.order_detail') })
        .bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.storeInfo.tel, () => {
          this.callTelSheet = false
        }), {
          detents: [309, 310],
          blurStyle: BlurStyle.Thick,
          preferType: SheetType.CENTER,
          showClose: true,
          backgroundColor: $r('sys.color.background_fourth'),
          title: { title: $r('app.string.contact_us') },
        });
      OrderDetail({
        orderInfo: this.orderDetailInfo.order,
        goods: this.orderDetailInfo.goods,
        address: this.orderDetailInfo.address,
        delivery: this.orderDetailInfo.delivery,
        confirmOrder: (): void => this.confirmOrder(),
        showPaySheet: (): void => {
          this.paySheetFlag = true
        },
        cancelOrderCb: (): void => this.cancelOrderCb(),
        oneMoreOrder: (): void => {
          this.pageStack?.pop({ index: TabBarType.ORDER } as IndexPageRouter)
        },
        callTelCb: (): void => this.callTelCb(),
        goNavigation: (): void => this.goNavigation(),
      }).layoutWeight(1)
        .bindSheet($$this.paySheetFlag, PayTypeSheetBuilder(this.orderDetailInfo.order.money || 0, (flag: boolean) => {
          if (flag) {
            this.confirmOrder()
          }
          this.paySheetFlag = false
        }), {
          detents: [290, 291],
          blurStyle: BlurStyle.Thick,
          preferType: SheetType.CENTER,
          showClose: true,
          backgroundColor: $r('sys.color.background_fourth'),
          title: { title: $r('app.string.select_pay_type') },
        });
    }
    .hideTitleBar(true)
    .padding({ bottom: this.windowModel.getWindowBottomHeight() })
    .backgroundColor('#F1F3F5')
    .onHidden(() => {
      clearInterval(this.timer)
    })
  }

  confirmOrder() {
    // 拉华为支付
    HttpRequest.getPurchase(this.uiContext).finally(() => {
      HttpRequestApi.getHuaweiPayInfo(this.orderDetailInfo.order?.id ?? '').then((resp: BaseResponse) => {
        if (resp.code === HttpCode.SUCCESS) {
          promptAction.showToast({ message: $r('app.string.pay_success') })
          let dataClass = new FormDataClass()
          dataClass.storeName = this.storeModel.storeInfo.name || ''
          dataClass.storeType = this.storeModel.orderType
          dataClass.orderState = true
          dataClass.orderId = this.orderDetailInfo.order.id || ''
          dataClass.orderPickNum = this.orderDetailInfo.order.oid || ''
          dataClass.makingNum = this.storeModel.storeInfo.makingNum || 0
          dataClass.makingWaitMin = this.storeModel.storeInfo.makingWaitTime || 0
          dataClass.deliveryTime = this.orderDetailInfo.delivery.estimatedTime
          let distance = Utils.getDistance(this.orderDetailInfo.delivery.distance) || ''
          dataClass.distance = `${distance} ${this.orderDetailInfo.delivery.remainingTime}`
          CardManager.get().updateCard(dataClass)
          this.getOrderInfo()
        } else {
          promptAction.showToast({ message: $r('app.string.pay_failed') })
        }
      }).catch((e: BusinessError) => {
        console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
        promptAction.showToast({ message: $r('app.string.pay_failed_msg', JSON.stringify(e)) })
      })
    })
  }

  cancelOrderCb() {
    HttpRequest.cancelOrder(this.orderId).then(() => {
      this.getOrderInfo()
    })
  }

  getOrderInfo() {
    HttpRequestApi.getOrderInfo(this.orderId).then((resp: MyOrderInfo) => {
      if (resp) {
        console.info(`getOrderInfo resp:${JSON.stringify(resp)}.`);
        this.orderDetailInfo = resp
        this.initStoreInfo()
      } else {
        console.error(`getOrderInfo error: ${JSON.stringify(resp)}.`);
        promptAction.showToast({ message: $r('app.string.order_not_exist') })
        this.pageStack?.pop()
      }
    }).catch((e: BusinessError) => {
      console.error(`getOrderInfo error: ${JSON.stringify(e)}.`);
    })
  }

  getRouteParams() {
    let paramsArr: OrderDetailRouter[] =
      this.pageStack?.getParamByName(RouterMap.ORDER_DETAIL_PAGE) as OrderDetailRouter[]
    if (paramsArr.length) {
      this.orderId = paramsArr[paramsArr.length - 1].orderId
      this.isOrderJump = paramsArr[paramsArr.length - 1].isOrderJump
    }
  }

  initStoreInfo() {
    this.locations = []
    this.storeInfo.name = this.orderDetailInfo.order?.storeName ?? ''
    this.storeInfo.address = this.orderDetailInfo.order?.address ?? ''
    this.storeInfo.tel = this.orderDetailInfo.order?.tel ?? ''
    this.storeInfo.coordinates = this.orderDetailInfo.order?.coordinates ?? ''
    if (this.orderDetailInfo.order?.orderType === OrderTypeEnum.TAKEAWAY_DELIVERY) {

      // 配送位置
      let location1 = new MapLocation()
      location1.id = '1'
      location1.latitude = this.orderDetailInfo.address.latitude
      location1.longitude = this.orderDetailInfo.address.longitude
      location1.icon = 'ic_user_location.png'
      this.locations.push(location1)
      // 店铺位置
      let location2 = new MapLocation()
      location1.id = '2'
      let locationArr2 = this.storeInfo.coordinates.split(',')
      if (locationArr2?.length === 2) {
        location2.title = this.orderDetailInfo.order?.storeName ?? ''
        location2.latitude = Number(locationArr2[0])
        location2.longitude = Number(locationArr2[1])
      }
      this.locations.push(location2)
      this.selectStore = location2
      // 外卖员位置
      if (this.orderDetailInfo.order.state === OrderStateEnum.DELIVERING) {
        let location3 = new MapLocation()
        location3.id = '3'
        location3.icon = 'ic_delivery_location.png'
        location3.latitude = this.orderDetailInfo.delivery.latitude
        location3.longitude = this.orderDetailInfo.delivery.longitude
        // 计算坐标之间的距离
        let fromLatLng: mapCommon.LatLng = {
          latitude: this.orderDetailInfo.delivery.latitude,
          longitude: this.orderDetailInfo.delivery.longitude,
        };
        let toLatLng: mapCommon.LatLng = {
          latitude: location1.latitude,
          longitude: location1.longitude,
        };
        let distance = Utils.getDistanceByLocation(fromLatLng, toLatLng)
        // 通过上下文获取字符串
        location3.title = this.context?.resourceManager.getStringByNameSync('delivery_distance',
          `${distance} ${this.orderDetailInfo.delivery.remainingTime}`) || ''
        this.locations.push(location3)
        this.selectStore = location3
      }
    }

    if (!this.timer && this.orderDetailInfo.order?.state &&
      this.orderDetailInfo.order?.state > OrderStateEnum.TO_BE_PAID) {
      this.timer = setInterval(() => {
        this.getOrderInfo()
      }, 5000)
    }
    if (this.orderDetailInfo.order?.state && this.orderDetailInfo.order?.state >= OrderStateEnum.COMPLETED) {
      clearInterval(this.timer)
    }
  }

  callTelCb() {
    this.callTelSheet = true
  }

  goNavigation() {
    let coordinates = this.storeInfo.coordinates?.split(',')
    if (coordinates?.length === 2) {
      let latitude: number = Number(coordinates[0])
      let longitude: number = Number(coordinates[1])
      this.pageStack?.pushPathByName(RouterMap.HW_MAP,
        { latitude, longitude } as HwMapModel)
    } else {
      promptAction.showToast({ message: $r('app.string.store_address_error') })
    }
  }
}

