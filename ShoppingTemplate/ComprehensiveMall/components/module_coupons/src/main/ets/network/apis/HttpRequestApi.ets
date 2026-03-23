import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosResponse } from '@ohos/axios';
import { UtilLog } from '@hw-agconnect/util-log';
import { LOG_TAG } from '../../constants/Contants';
import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { RequestUrl } from '../types/RequestUrl';
import { GetCouponsResp } from '../types/responseTypes/GetCouponsResp';

export const request = axios.create({
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

request.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      UtilLog.error(
        LOG_TAG,
        `https request failed：${response.config.url}. error:`,
        JSON.stringify(response.status),
      );
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    UtilLog.error(LOG_TAG, `https request failed：. error:`, JSON.stringify(error));
    return Promise.reject(error);
  },
);

class HttpRequestApi {
  /** 获取优惠券 **/
  public getCoupons(
    params: GetCouponsRequest,
  ): Promise<BaseSuccessResponse<GetCouponsResp>> {
    return request.get(RequestUrl.URL_COUPONS_GET, { params });
  }
}

const https = new HttpRequestApi();

export { https as Https };
