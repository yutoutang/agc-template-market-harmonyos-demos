import { HwMapComp } from 'base_ui/src/main/ets/components/HwMapComp'
import { site } from '@kit.MapKit'
import { MapLocation, StoreInfo } from '../models/Index'
import { Constants } from '../constants/Index'
import { SelectStoreComp } from './SelectStoreComp'

@ComponentV2
export struct SelectStore {
  @Param storeInfoList: Array<StoreInfo> = []
  @Local searchText: string = ''
  @Local selectIndex: number = 0
  @Local mapHeight: number = Constants.MAP_HEIGHT_DEFAULT
  @Local isExpandMap: boolean = true
  @Local collectStoreList: Array<StoreInfo> = []
  @Local selectStore: MapLocation = new MapLocation()
  @Local searchAddressList: Array<site.Site> = []
  @Event navigateStoreCb: (coordinates: string, address: string) => void = () => {
  }
  @Event selectStoreCb: (storeId: string) => void = () => {
  }
  @Event callTelCb: (callTelSheet: boolean, tel: string) => void = () => {
  }

  @Computed
  get locations() {
    return this.searchList.map(item => {
      let location = new MapLocation()
      let locationArr = item.coordinates.split(',')
      if (locationArr?.length === 2) {
        location.id = item.id
        location.title = item.name
        location.latitude = Number(locationArr[0])
        location.longitude = Number(locationArr[1])
      }
      return location
    })
  }

  @Computed
  get searchList() {
    return this.storeInfoList.filter(item => !this.searchText || item.name.includes(this.searchText))
  }

  aboutToAppear(): void {
    this.selectStore = this.locations.find(item => item.id === this.storeInfoList[0].id)!

  }

  build() {
    Column() {
      Row() {
        Search({ value: $$this.searchText, placeholder: $r('app.string.search') })
          .textFont({ size: $r('sys.float.Body_L') })
          .width('100%')
          .placeholderFont({ size: $r('sys.float.Body_L') })
          .maxLength(20)
      }
      .height(28)
      .margin({ top: 12, bottom: 12 })
      .padding({ left: 16, right: 16 })

      Column() {
        HwMapComp({
          mapHeight: this.mapHeight,
          locations: this.locations,
          showMyLocation: false,
          selectStore: this.selectStore,
        }).margin({ top: 4 })
        Row() {
          Text(this.isExpandMap ? $r('app.string.collapse_map') : $r('app.string.expand_map'))
            .fontSize(8)
            .fontColor($r('sys.color.font_primary'))
          Image(this.isExpandMap ? $r('app.media.ic_up') : $r('app.media.ic_down')).width(16).margin({ left: 8 })
        }.width('100%').height(24).justifyContent(FlexAlign.Center).onClick(() => {
          if (this.isExpandMap) {
            this.isExpandMap = false
            this.mapHeight = 0
          } else {
            this.isExpandMap = true
            this.mapHeight = Constants.MAP_HEIGHT_DEFAULT
          }
        })
      }

      Column() {
        List({ space: 12 }) {
          ForEach(this.searchList, (item: StoreInfo, index: number) => {
            ListItem() {
              SelectStoreComp({
                storeInfo: item,
                isSelect: this.selectIndex === index,
                navigateStoreCb: (coordinates: string = '', address: string = '') => {
                  this.navigateStoreCb(coordinates, address)
                },
                callTelCb: (callTelSheet: boolean, tel: string) => {
                  this.callTelCb(callTelSheet, tel)
                },
              })
                .onClick(() => {
                  if (this.selectIndex === index) {
                    this.selectStoreCb(item.id)
                  } else {
                    this.selectIndex = index
                    this.selectStore = this.locations.find(location => location.id === item.id)!
                  }
                })
            }
          }, (item: StoreInfo) => item.id)
        }.layoutWeight(1).scrollBar(BarState.Off).contentEndOffset(12)
      }.layoutWeight(1)
      .padding({
        top: 12,
        left: 16,
        right: 16,
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }.width('100%').layoutWeight(1)
  }
}
