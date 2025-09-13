import {
  AppInfoModel,
  getDistanceWithLocation,
  getFmtDistWithLocation,
  HomePageRouter,
  PermissionUtil,
  RouterMap,
  RouterModule,
  StoreInfo,
  StoreInfoModel,
  TabBarType,
  WindowModel,
} from 'common';
import { SelectStore } from 'select_store';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function SelectStorePageBuilder() {
  SelectStorePage()
}

@ComponentV2
struct SelectStorePage {
  @Local appInfoModel: AppInfoModel = AppStorageV2.connect(AppInfoModel, () => new AppInfoModel())!;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!
  @Param windowTopHeight: number = AppStorageV2.connect(WindowModel)?.getWindowTopHeight() || 38.77
  @Local storeInfoList: Array<StoreInfo> = []

  build() {
    NavDestination() {
      Stack() {
        SelectStore({
          storeInfoList: this.storeInfoList,
          storeId: this.storeModel.storeId,
          packageName: this.appInfoModel.packageName,
          selectedStore: (storeId: string) => {
            RouterModule.popToName(RouterMap.HOME_PAGE, { index: TabBarType.ORDER, storeId: storeId } as HomePageRouter)
          },
        })
        Row() {
          Image($r('app.media.ic_back_grey')).width(40).height(40).onClick(() => {
            RouterModule.pop()
          })
        }.margin({ left: 16, top: this.windowTopHeight }).padding({ top: 8, bottom: 8 })
      }.alignContent(Alignment.TopStart)
    }.hideTitleBar(true).onShown(() => {
      PermissionUtil.getLocation().then(res => {
        let myLocation = res
        this.storeModel.storeList.forEach(item => {
          item.distance = getDistanceWithLocation(myLocation, item.coordinates || '');
          item.distanceStr = getFmtDistWithLocation(myLocation, item.coordinates || '');
        })
        this.storeModel.storeList.sort((a, b) => (a.distance || 0) - (b.distance || 0))
        this.storeInfoList = this.storeModel.storeList
      })
    })
  }
}