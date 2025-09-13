import { promptAction } from '@kit.ArkUI';
import { CommonConstants } from '../../constants/Contants';
import { FullLoading } from '../../utils/FullLoading';
import { Logger } from '../../utils/Logger';
import { GetCouponsRequest } from '../types/AxiosRequestParam';
import { BaseSuccessResponse } from '../types/BaseSuccessResponse';
import { RequestUrl } from '../types/RequestUrl';
import { httpsMock } from './HttpRequestApiMock';

export async function replaceMockData(
  url: string | undefined,
  args: Object,
): Promise<Object | string> {
  let response: BaseSuccessResponse | undefined;
  switch (url) {
    case RequestUrl.URL_COUPONS_GET:
      response = await httpsMock.getCoupons(args as GetCouponsRequest);
      break;
    default:
      return mockErrorHandler('cannot find url.');
  }
  if (response) {
    const delayResponse: BaseSuccessResponse = await simulateDelay(
      response,
      CommonConstants.SIMULATE_DELAY,
    );
    FullLoading.close();
    return Promise.resolve(delayResponse);
  }
  return mockErrorHandler('cannot find mock function.');
}

function simulateDelay<T>(data: T, delay: number): Promise<T> {
  return new Promise<T>((resolve) => {
    setTimeout(() => {
      resolve(data);
    }, delay);
  });
}

function mockErrorHandler(msg?: string): Promise<string> {
  const errMsg: string = 'replace mock data failed!';
  FullLoading.close();
  promptAction.showToast({ message: errMsg });
  Logger.error('[MockRequest]', msg ?? '', errMsg);
  return Promise.reject(errMsg);
}
