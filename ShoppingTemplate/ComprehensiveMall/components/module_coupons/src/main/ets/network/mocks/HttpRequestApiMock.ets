import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import {
  getCouponsMock1, getCouponsMock2, getCouponsMockNull,
} from './mockData/GetCoupons';
import { request } from '../apis/HttpRequestApi';
import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { RequestUrl } from '../types/RequestUrl';
import { GetCouponsResp } from '../types/responseTypes/GetCouponsResp';

class CouponApiMock {
  /** 获取优惠券 **/
  public getCoupons(
    params: GetCouponsRequest,
  ): Promise<BaseSuccessResponse<GetCouponsResp>> {
    if (params.status === '2') {
      return Promise.resolve(getCouponsMock1);
    } else if (params.status === '3' && params.couponStatus === '1') {
      return Promise.resolve(getCouponsMock2);
    }
    return Promise.resolve(getCouponsMockNull);
  }

  public start(adapter: AxiosMockAdapter) {
    adapter.onGet(RequestUrl.URL_COUPONS_GET)
      .reply((config: AxiosRequestConfig) => {
        const params = config.params as GetCouponsRequest;
        let res = getCouponsMockNull;
        if (params.status === '2') {
          res = getCouponsMock1;
        } else if (params.status === '3' && params.couponStatus === '1') {
          res = getCouponsMock2;
        }
        return [HttpStatusCode.Ok, res];
      });
  }
}
export const adapter = new AxiosMockAdapter(request, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const apis = new CouponApiMock();
  apis.start(adapter);
}
