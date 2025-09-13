import { BusinessError } from '@kit.BasicServicesKit';
import { BaseResponse, CouponItem, HelpMsgResp, HttpCode, HttpRequest, RechargeRecord, UserInfoResp } from 'network';
import { paymentService } from '@kit.PaymentKit';
import { common } from '@kit.AbilityKit';

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

export function getOpenLoginHm(code: string): Promise<UserInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getOpenLoginHm(encodeURIComponent(code)).then((resp: BaseResponse<UserInfoResp>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getOpenLoginHm resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getOpenLoginHm error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    })
      .catch((e: BusinessError) => {
        console.error(`getOpenLoginHm error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getCancelLogin(): Promise<UserInfoResp> {
  return new Promise((resolve, reject) => {
    HttpRequest.getCloseLoginHm()
      .then((resp: BaseResponse<UserInfoResp>) => {
        if (resp.code === HttpCode.SUCCESS) {
          console.info(`getCancelLogin resp:${JSON.stringify(resp)}.`);
          resolve(resp.data)
        } else {
          console.error(`getCancelLogin error: ${JSON.stringify(resp)}.`);
          reject(resp)
        }
      })
      .catch((e: BusinessError) => {
        console.error(`getCancelLogin error: ${JSON.stringify(e)}.`);
        reject(e)
      })
  })
}

export function getHelpMsg(): Promise<Array<HelpMsgResp>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getHelpMsg().then((resp: BaseResponse<Array<HelpMsgResp>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getHelpMsg resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getHelpMsg error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getHelpMsg error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}

export function rechargeMoney(rechargeTierId: string): Promise<number> {
  return new Promise((resolve, reject) => {
    HttpRequest.rechargeMoney(rechargeTierId).then((resp: BaseResponse<number>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`rechargeMoney resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`rechargeMoney error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`rechargeMoney error: ${JSON.stringify(e)}.`);
      reject(e)
    })
  })
}

export function getRechargeRecord(): Promise<Array<RechargeRecord>> {
  return new Promise((resolve, reject) => {
    HttpRequest.getRechargeRecord().then((resp: BaseResponse<Array<RechargeRecord>>) => {
      if (resp.code === HttpCode.SUCCESS) {
        console.info(`getRechargeRecord resp:${JSON.stringify(resp)}.`);
        resolve(resp.data)
      } else {
        console.error(`getRechargeRecord error: ${JSON.stringify(resp)}.`);
        reject(resp)
      }
    }).catch((e: BusinessError) => {
      console.error(`getRechargeRecord error: ${JSON.stringify(e)}.`);
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

export function purchase(context: common.UIAbilityContext): Promise<boolean> {
  return new Promise((resolve, reject) => {
    const orderStr =
      '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}';
    paymentService.requestPayment(context, orderStr).then(() => {
      console.info('fzp  pay succeed');
      resolve(true)
    }).catch((error: BusinessError) => {
      resolve(true)
    })
  })
}