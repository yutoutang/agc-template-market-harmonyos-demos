import { Decimal } from '@kit.ArkTS';
import { GoodsSpecResp, GoodsTypeResp, PackageSpec, SpecCatalogResp } from '../params/response/GoodsResponse';
import { MockGoods } from './mockdata/MockGoods';

export class GoodsService {
  /**
   * 查询商品列表
   * @param storeId
   * @returns
   */
  public queryStoreGoodsList(storeId: string): GoodsTypeResp[] {
    return MockGoods.goodsTypeList
  }

  /**
   * 查询商品信息
   * @param goodsId
   * @returns
   */
  public queryGoodsInfoById(goodsId: string) {
    const goods = MockGoods.allGoodsList.find(item => item.id === goodsId)
    if (goods?.specType === 2) {
      let spec = JSON.parse(MockGoods.specJson1) as SpecCatalogResp[]
      goods.spec = spec
    }
    return goods

  }

  /**
   * 查询商品规格
   * @param goodsId
   * @param specArray
   * @returns
   */
  public queryGoodsSpecInfo(goodsId: string = '', specArray: PackageSpec[]) {
    let goods = MockGoods.allGoodsList.find(item => item.id === goodsId)
    let money = 0
    let spec = specArray.map(item => item.specName).join('/')
    if (spec.indexOf('12寸') >= 0) {
      money = Number(new Decimal(goods?.money || 0).mul(2).toFixed(1))
    } else if (spec.indexOf('9寸') >= 0) {
      money = Number(new Decimal(goods?.money || 0).mul(1.5).toFixed(1))
    } else {
      money = goods?.money || 0
    }
    let result: GoodsSpecResp = {
      money: money,
      spec: spec,
      combination: specArray,
      goodsId: goodsId,
      specType: goods?.specType || 0,
      boxMoney: goods?.boxMoney || 0,
      isMust: goods?.isMust || 0,
      id: '',
      money2: 0,
      discount: '',
      number: 0,
    }
    return result
  }
}


const instance = new GoodsService();

export { instance as GoodsServiceApi };