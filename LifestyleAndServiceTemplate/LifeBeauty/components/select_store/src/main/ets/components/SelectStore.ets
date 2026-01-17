import { MapLocation, StoreInfo } from '../models/Index';
import { ConfirmDialog } from '../utils/ConfirmDialog';
import { HwMapComp } from './HwMapComp';
import { StoreCard } from './StoreCard';
import { curves, display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';

export class SelectStoreController {
  closeSheet: () => void = () => {}
}

@ComponentV2
export struct SelectStore {
  @Param storeInfoList: Array<StoreInfo> = []
  @Param storeId: string = ''
  @Param packageName: string = ''
  @Param geometryId: string = ''
  @Param controller: SelectStoreController = new SelectStoreController()
  @Event selectedStore: (storeId: string) => void = () => {}
  @Event onSearchClick: () => void;
  @Local selectStore: MapLocation = new MapLocation()
  @Local selectIndex: number = 0
  @Local showSelectStore: boolean = true
  @Local mapMarginBottom: number = 0
  @Local sheetMaxHeight: number = 690;

  aboutToAppear(): void {
    this.locationsChange()
    this.getMaxHeight()
    this.controller.closeSheet = (): void => this.closeSheet();
  }

  async getMaxHeight() {
    try {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const win: window.Window = await window.getLastWindow(context);
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const topPadding = this.getUIContext().px2vp(area.topRect.height);
      const displayInfo = display.getDefaultDisplaySync();
      const displayHeight = this.getUIContext().px2vp(displayInfo.height);
      this.sheetMaxHeight = displayHeight - topPadding - 56;
    } catch (e) {
      UtilLog.error('[SelectStore]', `Failed to get window avoid area. ${JSON.stringify(e)}`)
    }
  }

  closeSheet() {
    this.showSelectStore = false;
  }

  @Computed
  get locations() {
    return this.storeInfoList.map(item => {
      let location = new MapLocation()
      let locationArr = item.coordinates.split(',')
      if (locationArr?.length === 2) {
        location.id = item.id
        location.title = item.name
        location.longitude = Number(locationArr[0])
        location.latitude = Number(locationArr[1])
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

  @Monitor('storeId')
  storeIdChange() {
    const index = this.storeInfoList.findIndex((item) => item.id === this.storeId);
    const store = this.locations.find((item) => item.id === this.storeId);
    if (index !== -1) {
      this.selectIndex = index
    }
    if (store) {
      this.selectStore = store;
    }
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
      detents: [442, 200, this.sheetMaxHeight],
      showClose: true,
      preferType: SheetType.CENTER,
      maskColor: '#00000000',
      title: { title: $r('app.string.select_store') },
      enableOutsideInteractive: true,
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
      Row() {
        Search({ placeholder: '搜索门店' })
          .focusable(false)
          .defaultFocus(false)
          .focusOnTouch(false)
          .focusable(false)
          // 由于模态转场不涉及首页的消失，因此需要加true让首页的卡片做一镜到底动效，否则卡片没有一镜到底效果
          .geometryTransition(this.geometryId)
          .transition(TransitionEffect.OPACITY.animation({
            duration: 200,
            curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
          }))
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Up) {
              this.onSearchClick();
            }
          })
      }
      .width('100%')
      .padding({left: 16, right: 16 })

      List({ space: 12 }) {
        ForEach(this.storeInfoList, (item: StoreInfo, index: number) => {
          ListItem() {
            StoreCard({ storeInfo: item, packageName: this.packageName, isSelect: this.selectIndex === index })
              .onClick(() => {
                if (this.selectIndex === index) {
                  ConfirmDialog.show({primaryTitle:'温馨提示',content:'您是否需要切换至该门店',confirm:()=>{
                    this.selectedStore(item.id)
                    this.showSelectStore = false
                  }})
                } else {
                  this.selectIndex = index
                  this.selectStore = this.locations.find(location => location.id === item.id)!
                }
              })
          }
        }, (item: StoreInfo) => item.id)
      }
      .width('100%')
      .padding({left: 16, right: 16 })
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .constraintSize({ maxWidth: '100%' })
  }
}