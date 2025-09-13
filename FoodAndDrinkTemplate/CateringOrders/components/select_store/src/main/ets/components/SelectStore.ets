import { MapLocation, StoreInfo } from '../models/Index';
import { HwMapComp } from './HwMapComp';
import { StoreCard } from './StoreCard';

@ComponentV2
export struct SelectStore {
  @Param storeInfoList: Array<StoreInfo> = []
  @Param storeId: string = ''
  @Param packageName: string = ''
  @Local selectStore: MapLocation = new MapLocation()
  @Local selectIndex: number = 0
  @Local showSelectStore: boolean = true
  @Local mapMarginBottom: number = 0
  @Event selectedStore: (storeId: string) => void = () => {
  }

  aboutToAppear(): void {
    this.locationsChange()
  }

  @Computed
  get locations() {
    return this.storeInfoList.map(item => {
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

  @Monitor('locations')
  locationsChange() {
    this.locations.forEach((item, index) => {
      if (item.id === (this.storeId || this.storeInfoList[0].id)) {
        this.selectStore = item
        this.selectIndex = index
      }
    })
  }

  build() {
    Column() {
      HwMapComp({
        locations: this.locations,
        showMyLocation: false,
        selectStore: this.selectStore,
        mapMarginBottom: this.mapMarginBottom,
        changeStore: (storeName: string) => {
          this.showSelectStore = true
          this.locations.forEach((item, index) => {
            if (item.title === storeName) {
              this.selectStore = item
              this.selectIndex = index
            }
          })
        },
      })
    }.width('100%').bindSheet($$this.showSelectStore, this.selectStoreSheet(), {
      detents: [442, 200, SheetSize.LARGE],
      showClose: true,
      maskColor: '#00000000',
      title: { title: $r('app.string.select_store') },
      onDetentsDidChange: (height: number) => {
        this.mapMarginBottom = this.getUIContext().px2vp(height)
      },
      onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
        this.mapMarginBottom = 0
        dismissSheetAction.dismiss(); //注册dismiss行为
      },
    })
  }

  @Builder
  selectStoreSheet() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.storeInfoList, (item: StoreInfo, index: number) => {
          ListItem() {
            StoreCard({ storeInfo: item, packageName: this.packageName, isSelect: this.selectIndex === index })
              .onClick(() => {
                if (this.selectIndex === index) {
                  this.selectedStore(item.id)
                } else {
                  this.selectIndex = index
                  this.selectStore = this.locations.find(location => location.id === item.id)!
                }
              })
          }
        }, (item: StoreInfo) => item.id)
      }.layoutWeight(1).scrollBar(BarState.Off)
    }.width('100%').margin({ left: 16, right: 16 }).constraintSize({ maxWidth: '100%' }).padding({ left: 8, right: 8 })
  }
}