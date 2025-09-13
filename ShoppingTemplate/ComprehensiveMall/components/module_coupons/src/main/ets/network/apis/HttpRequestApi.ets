import { AxiosRequestHeaders } from '@ohos/axios';
import axiosClient from '../models/AxiosRequest';
import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { RequestUrl } from '../types/RequestUrl';
import { GetCouponsResp } from '../types/responseTypes/GetCouponsResp';

class HttpRequestApi {
  /** 获取优惠券 **/
  public getCoupons(
    params: GetCouponsRequest,
  ): Promise<BaseSuccessResponse<GetCouponsResp>> {
    return axiosClient.get({
      url: RequestUrl.URL_COUPONS_GET,
      showLoading: true,
      headers: {} as AxiosRequestHeaders,
      params: params,
    });
  }
}

const https = new HttpRequestApi();

export { https as Https };
