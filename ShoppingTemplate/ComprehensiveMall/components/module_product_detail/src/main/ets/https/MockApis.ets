import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AppStorageV2 } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { Constants } from '../commons/Constants';
import { RequestUrlMap } from '../commons/Enums';
import { ProductReviewListModel } from '../commons/Models';
import { ProductInfo, ProductReviewResp } from '../commons/Types';
import { request } from './Apis';
import { getProductListMock } from './MockData';

@ObservedV2
export class ProductDetailMockApis {
  @Trace
  private _mockList: ProductInfo[] = getProductListMock();
  @Trace
  private _mockReviewList: ProductReviewListModel = AppStorageV2.connect(
    ProductReviewListModel,
    () => new ProductReviewListModel(),
  )!;

  public start(adapter: AxiosMockAdapter) {
    // 获取商品详情
    adapter
      .onGet(RequestUrlMap.PRODUCT_DETAIL)
      .reply((config: AxiosRequestConfig) => {
        const id: string = config.params.id;
        const item = this._mockList.find((item) => item.id === id);
        return [HttpStatusCode.Ok, item];
      });

    // 获取商品库存
    adapter
      .onGet(RequestUrlMap.PRODUCT_STOCK)
      .reply((config: AxiosRequestConfig) => {
        const id: string = config.params.id;
        const item = this._mockList.find((item) => item.id === id);
        return [HttpStatusCode.Ok, item!.selectionInfo];
      });

    // 获取商品评价列表
    adapter
      .onGet(RequestUrlMap.PRODUCT_REVIEW)
      .reply((config: AxiosRequestConfig) => {
        const curPage: number = config.params.curPage;
        const id: string = config.params.id;
        const startIndex = (curPage - 1) * Constants.PAGE_SIZE;
        const endIndex = startIndex + Constants.PAGE_SIZE;
        const list = this._mockReviewList.list;
        const reviewList = list.slice(startIndex, endIndex);
        const isFinal = reviewList.length < Constants.PAGE_SIZE || endIndex === this._mockReviewList.list.length;
        const total = list.length;
        const res: ProductReviewResp = {
          isFinal,
          reviewList,
          curPage,
          total,
        };
        return [HttpStatusCode.Ok, res];
      });
  }
}

export const adapter = new AxiosMockAdapter(request, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const apis = new ProductDetailMockApis();
  apis.start(adapter);
}
