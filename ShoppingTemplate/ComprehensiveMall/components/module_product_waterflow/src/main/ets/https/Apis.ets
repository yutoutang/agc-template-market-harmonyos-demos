import { ProductCardItem, ProductListResp } from '../commons/Types';
import { MOCK_PRODUCT_LIST1, MOCK_PRODUCT_LIST2 } from './MockData';

export class ProductWaterFlowApis {
  private static _requestCount: number = 0;

  public static getProductList(): Promise<ProductListResp> {
    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list: MOCK_PRODUCT_LIST2,
    };
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  public static getProductListByCategoryId(
    id: string,
  ): Promise<ProductListResp> {
    let list: ProductCardItem[] = id.startsWith('1001') ? MOCK_PRODUCT_LIST1 : MOCK_PRODUCT_LIST2
    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list: list,
    };
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  public static getProductListByKeywords(
    words: string,
  ): Promise<ProductListResp> {
    const initList = MOCK_PRODUCT_LIST2.concat(MOCK_PRODUCT_LIST1)
    const list: ProductCardItem[] = words.length
      ? initList.filter((item) => item.title.includes(words))
      : initList;
    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list,
    };
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  private static _mockMultiData() {
    ProductWaterFlowApis._requestCount++;
    const isFinal = ProductWaterFlowApis._requestCount > 2;
    if (isFinal) {
      ProductWaterFlowApis._requestCount = 0;
    }
    return isFinal;
  }

  private static _simulateDelay<T>(data: T, delay: number): Promise<T> {
    return new Promise<T>((resolve) => {
      setTimeout(() => {
        resolve(data);
      }, delay);
    });
  }
}
