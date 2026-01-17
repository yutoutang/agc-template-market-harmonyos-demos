import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { CLOUD_STORAGE_DOMAIN, RequestUrlMap } from '../../constants/Enums';
import {
  CategoryItem, CategoryProductListResp, HomeConfigResp,
  ProductSummaryItem,
} from '../../types/responses/HomeConfigResponse';
import { MockHomeConfig } from '../mockdata/MockHomeData';

export class HomeMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取首页配置信息
    adapter.onGet(RequestUrlMap.COMMON_HOME_CONFIG).reply(() => {
      const categoryBarList = MockHomeConfig.categoryBarList.map((category) => ({
        id: category.id,
        label: category.label,
        iconUrl: CLOUD_STORAGE_DOMAIN + category.iconUrl,
        subCategory: category.subCategory,
      } as CategoryItem))
      const res: HomeConfigResp = {
        code: 0,
        categoryList: categoryBarList,
        searchList: MockHomeConfig.searchList,
        bannerList: MockHomeConfig.bannerList.map((item) => CLOUD_STORAGE_DOMAIN + item),
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取分类内商品
    adapter
      .onGet(RequestUrlMap.COMMON_CATEGORY_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const subId = config.params.subId as string;
        let list = MockHomeConfig.categoryDataList.map((data)=>({
          banner: CLOUD_STORAGE_DOMAIN+data.banner,
          title:data.title,
          id: data.id,
          subCategoryId: data.subCategoryId,
        } as ProductSummaryItem));
        if (subId) {
          list = list.filter((product) => product.subCategoryId === subId);
        }
        const res: CategoryProductListResp = {
          code: 0,
          productList: list,
        };
        return [HttpStatusCode.Ok, res];
      });
  }
}
