import axios, { AxiosResponse } from '@ohos/axios';
import { BusinessError } from '@kit.BasicServicesKit';
import { BASE_URL } from '../constants/AppConstant';
import { UtilLog } from '@hw-agconnect/util-log';

const instance = axios.create({
  baseURL: BASE_URL,
  timeout: 3000,
});

instance.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      UtilLog.error('[Network]', `https request failed：${response.config.url}. error:` +
      JSON.stringify(response.status));
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    UtilLog.error('[Network]', `https request failed：. error:` + JSON.stringify(error));
    return Promise.reject(error);
  },
);

export default instance;