import { MyCar, MyCarModel, StoreInfo } from 'common';
import {
  AppInfoResp,
  BaseResponse,
  CouponItem,
  HttpCode,
  HttpRequest,
  MyCarResp,
  StoreInfoResp,
  TableInfoResp,
  UserInfoResp,
} from 'network';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { storeInfoMapper } from 'order';

export function getAppInfo(): Promise<AppInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getAppInfo()
      .then((resp: BaseResponse<AppInfoResp>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getAppInfo resp:${JSON.stringify(resp)}.`);
          resolve(resp.data)
        } else {
          console.error(`getAppInfo error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getAppInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getTableList(): Promise<Array<TableInfoResp>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getTableList()
      .then((resp: BaseResponse<Array<TableInfoResp>>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getTableList resp:${JSON.stringify(resp)}.`);
          resolve(resp.data)
        } else {
          console.error(`getTableList error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getTableList error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getStoreList(): Promise<Array<StoreInfo>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getStoreList()
      .then((resp: BaseResponse<Array<StoreInfoResp>>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getStoreInfo resp:${JSON.stringify(resp)}.`);
          let storeList = resp.data.map((item): StoreInfo => storeInfoMapper(item))
          resolve(storeList)
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

export function getUserInfo(storeId: string, openid: string, unionId: string): Promise<UserInfoResp> {
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

export function getMyCar(): Promise<MyCar> {
  return new Promise((resolve, reject) => {
    HttpRequest.getMyCar().then((resp: BaseResponse<MyCarResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getMyCar resp:${JSON.stringify(resp)}.`);
        let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
        myCarModel.myCar.update(resp.data)
        resolve(myCarModel.myCar)
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

export function clearCar(): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.clearMyCar()
      .then((resp: BaseResponse<number>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`clearCarUtil resp:${JSON.stringify(resp)}.`);
          getMyCar()
          resolve(resp.data)
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
