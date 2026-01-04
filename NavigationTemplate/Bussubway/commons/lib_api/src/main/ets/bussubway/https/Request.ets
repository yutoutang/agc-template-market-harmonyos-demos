import axios, { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from 'lib_common';

/**
 * 1. 配置axios实例； 2. 在../apis目录下查看接口定义并对接真实后端
 */
const instance = axios.create({
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      Logger.error(
        '[Network]',
        `https request failed：${response.config.url}. error:`,
        JSON.stringify(response.status),
      );
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    Logger.error(
      '[Network]',
      'https request failed：. error:',
      JSON.stringify(error),
    );
    return Promise.reject(error);
  },
);

export { instance as httpRequest }
