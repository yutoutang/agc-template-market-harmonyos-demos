import { promptAction } from '@kit.ArkUI';
import { mockMap } from '../constants/Constant';
import { BaseResponse } from '../model/IResponse';

// 模拟一个延时的 mock 方法，延迟时间为 `delay` 毫秒
function simulateDelay<T>(data: T, delay: number): Promise<T> {
  return new Promise<T>((resolve) => {
    setTimeout(() => {
      resolve(data);
    }, delay);
  });
}

function mockErrorHandler(msg?: string): Promise<string> {
  const errMsg: string = 'replace mock data failed!';
  return Promise.reject(errMsg);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<ESObject> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url === item[0]);
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 500);
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('cannot find mock function.');
  }
  return mockErrorHandler('cannot find url.');
}
