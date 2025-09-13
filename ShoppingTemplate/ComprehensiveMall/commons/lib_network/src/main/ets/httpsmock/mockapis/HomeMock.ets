import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { RequestUrlMap } from '../../constants/Enums';
import { CategoryProductListResp, HomeConfigResp } from '../../types/responses/HomeConfigResponse';
import { MockHomeConfig } from '../mockdata/MockHomeData';

export class HomeMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取首页配置信息
    adapter.onGet(RequestUrlMap.COMMON_HOME_CONFIG).reply(() => {
      const res: HomeConfigResp = {
        code: 0,
        categoryList: MockHomeConfig.categoryBarList,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取分类内商品
    adapter.onGet(RequestUrlMap.COMMON_CATEGORY_PRODUCT).reply((config: AxiosRequestConfig) => {
      const subId = config.params.subId as string
      let list = MockHomeConfig.categoryDataList
      if (subId) {
        list = list.filter((product) => product.subCategoryId === subId)
      }
      const res: CategoryProductListResp = {
        code: 0,
        productList: list,
      };
      return [HttpStatusCode.Ok, res];
    });
  }
}
