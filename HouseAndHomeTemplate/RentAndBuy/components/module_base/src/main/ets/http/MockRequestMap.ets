import { promptAction } from '@kit.ArkUI';
import { mockMap } from '../constant/Constant';
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
  const errMsg: string = 'replace mock data fail!';
  return Promise.reject(errMsg);
}

export async function replaceMockData(url: string | undefined, ...args: ESObject[]): Promise<ESObject> {
  const arr = Object.entries(mockMap);
  if (url) {
    const func = arr.find((item) => url === item[0]);
    if (func) {
      const response: BaseResponse = await func[1](...args);
      const delayResponse: BaseResponse = await simulateDelay(response, 200);
      return Promise.resolve(delayResponse);
    }
    return mockErrorHandler('can not find mock function.');
  }
  return mockErrorHandler('can not find url.');
}
