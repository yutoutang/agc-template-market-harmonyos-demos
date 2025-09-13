import { HttpStatusCode } from '@ohos/axios';
import { axiosInstance } from '../apis/HttpRequest';
import { AxiosMock } from './AxiosMock';
import { EXCHANGE_INFO } from './MockData/Exchange';

const mock: AxiosMock = new AxiosMock(axiosInstance, {
  delayResponse: 300,
});

mock.onGet('/exchange/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: EXCHANGE_INFO,
  };
});