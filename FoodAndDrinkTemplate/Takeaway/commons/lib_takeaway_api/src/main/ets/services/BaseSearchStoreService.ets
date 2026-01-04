import { RequestStoreListData } from '../params/response/LayoutResponse';
import { MockStore } from './mockdata/MockStore';
import { StoreResponse } from '../params/response/StoreResponse';

/**
 * 外卖base类
 */
export class BaseSearchStoreService {
  public handleRawStore(item: StoreResponse, ignoreRec: boolean = false): StoreResponse {
    const copyItem = JSON.parse(JSON.stringify(item)) as StoreResponse;
    return copyItem;
  }

  public querySearchStoreResultList(search: string, index: number, address: string): RequestStoreListData[] {
    const storeList = address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther
    if (index === 0) {
      const list = storeList
        .filter(v => v.name.includes(search))
        .map(v => this.handleRawStore(v))
        .map(v => this.layoutStoreTrans(v));
      return list;
    } else {
      const list = storeList
        .filter(v => v.name.includes(search) && v.type === (index - 1))
        .map(v => this.handleRawStore(v))
        .map(v => this.layoutStoreTrans(v));
      return list;
    }

  }


  public layoutStoreTrans(store: StoreResponse): RequestStoreListData {
    const resp: RequestStoreListData = {
      articles: [store as StoreResponse],
    };
    return resp;
  }
}

const instance = new BaseSearchStoreService();

export { instance as BaseSearchStoreServiceApi };