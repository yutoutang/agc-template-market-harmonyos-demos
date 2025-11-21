import { RequestUrlMap } from '../../constants/Enums';
import { ProductListReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductCollectStatusResp,
  ProductListResp,
} from '../../types/responses/ProductResponse';
import request from '../Request';

class ProductApis {
  /**
   * 获取推荐商品列表
   */
  public getProductList(params: ProductListReq): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_LIST, { params });
  }

  /**
   * 收藏商品
   */
  public collectProduct(productId: string): Promise<BaseResponse> {
    return request.get(RequestUrlMap.PRODUCT_COLLECT, {
      params: { productId },
    });
  }

  /**
   * 取消收藏商品
   */
  public cancelCollectProduct(productIds: string[]): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.PRODUCT_COLLECT, {
      params: { productIds },
    });
  }

  /**
   * 获取收藏商品列表
   */
  public getCollectedProductList(
    params: ProductListReq,
  ): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_COLLECTED_LIST, { params });
  }

  /**
   * 获取指定商品的收藏状态
   */
  public getProductCollectStatus(
    productId: string,
  ): Promise<ProductCollectStatusResp> {
    return request.get(RequestUrlMap.PRODUCT_COLLECT_STATUS, {
      params: { productId },
    });
  }

  /**
   * 添加浏览记录
   */
  public addProductViewHistory(productId: string): Promise<BaseResponse> {
    return request.post(RequestUrlMap.PRODUCT_VIEW_HISTORY, productId);
  }

  /**
   * 删除浏览记录
   */
  public deleteProductViewHistory(productIds: string[]): Promise<BaseResponse> {
    return request.delete(RequestUrlMap.PRODUCT_VIEW_HISTORY, {
      params: { productIds },
    });
  }

  /**
   * 获取浏览记录列表
   */
  public getProductViewHistory(
    params: ProductListReq,
  ): Promise<ProductListResp> {
    return request.get(RequestUrlMap.PRODUCT_VIEW_HISTORY_LIST, { params });
  }
}

const instance = new ProductApis();

export { instance as ProductApis };
