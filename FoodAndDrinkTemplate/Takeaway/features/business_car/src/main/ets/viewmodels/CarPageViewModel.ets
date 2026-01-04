import { BaseViewModel } from 'lib_common';
import { CarGoodsInfo, MyCarModel } from 'lib_takeaway_api';
import { AppStorageV2 } from '@kit.ArkUI';

@ObservedV2
export class CarPageViewModel extends BaseViewModel {
  @Trace myCar: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
  @Trace isEdit: boolean = false;
  @Trace isShow: boolean = false;
  @Trace totalPrice: number = 0;
  @Trace totalGoodsNum: number = 0;
  @Trace checkGoodsList: CarGoodsInfo[] = []
  @Trace checkStoreList: string[] = []

  public checkSubmit(checkStoreList: string[], checkGoodsList: CarGoodsInfo[]): string {
    // 店铺分别结算
    if (checkStoreList.length > 1) {
      return '请按照店铺分别结算'
    }
    // 选择商品结算
    if (!checkGoodsList.length) {
      return '请先选择商品'
    }
    // 校验必选商品
    let mustGoodsId: string[] = []
    this.myCar.myCar.forEach(storeCar => {
      if (storeCar.storeId === checkStoreList[0]) {
        storeCar.goodsList.forEach(goods => {
          if (goods.isMust) {
            // 必选商品未选中
            mustGoodsId.push(goods.id)
          }
        })
      }
    })
    if (mustGoodsId.length === 0) {
      return '请选择必选商品'
    }
    let intersection = checkGoodsList.filter(value => mustGoodsId.includes(value.id))
    if (intersection.length === 0) {
      return '请选择必选商品'
    }
    return ''
  }
}

