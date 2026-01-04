import { WindowModel } from 'lib_common';
import { StoreMap, StoreMapInfo } from 'module_store_map';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function OrderStoreMapBuilder() {
  OrderStoreMapPage()
}

@ComponentV2
struct OrderStoreMapPage {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local storeInfo: StoreMapInfo = {
    shopName: '饭点食光',
    latitude: 32.043060,
    longitude: 118.785017,
    address: '江苏省南京市玄武区德基广场'
  }

  build() {
    NavDestination() {
      Column() {
        StoreMap({
          storeInfo: {
            shopName: this.storeInfo.shopName,
            latitude: this.storeInfo.latitude,
            longitude: this.storeInfo.longitude,
            address: this.storeInfo.address
          },
          showInfoWindow: true,
          showUserLocation: true,
          mapHeight: '100%',
        });
      }
    }
    .padding({
      top: this.windowModel.windowTopPadding
    })
    .onReady((context: NavDestinationContext) => {
      let storeInfo = context.pathInfo.param as StoreMapInfo
      if (storeInfo) {
        this.storeInfo = storeInfo
      }
    })
  }
}