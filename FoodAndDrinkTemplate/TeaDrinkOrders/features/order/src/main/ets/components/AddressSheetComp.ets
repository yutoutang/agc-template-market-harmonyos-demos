import {
  AddressInfo as AddressInfoResp,
  BaseResponse,
  Constants,
  HttpCode,
  HttpRequestApi,
  PermissionUtil,
  StoreInfoModel,
  WindowModel,
} from 'common';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { map, mapCommon } from '@kit.MapKit';
import { AddAddress, AddressCard, AddressInfo } from 'add_address';
import { geoLocationManager } from '@kit.LocationKit';
import { getAddressInfoMapper } from '../mapper/Index';

@Builder
export function AddressSheetBuilder(selectAddress: AddressInfo, close: (selectAddress?: AddressInfo) => void) {
  AddressSheet({
    selectAddress,
    close: (selectAddress?: AddressInfo) => {
      close(selectAddress)
    },
  })
}

@ComponentV2
struct AddressSheet {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Local storeInfoModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!
  @Param @Require selectAddress: AddressInfo;
  @Local modifyAddress: AddressInfo = new AddressInfo()
  @Local addressList: Array<AddressInfo> = [];
  @Local addressOverList: Array<AddressInfo> = [];
  @Local addAddressSheetShow: boolean = false
  @Local myLocation?: geoLocationManager.Location
  @Event close: (selectAddress?: AddressInfo) => void = () => {
  }

  aboutToAppear(): void {
    this.getUserAddressList()
    PermissionUtil.getLocation().then(res => {
      this.myLocation = res
    })
  }

  @Styles
  cardStyle(){
    .width(Constants.FULL_SIZE)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12,
    })
  }

  build() {
    Stack() {
      Column() {
        List({ space: 8 }) {
          ForEach(this.addressList, (address: AddressInfo) => {
            ListItem() {
              AddressCard({
                address,
                selectId: this.selectAddress.id,
                showSelect: true,
                selectAddress: () => {
                  this.close(address)
                },
                modifyAddress: (address: AddressInfo) => {
                  this.modifyAddress = address
                  this.addAddressSheetShow = true
                },
              })
            }
          }, (address: AddressInfo) => JSON.stringify(address))
        }.width(Constants.FULL_SIZE).scrollBar(BarState.Off)

        Row() {
          Image($r('app.media.ic_add_address')).width(24)
          Text($r('app.string.add_address'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.fontMainColor'))
            .margin({ left: 8 })
        }
        .cardStyle()
        .height(56)
        .margin({ top: 24 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.modifyAddress = new AddressInfo()
          this.addAddressSheetShow = true
        })
        .bindSheet($$this.addAddressSheetShow, this.addAddressSheet(this.modifyAddress), {
          detents: [736, 737],
          blurStyle: BlurStyle.Thick,
          preferType: SheetType.CENTER,
          showClose: true,
          backgroundColor: $r('sys.color.background_fourth'),
          title: { title: this.modifyAddress?.id ? $r('app.string.modify_address') : $r('app.string.add_address') },
          onWillDismiss: () => {
            this.addAddressSheetShow = false
          },
        })

        // 超出配送范围
        Column() {
          Text($r('app.string.over_distance_address'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ bottom: 12 })
          List({ space: 8 }) {
            ForEach(this.addressOverList, (address: AddressInfo) => {
              ListItem() {
                AddressCard({ address, showSelect: true, disable: true })
              }
              .opacity(0.4)
            }, (address: AddressInfo) => JSON.stringify(address))
          }.width(Constants.FULL_SIZE).scrollBar(BarState.Off).margin({ bottom: 16 }).opacity(0.4)
        }
        .margin({ top: 39 })
        .alignItems(HorizontalAlign.Start)
        .visibility(this.addressOverList.length ? Visibility.Visible : Visibility.None)
      }
      .width(Constants.FULL_SIZE)
      .padding({
        left: Constants.BORDER_WIDTH,
        right: Constants.BORDER_WIDTH,
        bottom: this.windowModel.getWindowBottomHeight(),
      })
    }.width(Constants.FULL_SIZE)
    .alignContent(Alignment.Bottom)
  }

  @Builder
  addAddressSheet(selectAddress: AddressInfo) {
    AddAddress({
      addressInfo: selectAddress,
      myLocation: this.myLocation,
      modifyAddressInfo: (addressInfo: AddressInfo) => {
        this.modifyAddressInfo(addressInfo)
      },
    })
  }

  closeAddAddressSheet() {
    this.getUserAddressList()
    this.addAddressSheetShow = false
  }

  getUserAddressList() {
    HttpRequestApi.getUserAddressList().then(res => {
      if (res.code === HttpCode.SUCCESS && res.data) {
        this.addressList = []
        this.addressOverList = []
        res.data.forEach((item: AddressInfoResp) => {
          let fromLatLng: mapCommon.LatLng = {
            latitude: 0,
            longitude: 0,
          };
          let locationArr = this.storeInfoModel.storeInfo?.coordinates?.split(',')
          if (locationArr?.length === 2) {
            fromLatLng.latitude = Number(locationArr[0])
            fromLatLng.longitude = Number(locationArr[1])
          }
          let address: AddressInfo = getAddressInfoMapper(item);
          let toLatLng: mapCommon.LatLng = {
            latitude: address.latitude,
            longitude: address.longitude,
          };
          let distance = map.calculateDistance(fromLatLng, toLatLng)
          if (distance > Constants.ADDRESS_OVER) {
            this.addressOverList.push(address)
          } else {
            this.addressList.push(address)
          }
        })
      }
    }).catch((e: BusinessError) => {
      console.error(`getUserAddressList error: ${JSON.stringify(e)}.`);
    })
  }

  modifyAddressInfo(addressInfo: AddressInfo) {
    let address = new AddressInfoResp()
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
        this.closeAddAddressSheet()
      } else {
        console.info(`modifyUserAddress failed. Error:${resp.msg}`);
        promptAction.showToast({ message: $r('app.string.save_address_failed') })
      }
    })
  }
}