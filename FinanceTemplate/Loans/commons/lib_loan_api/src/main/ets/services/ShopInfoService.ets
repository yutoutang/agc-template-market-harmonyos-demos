import { ShopInfoType } from '../database/ShopInfoType';
import { MockShopInfo } from './mockdata/MockShopInfo';


/**
 * 贷款-商家信息类
 */
export class ShopInfoService {
  queryShopInfo(): ShopInfoType | undefined {
    let shopInfo: ShopInfoType = MockShopInfo.shopInfoData;
    if (shopInfo) {
      return MockShopInfo.shopInfoData;
    } else {
      return undefined;
    }
  }
}

const instance = new ShopInfoService();

export { instance as ShopInfoServiceApi };