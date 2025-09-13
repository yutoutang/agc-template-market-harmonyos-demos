import { BaseResponse, HttpCode, HttpRequest, MyCarResp, MyOrderResp } from 'network';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { myCarMapper, MyCarModel } from 'common';

export function addGoods(orderId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.addGoods(orderId).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`addGoods resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`addGoods error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`addGoods error: ${JSON.stringify(e)}.`);
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

export function cancelOrder(orderId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.cancelOrder(orderId)
      .then((resp: BaseResponse<number>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`cancelOrder resp：${JSON.stringify(resp)}.`);
          resolve(resp.data)
        } else {
          console.error(`cancelOrder error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`cancelOrder error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function deleteOrder(orderId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.deleteOrder(orderId).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`deleteOrder resp：${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`deleteOrder error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`deleteOrder error: ${JSON.stringify(e)}.`);
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

export function getOrderInfo(orderId: string = ''): Promise<MyOrderResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getOrderInfo(orderId).then((resp: BaseResponse<MyOrderResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getOrderInfo resp：${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getOrderInfo error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getOrderInfo error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getMyOrder(page: number = 0, tab: Array<number>): Promise<Array<MyOrderResp>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getMyOrder(page, tab).then((resp: BaseResponse<Array<MyOrderResp>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getMyOrder resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
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