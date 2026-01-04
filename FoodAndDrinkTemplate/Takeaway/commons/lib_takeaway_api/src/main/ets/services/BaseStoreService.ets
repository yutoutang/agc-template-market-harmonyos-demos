import { StoreResponse } from '../params/response/StoreResponse';
import { MockStore } from './mockdata/MockStore';

/**
 * 外卖base类
 */
export class BaseStoreService {
  /**
   * 查询数据库字段
   * @param newsType
   * @param newsId
   * @returns
   */
  public queryRawStore(newsId: string): StoreResponse | undefined {
    let list: StoreResponse[] = [...MockStore.storeList, ...MockStore.storeListOther];
    return list.find(v => v.id === newsId);
  }
}

const instance = new BaseStoreService();

export { instance as BaseStoreServiceApi };