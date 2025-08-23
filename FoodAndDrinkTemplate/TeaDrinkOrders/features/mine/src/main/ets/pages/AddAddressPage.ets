import { AddressInfo, BaseResponse, HttpCode, HttpRequestApi, NavHeaderBar, PermissionUtil, RouterMap } from 'common'
import { geoLocationManager } from '@kit.LocationKit'
import { promptAction } from '@kit.ArkUI'
import { AddAddress } from 'add_address'

@Builder
export function AddAddressPageBuilder() {
  AddAddressPage()
}

@ComponentV2
struct AddAddressPage {
  @Consumer('pageStack') pageStack?: NavPathStack
  @Local addressId: number = 0
  @Local addressInfo: AddressInfo = new AddressInfo()
  @Local myLocation?: geoLocationManager.Location

  aboutToAppear(): void {
    this.getParams()
    PermissionUtil.getLocation().then(res => {
      this.myLocation = res
    })
    if (this.addressId) {
      this.getAddressInfo()
    }
  }

  getParams() {
    let paramsArr: number[] = this.pageStack?.getParamByName(RouterMap.ADD_ADDRESS_PAGE) as number[];
    if (paramsArr.length) {
      this.addressId = paramsArr[paramsArr.length-1];
    }
  }

  build() {
    NavDestination() {
      NavHeaderBar({ title: this.addressId ? $r('app.string.modify_address') : $r('app.string.add_address') })
      AddAddress({
        addressInfo: this.addressInfo,
        myLocation: this.myLocation,
        modifyAddressInfo: (addressInfo: AddressInfo) => {
          this.modifyAddressInfo(addressInfo)
        },
      }).margin({ top: 8 })
    }.hideTitleBar(true)
  }

  getAddressInfo() {
    HttpRequestApi.getUserAddress(this.addressId).then((resp: BaseResponse<AddressInfo>) => {
      if (resp.code === HttpCode.SUCCESS) {
        this.addressInfo.addressPre = resp.data.addressPre
        this.addressInfo.addressNum = resp.data.addressNum
        this.addressInfo.name = resp.data.name
        this.addressInfo.sex = resp.data.sex
        this.addressInfo.tel = resp.data.tel
        this.addressInfo.tag = resp.data.tag
        this.addressInfo.latitude = resp.data.latitude
        this.addressInfo.longitude = resp.data.longitude
      } else {
        console.info(`getUserAddress failed. Error:${resp.msg}`);
      }
    })
  }

  modifyAddressInfo(addressInfo: AddressInfo) {
    let address = new AddressInfo()
    address.addressPre = addressInfo.addressPre
    address.addressNum = addressInfo.addressNum
    address.name = addressInfo.name
    address.sex = addressInfo.sex
    address.tel = addressInfo.tel
    address.tag = addressInfo.tag
    address.latitude = addressInfo.latitude
    address.longitude = addressInfo.longitude
    if (addressInfo.id) {
      address.id = addressInfo.id
    }
    HttpRequestApi.modifyUserAddress(address).then((resp: BaseResponse) => {
      if (resp.code === HttpCode.SUCCESS) {
        this.pageStack?.pop(null)
      } else {
        console.info(`modifyUserAddress failed. Error:${resp.msg}`);
        promptAction.showToast({ message: $r('app.string.save_address_failed') })
      }
    })
  }
}