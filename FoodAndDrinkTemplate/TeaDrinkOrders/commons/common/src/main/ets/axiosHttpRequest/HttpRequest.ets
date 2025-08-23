import { BusinessError } from '@kit.BasicServicesKit';
import {
  AddressInfo,
  BaseResponse,
  CarGoodsInfo,
  CouponResp,
  DishesType,
  Goods,
  GoodsSpec,
  GoodsSpecInfo,
  GoodsSpecVal,
  MyCar,
  MyCoupon,
  MyOrderInfo,
  PackageSpec,
  StoreInfo,
  UserInfo,
} from '../models/ResponseModel';
import * as HttpRequestApi from '../axiosHttpRequest/HttpRequestApi';
import { AddDnOrderReq, GoodsReq } from '../models/RequestModel';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';
import { HttpCode } from '../constants/Common';
import { MyCarModel, StoreInfoModel, UserInfoModel } from '../models/StorageModel';

export function getCancelLogin(): Promise<UserInfo> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getCloseLoginHm()
      .then((resp: UserInfo) => {
        if (resp) {
          console.info(`getCancelLoginUtil resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getCancelLoginUtil error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getCancelLoginUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getStoreInfo(): Promise<StoreInfo> {
  return new Promise((resolve, reject) => {
    let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel) as StoreInfoModel;
    if (!storeInfo?.storeId) {
      console.error('storeId is empty!');
      reject('storeId is empty!')
      return
    }
    HttpRequestApi.getStoreInfo(storeInfo.storeId)
      .then((resp: StoreInfo) => {
        if (resp) {
          console.info(`getStoreInfo resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getStoreInfo error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getStoreInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getCouponList(): Promise<Array<CouponResp>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getCoupons().then((resp: Array<CouponResp>) => {
      if (resp.length) {
        console.info(`getCouponList resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getCouponList error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getCouponList error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getLqCoupons(couponId: string): Promise<void> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.postLqCoupons(couponId).then((resp: BaseResponse) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getLqCouponsUtil resp:${JSON.stringify(resp)}.`);
        resolve()
      } else {
        console.error(`getLqCouponsUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getLqCouponsUtil error: ${JSON.stringify(e)}.`);
        reject()
      })
  })
}

export function getMyCoupons(): Promise<Array<MyCoupon>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyCoupons().then((resp: BaseResponse<Array<MyCoupon>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getMyCouponsUtil resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getMyCouponsUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getMyCouponsUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getGoodsInfo(goodsId: string = ''): Promise<Goods> {
  return new Promise((resolve, reject) => {
    if (!goodsId) {
      console.error(`getGoodsInfo error. GoodsId is empty: ${JSON.stringify(goodsId)}.`);
      reject(`getGoodsInfo error. GoodsId is empty: ${JSON.stringify(goodsId)}.`)
      return
    }
    HttpRequestApi.getGoodsInfo(goodsId).then((resp: Goods) => {
      if (resp) {
        let goods: Goods = resp
        goods.id = resp.id
        goods.name = resp.name
        goods.logo = resp.logo
        goods.bigImg = resp.bigImg
        goods.money = resp.money
        goods.content = resp.content
        goods.sales = resp.sales
        goods.specType = resp.specType
        goods.details = resp.details
        goods.num = resp.num
        goods.spec = resp.spec?.map((item: GoodsSpec) => {
          let specVal = item.specVal.map((specInfo: GoodsSpecVal) => {
            let temp = new GoodsSpecVal()
            temp.specValId = specInfo.specValId
            temp.specValName = specInfo.specValName
            temp.specValLogo = specInfo.specValLogo
            temp.specValNum = specInfo.specValNum
            temp.id = specInfo.id
            temp.name = specInfo.name
            temp.logo = specInfo.logo
            return temp
          })
          return new GoodsSpec(item.specId, item.specName, item.specValId, specVal)
        }) ?? []
        goods.boxMoney = resp.boxMoney
        resolve(resp)
        console.info(`getGoodsInfo resp:${JSON.stringify(resp)}.`);
      } else {
        console.error(`getGoodsInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodsInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getMyCar(): Promise<MyCar> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyCar().then((resp: MyCar) => {
      if (resp) {
        console.info(`getMyCar resp:${JSON.stringify(resp)}.`);
        let myCar: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
        myCar.myCar = resp
        myCar.carCheck = myCar.carCheck.filter(item => myCar.myCar.carGoods.some(carGoods => carGoods.id === item))
        resolve(resp)
      } else {
        console.error(`getMyCar error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getMyCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addCarSpec(selectSpecInfo: GoodsSpecInfo, goodsId: string | undefined,
  num: number = 1): Promise<string> {
  return new Promise((resolve, reject) => {
    if (!goodsId) {
      console.error(`addCarSpecUtil error.goodsId is empty.`);
      reject(`addCarSpecUtil error.goodsId is empty.`)
      return
    }
    HttpRequestApi.addCarBySpec(goodsId, selectSpecInfo, num).then((resp: BaseResponse<string | undefined>) => {
      if (resp.code === HttpCode.SUCCESS && resp.data) {
        console.info(`addCarSpecUtil resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp.data)
      } else {
        console.error(`addCarSpecUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addCarSpecUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function updateMyCar(carId: string, num: number): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.updateMyCar(carId, num).then((resp: number) => {
      if (resp) {
        console.info(`updateMyCarUtil resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp)
      } else {
        console.error(`updateMyCarUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`updateMyCarUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addDnOrder(list: Array<CarGoodsInfo>, params: AddDnOrderReq, storeInfo: StoreInfo,
  selectAddress: AddressInfo): Promise<number> {
  return new Promise((resolve, reject) => {
    let userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
    let storeStorage: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
    let sz = list?.map((carGoods: CarGoodsInfo) => {
      return {
        id: carGoods.id,
        goodsId: carGoods.goodsId,
        img: carGoods.logo,
        money: carGoods.money,
        name: carGoods.name,
        num: carGoods.num,
        spec: carGoods.spec,
        specType: carGoods.specType,
        combination: carGoods.combination,
      } as GoodsReq
    }) as Array<GoodsReq>
    let req = {
      userId: userInfo.userInfo.id,
      storeId: storeStorage.storeId,
      money: params.money,
      mjMoney: params.mjMoney,
      xyhMoney: params.xyhMoney,
      note: params.note,
      type: 2,
      formId: 1,
      formId2: 1,
      payType: 0,
      sz: JSON.stringify(sz),
      cutlery: params.cutlery,
      yhqMoney: params.yhqMoney ?? '0',
      couponId: params.couponId,
      orderType: params.orderType,
      boxMoney: params.orderType === 1 ? 0 : params.boxMoney,
      bagMoney: params.bagMoney,
      storeName: storeInfo.name,
      address: storeInfo.address,
      tel: storeInfo.tel,
      coordinates: storeInfo.coordinates,
      addressPre: selectAddress.addressPre,
      addressNum: selectAddress.addressNum,
      latitude: selectAddress.latitude,
      longitude: selectAddress.longitude,
      addressName: selectAddress.name,
      addressTel: selectAddress.tel,
    } as AddDnOrderReq
    HttpRequestApi.addDnOrder(req).then((resp: number) => {
      if (resp) {
        console.info(`AddDnOrderUtil resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp)
      } else {
        console.error(`AddDnOrderUtil error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`AddDnOrderUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function clearCar(): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.clearMyCar()
      .then((resp: number) => {
        if (resp) {
          console.info(`clearCarUtil resp:${JSON.stringify(resp)}.`);
          getMyCar()
          resolve(resp)
        } else {
          console.error(`clearCarUtil error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`clearCarUtil error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}


export function getDishesList(): Promise<Array<DishesType>> {
  return new Promise((resolve, reject) => {
    let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel) as StoreInfoModel;
    if (!storeInfo?.storeId) {
      console.error('storeId is empty!');
      reject('storeId is empty!')
      return
    }
    HttpRequestApi.getDishesList(storeInfo.storeId)
      .then((resp: Array<DishesType>) => {
        if (resp.length) {
          console.info(`getDishesList resp:${JSON.stringify(resp)}.`);
          resolve(resp)
        } else {
          console.error(`getDishesList error: ${JSON.stringify(resp)}.`);
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getDishesList error: ${JSON.stringify(e)}.`);
      })
  })
}

export function getGoodsSpec(goodsId: string = '', selectSpecArr: PackageSpec[]): Promise<GoodsSpecInfo> {
  return new Promise((resolve, reject) => {
    if (!goodsId || !selectSpecArr) {
      console.error(' GoodsId or selectSpecArr is empty!');
      reject(' GoodsId or selectSpecArr is empty!')
      return
    }
    HttpRequestApi.getGoodsSpec(goodsId, selectSpecArr).then((resp: BaseResponse<GoodsSpecInfo>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getGoodsSpec resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getGoodsSpec error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodsSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

/**
 * 订单列表页
 * @param page
 * @param tab
 * @returns
 */
export function getMyOrder(page: number = 0, tab: number): Promise<Array<MyOrderInfo>> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getMyOrder(page, tab).then((resp: Array<MyOrderInfo>) => {
      if (resp) {
        console.info(`getMyOrder resp:${JSON.stringify(resp)}.`);
        resolve(resp)
      } else {
        console.error(`getMyOrder error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getMyOrder error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}

export function cancelOrder(orderId: string): Promise<boolean> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.cancelOrder(orderId)
      .then((resp: BaseResponse) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`cancelOrder resp：${JSON.stringify(resp)}.`);
          promptAction.showToast({ message: $r('app.string.cancel_success') })
          resolve(true)
        } else {
          console.error(`cancelOrder error: ${JSON.stringify(resp)}.`);
          promptAction.showToast({ message: $r('app.string.cancel_failed') })
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`cancelOrder error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getPurchase(context: common.UIAbilityContext): Promise<boolean> {
  return new Promise((resolve, reject) => {
    const orderStr =
      '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
    paymentService.requestPayment(context, orderStr).then(() => {
      console.info('fzp  pay succeed');
      resolve(true)
      promptAction.showToast({
        message: $r('app.string.pay_success'),
        duration: 1000,
      })

    }).catch((error: BusinessError) => {
      console.error('fzp  pay failed.error:' + error.code);
      let payStr = $r('app.string.request_failed')
      if (error.code === HttpCode.CANCEL_PAY) {
        payStr = $r('app.string.cancel_pay')
      } else if (error.code === HttpCode.PAY_FAILED) {
        payStr = $r('app.string.pay_failed')
      } else if (error.code === HttpCode.NETWORK_ERROR) {
        payStr = $r('app.string.network_error')
      } else if (error.code === HttpCode.DUPLICATE_REQUEST) {
        payStr = $r('app.string.duplicate_request')
      }
      promptAction.showToast({
        message: payStr,
        duration: 1000,
      })
      reject(error.code)
    })
  })
}

/**
 * 隐私政策
 */
export function getPrivacyInfo(): Promise<string> {
  return new Promise((resolve, reject) => {
    HttpRequestApi.getPrivacyInfo().then((resp: BaseResponse<string>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getPrivacyInfo resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getPrivacyInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getPrivacyInfo error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}