import { AppStorageV2 } from '@kit.ArkUI';
import { Decimal } from '@kit.ArkTS';
import { AuthorService } from './AuthorService';
import { MyAuthor } from '../database/AuthorType';
import { StoreResponse } from '../params/response/StoreResponse';
import { BaseStoreServiceApi } from './BaseStoreService';
import { StoreModel } from '../observedmodels/StoreModel';
import { MockStore } from './mockdata/MockStore';
import { CarGoodsInfo, Goods, GoodsSpecResp } from '../params/response/GoodsResponse';
import { MyCar, MyCarModel } from '../observedmodels/MyCarModel';

/**
 * 我的管理类
 */
export class StoreService extends AuthorService {
  private storeListAll: StoreResponse[] =
    JSON.parse(JSON.stringify([...MockStore.storeList, ...MockStore.storeListOther]));
  private myCarId: number = 0

  public queryStoreByStoreId(storeId: string) {
    return this.storeListAll.find(v => v.id === storeId)
  }

  /**
   * 关注
   * @param storeId
   */
  public addFollow(storeId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo.myFollows.splice(0, 0, storeId);
  }

  /**
   * 取消关注
   * @param storeId
   */
  public cancelFollow(storeId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo.myFollows.findIndex(id => id === storeId);
    if (index !== -1) {
      mineUserInfo.myFollows.splice(index, 1);
    }
  }

  /**
   * 查询我的关注
   * @returns
   */
  public queryMyFollows(): StoreResponse[] {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    return mineUserInfo.myFollows
      .map((id: string) => {
        return BaseStoreServiceApi.queryRawStore(id);
      })
      .filter(v => Boolean(v)) as StoreResponse[];
  }

  /**
   * 添加浏览历史记录
   * @param storeId
   */
  public addBrowsingHistory(storeId: string) {
    this.deleteFromBrowsingHistory(storeId);
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo.myBrowsingHistory.splice(0, 0, storeId);
  }

  /**
   * 从浏览历史中删除
   * @param storeId
   */
  public deleteFromBrowsingHistory(storeId: string) {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    const index = mineUserInfo?.myBrowsingHistory.findIndex(id => id === storeId);
    if (index !== -1) {
      mineUserInfo?.myBrowsingHistory.splice(index, 1);
    }
  }

  /**
   * 清空浏览历史
   * @param storeId
   */
  public clearBrowsingHistory() {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    mineUserInfo.myBrowsingHistory = []
  }

  /**
   * 查询我的浏览历史
   * @returns
   */
  public queryMyBrowsingHistory(): StoreResponse[] {
    const mineUserInfo = this.queryAuthorRaw() as MyAuthor;
    return mineUserInfo.myBrowsingHistory
      .map((id: string) => {
        return BaseStoreServiceApi.queryRawStore(id);
      })
      .filter(v => Boolean(v)) as StoreResponse[];
  }

  /**
   * 更新单规格到购物车
   * @param storeCar
   * @param goods
   */
  updateStoreCar(storeCar: MyCar, goods: Goods) {
    let carGoodTemp = storeCar.goodsList?.find(item => item.goodsId === goods.id);
    // 店铺购物车该商品已存在
    if (carGoodTemp) {
      if (carGoodTemp.isMust === 1) {
        storeCar.isMust += 1;
      }
      carGoodTemp.num = new Decimal(carGoodTemp.num || 0).add(1).toNumber();
      storeCar.money = new Decimal(storeCar.money || 0).add(new Decimal(goods.money!).mul(1)).toNumber();
      storeCar.num = new Decimal(storeCar.num || 0).add(1).toNumber();
    } else {
      // 店铺购物车该商品不存在
      let carGood: CarGoodsInfo = {
        id: `${this.myCarId}`,
        goodsId: goods.id,
        num: 1,
        specType: goods.specType,
        spec: '',
        combination: [],
        money: goods.money,
        money2: goods?.money2 || 0,
        discount: goods?.discount || '',
        boxMoney: goods.boxMoney,
        logo: goods?.logo || '',
        name: goods?.name || '',
        isMust: goods?.isMust || 0,
        isCheck: true // 勾选
      };
      if (!storeCar.goodsList) {
        storeCar.goodsList = [];
      }
      if (!storeCar.checkCarIds) {
        storeCar.checkCarIds = [];
      }
      if (carGood.isMust === 1) {
        storeCar.isMust = 1;
      }
      storeCar.goodsList.push(carGood);
      storeCar.checkCarIds.push(carGood.id);
      storeCar.num = new Decimal(storeCar.num || 0).add(1).toNumber();
      storeCar.money = new Decimal(storeCar.money || 0).add(new Decimal(goods.money!).mul(1)).toNumber();
      this.myCarId++;
    }
  }

