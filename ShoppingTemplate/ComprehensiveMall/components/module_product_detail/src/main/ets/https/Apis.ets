import axios, { AxiosResponse } from '@ohos/axios';
import { Logger } from 'module_ui_base';
import {
  ProductInfo,
  ProductReviewResp,
  ProductSelectionInfo,
} from '../commons/Types';
import { BusinessError } from '@kit.BasicServicesKit';
import { RequestUrlMap } from '../commons/Enums';

const TAG: string = '[ProductDetailApis]';

export const request = axios.create({
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

request.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      Logger.error(
        TAG,
        `https request failed：${response.config.url}. error:`,
        JSON.stringify(response.status),
      );
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    Logger.error(TAG, `https request failed：. error:`, JSON.stringify(error));
    return Promise.reject(error);
  },
);

class ProductDetailApis {
  getProductDetail(id: string): Promise<ProductInfo> {
    return request.get(RequestUrlMap.PRODUCT_DETAIL, { params: { id } });
  }

  getProductStockInfo(id: string): Promise<ProductSelectionInfo> {
    return request.get(RequestUrlMap.PRODUCT_STOCK, { params: { id } });
  }

  getProductReviewList(
    id: string,
    curPage: number,
  ): Promise<ProductReviewResp> {
    return request.get(RequestUrlMap.PRODUCT_REVIEW, {
      params: { id, curPage },
    });
  }
}

const apis = new ProductDetailApis();

export { apis as ProductDetailApis };
