import { BusinessError } from '@kit.BasicServicesKit';
import { AxiosRequestHeaders, AxiosResponse } from '@ohos/axios';
import { CommonConstants } from '../../constants/Contants';
import { FullLoading } from '../../utils/FullLoading';
import { AxiosHttpRequest } from './AxiosHttp';

const axiosClient = new AxiosHttpRequest(
  {
    baseURL: CommonConstants.BASE_URL,
    timeout: 10 * 3000,
    headers: {} as AxiosRequestHeaders,
    interceptorHooks: {
      requestInterceptor: async (config) => {
        if (config.showLoading) {
          FullLoading.show();
        }
        return config;
      },
      requestInterceptorCatch: (err: BusinessError) => {
        if (FullLoading.isLoading) {
          FullLoading.close();
        }
        return err;
      },
      responseInterceptor: (response: AxiosResponse) => {
        if (FullLoading.isLoading) {
          FullLoading.close();
        }
        if (response.status === 200) {
          return Promise.resolve(response.data);
        } else {
          return Promise.reject(response);
        }
      },
      responseInterceptorCatch: (error: BusinessError) => {
        if (FullLoading.isLoading) {
          FullLoading.close();
        }
        return Promise.reject(error);
      },
    },
  },
  CommonConstants.OPEN_MOCK,
);

export default axiosClient;