  /**
   * 店铺添加多规格到购物车
   * @param storeId
   * @param storeInfo
   * @param goods
   */
  public addCar(storeId: string, storeInfo: StoreResponse | undefined, goods: Goods, goodsSpec?: GoodsSpecResp) {
    // 获取我的购物车
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let storeCar = myCarModel.myCar.find(car => car.storeId === storeId)
    if (storeCar) {
      // 店铺购物车已存在
      if (goodsSpec) {
        this.updateStoreCarBySpec(storeCar, goods, goodsSpec);
      } else {
        this.updateStoreCar(storeCar, goods)
      }
    } else {
      storeCar = new MyCar()
      storeCar.storeId = storeId;
      if (storeInfo) {
        storeCar.storeInfo = new StoreModel(storeInfo);
      }
      storeCar.isCheck = 1;
      if (goodsSpec) {
        this.updateStoreCarBySpec(storeCar, goods, goodsSpec);
      } else {
        this.updateStoreCar(storeCar, goods)
      }
      myCarModel.myCar.push(storeCar)
    }
    return 1
  }

  /**
   * 更新购物车数量
   * @param storeId
   * @param goodsId
   * @param num
   */
  public updateCar(storeId: string, goodsId: string, num?: number) {
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let storeCar = myCarModel.myCar.find(car => car.storeId === storeId)
    if (!storeCar) {
      return 0
    }
    let carGood = storeCar.goodsList?.find(item => item.goodsId === goodsId)
    if (!carGood) {
      return 0
    }
    if (!num) {
      num = 1
    }
    let goodNumOri: number = Number(carGood.num)
    // 购物车商品数量为0，返回失败
    if (goodNumOri === 0) {
      return 0
    }
    let goodNumSub = new Decimal(num).sub(goodNumOri).toNumber()
    if (carGood.isMust === 1) {
      storeCar.isMust -= num
    }
    storeCar.num = new Decimal(storeCar.num || 0).sub(num).toNumber();
    storeCar.money = new Decimal(storeCar.money || 0).sub(new Decimal(carGood.money!).mul(num)).toNumber();
    if (goodNumOri === 1 && goodNumSub <= 0) {
      storeCar.goodsList = storeCar.goodsList?.filter(item => item.id !== carGood?.id)
      storeCar.checkCarIds = storeCar.checkCarIds?.filter(item => item !== carGood?.id)
      if (storeCar.goodsList.length === 0) {
        myCarModel.myCar = myCarModel.myCar.filter(car => car.storeId !== storeCar?.storeId)
      }
    } else {
      carGood.num = goodNumSub
    }
    return 1

  }

  /**
   * 更新多规格到购物车
   * @param storeCar
   * @param goods
   * @param goodsSpec
   */
  public updateStoreCarBySpec(storeCar: MyCar, goods: Goods, goodsSpec: GoodsSpecResp) {
    let carGoodTemp = storeCar.goodsList?.find(item => item.goodsId === goods.id && item.spec === goodsSpec.spec);
    // 店铺购物车该商品已存在
    if (carGoodTemp) {
      carGoodTemp.num = new Decimal(carGoodTemp.num || 0).add(1).toNumber();
      storeCar.money = new Decimal(storeCar.money || 0).add(new Decimal(goodsSpec.money!).mul(1)).toNumber();
      storeCar.num = new Decimal(storeCar.num || 0).add(1).toNumber();
      if (carGoodTemp.isMust) {
        storeCar.isMust += 1
      }
    } else {
      // 店铺购物车该商品不存在
      let carGood: CarGoodsInfo = {
        id: `${this.myCarId}`,
        goodsId: goodsSpec.goodsId,
        num: 1,
        specType: goodsSpec.specType,
        spec: goodsSpec.spec,
        combination: goodsSpec.combination,
        money: goodsSpec.money,
        money2: goods?.money2 || 0,
        discount: goods?.discount || '',
        boxMoney: goodsSpec.boxMoney,
        logo: goods?.logo || '',
        name: goods?.name || '',
        isMust: goods?.isMust || 0,
        isCheck: true // 勾选
      };
      if (!storeCar.goodsList) {
        storeCar.goodsList = [];
      }
      if (!storeCar.checkCarIds) {
        storeCar.checkCarIds = [];
      }
      if (carGood.isMust === 1) {
        storeCar.isMust = 1;
      }
      storeCar.goodsList.push(carGood);
      storeCar.checkCarIds.push(carGood.id);
      storeCar.num = new Decimal(storeCar.num || 0).add(1).toNumber();
      storeCar.money = new Decimal(storeCar.money || 0).add(new Decimal(goodsSpec.money!).mul(1)).toNumber();
      this.myCarId++;
    }
  }

  public clearStoreCar(storeId: string) {
    // 获取购物车列表
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    myCarModel.myCar = myCarModel.myCar.filter(car => car.storeId !== storeId)
  }

  /**
   * 校验店铺是否在当前地址内
   * @param storeId
   * @param address
   */
  checkStoreIncluded(storeId: string, address: string): boolean {
    let array = storeId.split('store_0')
    let index = Number(array[1])
    if (address.includes('南京市')) {
      return index <= 20
    } else {
      return index > 20
    }
  }
}

const instance = new StoreService();

export { instance as StoreServiceApi };