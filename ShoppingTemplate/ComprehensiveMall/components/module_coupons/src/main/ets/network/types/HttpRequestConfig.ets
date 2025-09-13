import { BusinessError } from '@kit.BasicServicesKit';
import {
  AxiosRequestHeaders,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from '@ohos/axios';

export interface HttpRequestConfig extends InternalAxiosRequestConfig {
  showLoading?: boolean;
  interceptorHooks?: InterceptorHooks;
  method?: string;
  headers: AxiosRequestHeaders;
}

export interface InterceptorHooks {
  requestInterceptor?: (
    config: HttpRequestConfig,
  ) => Promise<HttpRequestConfig>;
  requestInterceptorCatch?: (error: BusinessError) => BusinessError;
  responseInterceptor?: (
    response: AxiosResponse,
  ) => AxiosResponse | Promise<AxiosResponse>;
  responseInterceptorCatch?: (error: BusinessError) => Promise<BusinessError>;
}
