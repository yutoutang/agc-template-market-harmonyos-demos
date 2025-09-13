import { myCarMapper, MyCarModel, OrderTypeEnum, PackageSpec, StoreInfo, StoreInfoModel } from 'common';
import {
  AddDnOrderReq,
  BaseResponse,
  DishesTypeResp,
  GoodsReq,
  GoodsResp,
  GoodsSpecResp,
  HttpCode,
  HttpRequest,
  MyCarResp,
  StoreInfoResp,
  UserInfoResp,
} from 'network';
import { BusinessError } from '@kit.BasicServicesKit';
import { storeInfoMapper } from '../mapper/Index';
import { Goods } from '../models/Index';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { CarGoodsInfo, CouponItem } from 'base_ui';

export function getStoreInfo(storeId: string): Promise<StoreInfo> {
  return new Promise((resolve, reject) => {
    HttpRequest.getStoreInfo(storeId)
      .then((resp: BaseResponse<StoreInfoResp>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getStoreInfo resp:${JSON.stringify(resp)}.`);
          resolve(storeInfoMapper(resp.data))
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

export function getGoodInfo(goodsId: string = ''): Promise<GoodsResp> {
  return new Promise((resolve, reject) => {
    if (!goodsId) {
      console.error(`getGoodInfo error. goodsId is empty: ${JSON.stringify(goodsId)}.`);
      reject(`getGoodInfo error. goodsId is empty: ${JSON.stringify(goodsId)}.`)
      return
    }
    HttpRequest.getGoodInfo(goodsId).then((resp: BaseResponse<GoodsResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        resolve(resp.data)
        console.info(`getGoodInfo resp:${JSON.stringify(resp)}.`);
      } else {
        console.error(`getGoodInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getMyCar(): Promise<MyCarResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getMyCar().then((resp: BaseResponse<MyCarResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getMyCar resp:${JSON.stringify(resp)}.`);
        let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
        myCarModel.myCar = myCarMapper(resp.data)
        resolve(resp.data)
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

export function addCar(goods: Goods, num: number = 1): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.addCar(goods, num).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`addCar resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp.data)
      } else {
        console.error(`addCar error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addCarSpec(selectSpecInfo: GoodsSpecResp, goodsId: string | undefined,
  num: number = 1): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!goodsId) {
      console.error(`addCarSpec error.goodsId is empty.`);
      reject(`addCarSpec error.goodsId is empty.`)
      return
    }
    HttpRequest.addCarBySpec(goodsId, selectSpecInfo, num).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`addCarSpec resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp.data)
      } else {
        console.error(`addCarSpec error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addCarSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function updateMyCar(carId: string, num: number): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.updateMyCar(carId, num).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`updateMyCar resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp.data)
      } else {
        console.error(`updateMyCar error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`updateMyCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function addDnOrder(list: Array<CarGoodsInfo>, params: AddDnOrderReq): Promise<number> {
  return new Promise((resolve, reject) => {
    let sz: Array<GoodsReq> = list?.map((carGood: CarGoodsInfo) => {
      let goodsReq: GoodsReq = {
        id: carGood.goodsId,
        img: carGood.logo,
        money: carGood.money,
        name: carGood.name,
        num: carGood.num,
        spec: carGood.spec,
        combination: carGood.combination,
      }
      return goodsReq
    })
    let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
    let req: AddDnOrderReq = {
      tableId: myCarModel.tableId,
      money: params.money,
      reductionMoney: params.reductionMoney,
      discount: '0',
      mjMoney: params.mjMoney,
      xyhMoney: params.xyhMoney,
      note: params.note,
      payType: params.payType,
      sz: JSON.stringify(sz),
      tableware: myCarModel.dinerNum,
      yhqMoney: params.yhqMoney ?? 0,
      couponId: params.couponId,
      orderType: params.orderType,
      boxMoney: params.orderType === OrderTypeEnum.PICK_SELF ? 0 : params.boxMoney, // orderType为0堂食，无打包费；为4外带，有打包费
      rechargeId: params.rechargeId,
      preorderTime: params.preorderTime,
      preorderPhone: params.preorderPhone,
    }
    HttpRequest.addDnOrder(req).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`AddDnOrder resp:${JSON.stringify(resp)}.`);
        getMyCar()
        resolve(resp.data)
      } else {
        console.error(`AddDnOrder error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`AddDnOrder error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}


export function clearCar(): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.clearMyCar()
      .then((resp: BaseResponse<number>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`clearCar resp:${JSON.stringify(resp)}.`);
          getMyCar()
          resolve(resp.data)
        } else {
          console.error(`clearCar error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`clearCar error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}


export function getDishesList(): Promise<Array<DishesTypeResp>> {
  return new Promise((resolve, reject) => {
    let storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
    if (!storeModel.storeId) {
      console.error('storeId is empty!');
      reject('storeId is empty!')
      return
    }
    HttpRequest.getDishesList(storeModel.storeId)
      .then((resp: BaseResponse<Array<DishesTypeResp>>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getDishesList resp:${JSON.stringify(resp)}.`);
          resolve(resp.data)
        } else {
          console.error(`getDishesList error: ${JSON.stringify(resp)}.`);
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getDishesList error: ${JSON.stringify(e)}.`);
      })
  })
}

export function getGoodSpec(goodsId: string = '', selectSpecArr: PackageSpec[]): Promise<GoodsSpecResp> {
  return new Promise((resolve, reject) => {
    if (!goodsId || !selectSpecArr) {
      console.error(' goodsId or selectSpecArr is empty!');
      reject(' goodsId or selectSpecArr is empty!')
      return
    }
    HttpRequest.getGoodSpec(goodsId, selectSpecArr).then((resp: BaseResponse<GoodsSpecResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getGoodSpec resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getGoodSpec error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getGoodSpec error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getLqCoupons(couponId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.getLqCoupons(couponId).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getLqCoupons resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getLqCoupons error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getLqCoupons error: ${JSON.stringify(e)}.`);
        reject()
      })
  })
}

export function getCouponList(): Promise<Array<CouponItem>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getCoupons().then((resp: BaseResponse<Array<CouponItem>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getCouponList resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
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

export function getIsNew(): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.getIsNew().then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getIsNew resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getIsNew error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getIsNew error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getHuaweiPayInfo(orderId: string = ''): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.getHuaweiPayInfo(orderId).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getHuaweiPayInfo resp：${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getHuaweiPayInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getHuaweiPayInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function purchase(context: common.UIAbilityContext, defaultSuccess: boolean = false): Promise<boolean> {
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
      if (defaultSuccess) {
        // todo 支付失败处理，模板默认成功
        resolve(true)
      } else {
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
      }

    })
  })
}

export function getMyCoupons(): Promise<Array<CouponItem>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getMyCoupons().then((resp: BaseResponse<Array<CouponItem>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getMyCoupons resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getMyCoupons error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getMyCoupons error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getSnackSizedDeal(): Promise<Array<GoodsResp>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getSnackSizedDeal().then((resp: BaseResponse<Array<GoodsResp>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getSnackSizedDeal resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getSnackSizedDeal error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getSnackSizedDeal error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getUserInfo(): Promise<UserInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getUserInfo()
      .then((resp: BaseResponse<UserInfoResp>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getUserInfo resp:${JSON.stringify(resp)}.`);
          resolve(resp.data);
        } else {
          console.error(`getUserInfo error: ${JSON.stringify(resp)}.`);
          reject(resp.msg);
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getUserInfo error: ${JSON.stringify(e)}.`);
        reject(e);
      });
  });
}