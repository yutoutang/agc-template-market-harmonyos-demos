import { AppStorageV2, promptAction } from '@kit.ArkUI'
import { common, Want } from '@kit.AbilityKit'
import {
  AppInfoModel,
  CallTelSheetBuilder,
  HttpCode,
  HttpRequestApi,
  IndexPageRouter,
  NavHeaderBar,
  PermissionUtil,
  RouterMap,
  StoreInfo,
  TabBarType,
  Utils,
  WindowModel,
} from 'common'

import { SelectStore } from 'select_store'

@Builder
export function SelectStorePageBuilder() {
  SelectStorePage()
}

@ComponentV2
struct SelectStorePage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local appInfo: AppInfoModel = AppStorageV2.connect(AppInfoModel, () => new AppInfoModel())!
  @Local storeInfoList: Array<StoreInfo> = []
  @Local callTelSheet: boolean = false
  @Local callTel: string = ''

  build() {
    NavDestination() {
      NavHeaderBar({ title: $r('app.string.store_list') })
      SelectStore({
        storeInfoList: this.storeInfoList,
        listOffset: this.windowModel.getWindowBottomHeight(),
        navigateStoreCb: (coordinates: string = '', address: string = '') => {
          this.goNavigationStore(coordinates, address)
        },
        selectStoreCb: (storeId: string) => {
          this.selectStore(storeId)
        },
        callTelCb: (callTelSheet: boolean, tel: string) => {
          this.callTelCb(callTelSheet, tel)
        },
      }).layoutWeight(1).bindSheet($$this.callTelSheet, CallTelSheetBuilder(this.callTel, () => {
        this.callTelSheet = false
      }), {
        detents: [309, 310],
        blurStyle: BlurStyle.Thick,
        preferType: SheetType.CENTER,
        showClose: true,
        backgroundColor: $r('sys.color.background_fourth'),
        title: { title: $r('app.string.contact_us') },
      });
    }

    .hideTitleBar(true)
    .onShown(() => {
      Promise.all([PermissionUtil.getLocation(), HttpRequestApi.getStoreList()]).then(res => {
        let myLocation = res[0]
        if (res[1].code === HttpCode.SUCCESS && res[1].data) {
          this.storeInfoList = res[1].data
          this.storeInfoList.forEach(item => {
            item.distance = Utils.getDistanceWithLocation(myLocation, item.coordinates);
            item.distanceStr = Utils.getFmtDistWithLocation(myLocation, item.coordinates);
          })
          this.storeInfoList.sort((a, b) => a.distance - b.distance)
        }
      })
    })
  }

  selectStore(storeId: string) {
    this.pageStack?.popToName(RouterMap.INDEX_PAGE, { index: TabBarType.ORDER, storeId } as IndexPageRouter)
  }

  async goNavigationStore(coordinates: string = '', address: string = '') {
    let coordinateArr = coordinates.split(',')
    if (coordinateArr?.length === 2) {
      let latitude: number = Number(coordinateArr[0])
      let longitude: number = Number(coordinateArr[1])
      let petalMapWant: Want = {
        bundleName: 'com.huawei.hmos.maps.app',
        uri: 'maps://routes',
        parameters: {
          linkSource: this.appInfo.packageName,
          destinationLatitude: latitude,
          destinationLongitude: longitude,
          destinationPoiId: '',
          destinationName: address ?? '',
        },
      }
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(petalMapWant);
    } else {
      promptAction.showToast({ message: $r('app.string.store_address_error') })
    }
  }

  callTelCb(callTelSheet: boolean, tel: string) {
    this.callTelSheet = callTelSheet
    this.callTel = tel
  }
}