import { BaseViewModel } from 'lib_common';
import { ShopInfoServiceApi ,ShopInfoType} from 'lib_loan_api';

export class LearnMoreVM extends BaseViewModel {
  getShopInfoData() {
    let shopInfo: ShopInfoType | undefined = ShopInfoServiceApi.queryShopInfo()
    if (shopInfo) {
      return shopInfo
    } else {
      return undefined
    }
  }
}