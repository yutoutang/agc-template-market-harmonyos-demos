import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosResponse } from '@ohos/axios';
import { Logger } from 'module_ui_base';
import { ShoppingCartApiMap } from './RequestUrlMap';
import {
  CalcCartPriceReq,
  CartDto,
  CartPrice,
  CartProductInfo,
  DeleteCartReq,
  UpdateCartReq,
} from '../commons/Types';

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

class ShoppingCartApis {
  /**
   * 获取购物车信息
   */
  public getCartData(): Promise<CartDto> {
    return request.get(ShoppingCartApiMap.CART_INFO)
  }

  /**
   * 获取购物车列表数据
   */
  public getCartList(): Promise<CartProductInfo[]> {
    return request.get(ShoppingCartApiMap.CART_LIST)
  }

  /**
   * 新增购物车商品
   */
  public addSkuToCart(data: UpdateCartReq): Promise<number> {
    return request.post(ShoppingCartApiMap.CART_PRODUCT, data)
  }

  /**
   * 更新购物车商品数量
   */
  public updateProductSkuCount(data: UpdateCartReq): Promise<number> {
    return request.put(ShoppingCartApiMap.CART_PRODUCT, data)
  }

  /**
   * 删除购物车商品
   */
  public deleteSkuFromCart(data: DeleteCartReq): Promise<number> {
    return request.delete(ShoppingCartApiMap.CART_PRODUCT, { data })
  }

  /**
   * 计算购物车金额
   */
  public calcCartPrice(params: CalcCartPriceReq): Promise<CartPrice> {
    return request.get(ShoppingCartApiMap.CART_PRICE, { params })
  }
}

const apis = new ShoppingCartApis();

export { apis as ShoppingCartApis };
