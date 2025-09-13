import { OrderTypeComp } from '../components/OrderTypeComp'
import { PaymentDetailsComp } from '../components/PaymentDetailsComp'
import {
  CardManager,
  FormDataClass,
  NavHeaderBar,
  OrderDetailRouter,
  RouterMap,
  RouterModule,
  StoreInfoModel,
  StoreType,
  WindowModel,
} from 'common/Index'
import { BusinessError } from '@kit.BasicServicesKit'
import dataPreferences from '@ohos.data.preferences'
import { ReductionCard } from '../components/ReductionCardComp'
import { StoreInfoCard } from '../components/StoreInfoCardComp'
import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { GoodsComp } from 'base_ui'
import { MyOrderResp } from 'network'
import * as API from '../api/Index'
import { orderGoodsMapper, orderInfoMapper } from '../mapper/Index'
import { MyOrderInfo } from '../models/Index'

@Builder
export function OrderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
struct OrderDetailPage {
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local orderId: string = ''
  @Local isOrderJump: boolean = false
  @Local orderDetailInfo: MyOrderInfo = new MyOrderInfo()
  scroller: Scroller = new Scroller();

  getRouteParams() {
    let params = RouterModule.getNavParam<OrderDetailRouter>(RouterMap.ORDER_DETAIL_PAGE)
    if (params) {
      this.orderId = params.orderId
      this.isOrderJump = params.isOrderJump
    }
  }

  aboutToAppear() {
    this.getRouteParams()
    this.getOrderInfo()
  }

  getOrderInfo() {
    API.getOrderInfo(this.orderId).then((resp: MyOrderResp) => {
      if (resp) {
        console.info(`getOrderInfo resp:${JSON.stringify(resp)}.`);
        this.orderDetailInfo = orderInfoMapper(resp)
        if (this.isOrderJump) {
          this.updateFormCard()
        }
      } else {
        console.error(`getOrderInfo error: ${JSON.stringify(resp)}.`);
        promptAction.showToast({ message: $r('app.string.order_not_exist') })
        RouterModule.popToName(RouterMap.HOME_PAGE, 0)
      }
    }).catch((e: BusinessError) => {
      console.error(`getOrderInfo error: ${JSON.stringify(e)}.`);
      promptAction.showToast({ message: $r('app.string.order_not_exist') })
      RouterModule.popToName(RouterMap.HOME_PAGE, 0)
    })
  }

  updateFormCard() {
    dataPreferences.removePreferencesFromCacheSync(getContext(this), { name: CardManager.KEY_CARD_ID })
    let pref = dataPreferences.getPreferencesSync(getContext(this), { name: CardManager.KEY_CARD_INFO })
    let dataClass = new FormDataClass()
    let storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
    dataClass.storeName = storeModel.storeInfo.name || ''
    dataClass.storeType = this.storeModel.storeType.toString()
    dataClass.orderState = true
    dataClass.orderId = this.orderId
    dataClass.storeTable =
      this.storeModel.storeType === StoreType.SCAN_TYPE ?
        `${this.orderDetailInfo?.table?.typeName} | ${this.orderDetailInfo?.table?.name}` : ''
    dataClass.orderPickNum =
      this.storeModel.storeType === StoreType.PICK_NUM_TYPE ? `${this.orderDetailInfo?.order?.oid}` : ''
    pref.putSync(CardManager.KEY_CARD_INFO, dataClass)
    pref.flush()
    CardManager.get().updateCard(getContext(this), '', dataClass)
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.order_detail'), hasBackButton: true })
      Scroll(this.scroller) {
        Column({ space: 12 }) {
          OrderTypeComp({
            orderDetail: this.orderDetailInfo,
            getOrderInfo: () => {
              this.getOrderInfo()
            },
          })
          StoreInfoCard()
          GoodsComp({ goodsList: orderGoodsMapper(this.orderDetailInfo.goods) })
          ReductionCard({ orderInfo: this.orderDetailInfo?.order })
          PaymentDetailsComp({ orderDetail: this.orderDetailInfo }).margin({ top: 8 })
        }.margin({ left: 12, right: 12, top: 12 })
      }
      .layoutWeight(1)
      .padding({ bottom: this.windowModel.getWindowBottomHeight() })
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
  }
}

