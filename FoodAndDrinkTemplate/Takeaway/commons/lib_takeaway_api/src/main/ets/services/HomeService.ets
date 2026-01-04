import { HomeConfigResp } from '../params/response/HomeConfigResponse';
import { AsyncFunc } from '../utils/AsyncUtils';
import { MockHomeConfig } from './mockdata/MockHomeData';
import { SearchMockData } from './mockdata/MockSearchData';
import { MockStore } from './mockdata/MockStore';

/**
 * 首页
 */

export class HomeService {
  @AsyncFunc
  public getHomeConfig(address: string): Promise<HomeConfigResp> {
    return new Promise<HomeConfigResp>((resolve, reject) => {
      const res: HomeConfigResp = {
        code: 0,
        categoryList: MockHomeConfig.categoryBarList,
        storeList: address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther
      };
      resolve(res);
    });

  }

  public getHostSearchList() {
    return SearchMockData.hotSearchList
  }
}


const instance = new HomeService();

export { instance as HomeServiceApi };