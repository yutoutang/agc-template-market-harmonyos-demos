import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { axiosInstance } from '../apis/HttpRequest';
import { FeedBack } from '../model/FeedBacks';
import { AppStorageBank } from '../utils/AppStorageBank';
import { AxiosMock } from './AxiosMock';

const mock: AxiosMock = new AxiosMock(axiosInstance, {
  delayResponse: 300,
});

mock.onPost('/feedback/add').reply(async (config: AxiosRequestConfig) => {
  const data = JSON.parse(config.data) as FeedBack;
  AppStorageBank.addFeedback(data)
  return {
    status: HttpStatusCode.Ok,
  };
});

mock.onGet('/feedback/list').reply(async () => {
  return {
    status: HttpStatusCode.Ok,
    data: AppStorageBank.getFeedBacks()
  };
});