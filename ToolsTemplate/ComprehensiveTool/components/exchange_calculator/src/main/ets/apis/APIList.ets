import { AxiosResponse } from '@ohos/axios';
import { axiosInstance } from './HttpRequest';
import '../mocks/RequestMock';
import { Exchange } from '../mocks/MockData/Exchange';

// 查询汇率列表
export const queryExchangeList = (): Promise<AxiosResponse<Exchange, void>> => {
  const url = '/exchange/list';
  return axiosInstance.get(url);
};
