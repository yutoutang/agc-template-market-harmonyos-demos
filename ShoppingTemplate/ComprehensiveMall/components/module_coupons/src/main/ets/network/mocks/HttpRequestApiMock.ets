import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { GetCouponsResp } from '../types/responseTypes/GetCouponsResp';
import {
  getCouponsMock1,
  getCouponsMock2,
  getCouponsMockNull,
} from './mockData/GetCoupons';

class HttpRequestApiMock {
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
}

const httpsMock = new HttpRequestApiMock();

export { httpsMock };
