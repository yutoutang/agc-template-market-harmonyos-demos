import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosError, AxiosInstance } from '@ohos/axios';
import { Logger } from '../../utils/Logger';
import { replaceMockData } from '../mocks/MockRequestMap';
import {
  HttpRequestConfig,
  InterceptorHooks,
} from '../types/HttpRequestConfig';

/**
 * 网络请求构造
 * 基于axios框架实现
 */
export class AxiosHttpRequest {
  config: HttpRequestConfig;
  instance: AxiosInstance;
  interceptorHooks?: InterceptorHooks;
  openMock: boolean = false;

  constructor(config: HttpRequestConfig, openMock: boolean = false) {
    this.config = config;
    this.instance = axios.create(config);
    this.interceptorHooks = config.interceptorHooks;
    this.openMock = openMock;
    this._setupInterceptor();
  }

  private _setupInterceptor(): void {
    this.instance.interceptors.request.use(
      this.interceptorHooks?.requestInterceptor,
      this.interceptorHooks?.requestInterceptorCatch,
    );
    this.instance.interceptors.response.use(
      this.interceptorHooks?.responseInterceptor,
      this.openMock
        ? this._replaceMock
        : this.interceptorHooks?.responseInterceptorCatch,
    );
  }

  private _replaceMock(error: AxiosError): Promise<Object> {
    if (error.config && error.config.baseURL === '') {
      if (error.config.params) {
        return replaceMockData(error.config.url, error.config.params);
      }

      const data: object = JSON.parse(error.config.data ?? '{}');
      return replaceMockData(error.config.url, data);
    }
    return Promise.reject(error.response?.data);
  }

  private _request<T>(config: HttpRequestConfig): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      this.instance
        .request<Object, T>(config)
        .then((res) => {
          resolve(res);
        })
        .catch((err: BusinessError) => {
          Logger.error(`网络请求Request异常：${config.url}`, err.message);
          if (err) {
            reject(err);
          }
        });
    });
  }

  public get<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'GET';
    return this._request(config);
  }

  public post<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'POST';
    return this._request(config);
  }

  public put<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'PUT';
    return this._request(config);
  }

  public delete<T>(config: HttpRequestConfig): Promise<T> {
    config.method = 'DELETE';
    return this._request(config);
  }
}

export default AxiosHttpRequest;
