import { AppStorageV2 } from '@kit.ArkUI';
import { MyCar, MyCarModel } from '../observedmodels/MyCarModel';
import { CarGoodsInfo } from '../params/response/GoodsResponse';
import { StoreServiceApi } from './StoreService';
import { StoreModel } from '../observedmodels/StoreModel';

export class MyCartService {
  public getMyCar(address: string) {
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!

    let tempMyCar = myCarModel.myCar.filter(car => {
      let array = car.storeId.split('store_0')
      let index = Number(array[1])
      if (address.includes('南京市')) {
        return index <= 20
      } else {
        return index > 20
      }
    })
    return tempMyCar
  }

  public addMyCar(storeId: string, carId: string) {
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let storeCar = myCarModel.myCar.find(car => car.storeId === storeId)
    if (storeCar) {
      storeCar.goodsList.forEach((carGoods: CarGoodsInfo) => {
        if (carGoods.id === carId) {
          carGoods.num++;
          if (storeCar) {
            storeCar.num++;
            storeCar.money = storeCar.money + carGoods.money
          }

        }
      })
      return 1
    } else {
      return 0
    }
  }

  public batchDeleteCar(carIds: string[]) {
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let tempMyCars: MyCar[] = []
    let tempStoreIds: string[] = []
    myCarModel.myCar.forEach((storeCar) => {
      let tempGoodsList: CarGoodsInfo[] = []
      let tempGoodsTotalNum: number = 0
      let tempGoodsTotalMoney: number = 0
      let tempGoodsMust: number = 0
      storeCar.goodsList.forEach((carGoods: CarGoodsInfo) => {
        if (!carIds.includes(carGoods.id)) {
          tempGoodsList.push(carGoods)
          tempGoodsTotalNum += carGoods.num
          tempGoodsTotalMoney += (carGoods.money * carGoods.num)
          if (carGoods.isMust === 1) {
            // 必选数量
            tempGoodsMust += carGoods.num
          }
        }
      })
      if (tempGoodsList.length > 0) {
        let tempMyCar: MyCar = new MyCar()
        tempMyCar.storeId = storeCar.storeId
        tempMyCar.storeInfo = storeCar.storeInfo
        tempMyCar.goodsList = tempGoodsList
        tempMyCar.num = tempGoodsTotalNum
        tempMyCar.money = tempGoodsTotalMoney
        tempMyCar.isMust = tempGoodsMust
        tempMyCar.isCheck = 0
        tempMyCar.checkCarIds = []
        tempMyCars.push(tempMyCar)
        tempStoreIds.push(storeCar.storeId)
      }

    })
    myCarModel.myCar = tempMyCars
    return 1
  }

  public subMyCar(storeId: string, carId: string) {
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let storeCar = myCarModel.myCar.find(car => car.storeId === storeId)
    let flag = false
    if (storeCar) {
      storeCar.goodsList.forEach((carGoods: CarGoodsInfo) => {
        if (carGoods.id === carId && storeCar) {
          flag = carGoods.num === 1
          storeCar.num--;
          storeCar.money = storeCar.money - carGoods.money
          if (!flag) {
            carGoods.num--;
          }
        }
      })
      if (flag) {
        storeCar.goodsList = storeCar.goodsList.filter((carGoods: CarGoodsInfo) => carGoods.id !== carId)
      }
      if (storeCar.goodsList.length === 0) {
        myCarModel.myCar = myCarModel.myCar.filter(car => car.storeId !== storeCar?.storeId)
      }
      return 1
    } else {
      return 0
    }
  }

  batchAddCarGoods(data: CarGoodsInfo[], storeId: string) {
    // 创建新的店铺购物车
    let storeCar = new MyCar()
    storeCar.storeId = storeId
    // 获取店铺信息
    const storeInfo = StoreServiceApi.queryStoreByStoreId(storeId)
    if (!storeInfo) {
      return 0
    }
    storeCar.storeInfo = new StoreModel(storeInfo)
    // 批量添加商品到购物车
    data.forEach((carGoods: CarGoodsInfo) => {
      carGoods.isCheck = true
      storeCar!.goodsList.push(carGoods)
      storeCar!.num += carGoods.num
      storeCar!.money += carGoods.money * carGoods.num
      if (carGoods.isMust) {
        storeCar!.isMust += carGoods.num
      }
    })
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    myCarModel.myCar = myCarModel.myCar.filter(car => car.storeId !== storeId)
    myCarModel.myCar.push(storeCar)
    return 1
  }
}


const instance = new MyCartService();

export { instance as MyCartServiceApi };