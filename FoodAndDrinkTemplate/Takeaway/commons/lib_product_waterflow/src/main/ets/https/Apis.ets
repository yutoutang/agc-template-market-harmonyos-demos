import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';
import { MockStore } from 'lib_takeaway_api/src/main/ets/services/mockdata/MockStore';
import { ProductListResp } from '../commons/Types';

export class ProductWaterFlowApis {
  private static _requestCount: number = 0;

  /**
   * 根据评分、销量和配送时间筛选店铺（参数均为可选）
   * @param scoreThreshold - 最低评分阈值（可选）
   * @param salesThreshold - 最低销量阈值（可选）
   * @param deliveryTimeThreshold - 最大配送时间阈值（可选）
   * @returns Promise<ProductListResp> - 筛选后的店铺列表
   */
  public static getProductListByOptionalFilters(
    address: string,
    scoreThreshold?: number,
    salesThreshold?: number,
    deliveryTimeThreshold?: number
  ): Promise<ProductListResp> {
    // 从 MockStore.list 获取原始数据并进行筛选
    const storeList = address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther
    const filteredList: StoreResponse[] = storeList.filter((store) => {
      // 评分筛选: 如果提供了评分阈值，则检查评分是否满足条件
      const scorePass = scoreThreshold !== undefined ? store.score >= scoreThreshold : true;

      // 销量筛选: 如果提供了销量阈值，则检查销量是否满足条件
      const salesPass = salesThreshold !== undefined ? store.monthlySales >= salesThreshold : true;

      // 配送时间筛选: 如果提供了配送时间阈值，则检查配送时间是否满足条件
      const deliveryTimePass = deliveryTimeThreshold !== undefined ? store.deliveryTime <= deliveryTimeThreshold : true;

      // 只有所有提供的条件都满足才保留该店铺
      return scorePass && salesPass && deliveryTimePass;
    });

    // 构造响应对象
    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list: filteredList,
    };

    // 添加500ms延迟模拟网络请求
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  public static getProductList(address: string): Promise<ProductListResp> {
    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list: address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther,
    };
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  /**
   * 根据分类ID获取店铺列表
   * @param id - 分类ID
   * @returns Promise<ProductListResp> - 筛选后的店铺列表
   */
  public static getProductListByCategoryId(
    address: string,
    id: string,
    scoreThreshold?: number,
    salesThreshold?: number,
    deliveryTimeThreshold?: number
  ): Promise<ProductListResp> {
    // 从 MockStore.list 中筛选出 type 值与 id 相同的数据
    const storeList = address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther
    let list: StoreResponse[] = storeList.filter((item) => item.type.toString() === id);
    // 从 list 并进行筛选
    const filteredList: StoreResponse[] = list.filter((store) => {
      // 评分筛选: 如果提供了评分阈值，则检查评分是否满足条件
      const scorePass = scoreThreshold !== undefined ? store.score >= scoreThreshold : true;

      // 销量筛选: 如果提供了销量阈值，则检查销量是否满足条件
      const salesPass = salesThreshold !== undefined ? store.monthlySales >= salesThreshold : true;

      // 配送时间筛选: 如果提供了配送时间阈值，则检查配送时间是否满足条件
      const deliveryTimePass = deliveryTimeThreshold !== undefined ? store.deliveryTime <= deliveryTimeThreshold : true;
      // 只有所有提供的条件都满足才保留该店铺
      return scorePass && salesPass && deliveryTimePass;
    });
    // 按评分值倒序排序（评分高的在前）
    filteredList.sort((a, b) => b.score - a.score);

    const res: ProductListResp = {
      isFinal: ProductWaterFlowApis._mockMultiData(),
      list: filteredList,
    };
    return ProductWaterFlowApis._simulateDelay(res, 500);
  }

  /**
   * 根据关键词获取店铺列表
   * @param words - 关键词
   * @param id - 分类ID
   * @returns Promise<ProductListResp> - 筛选后的店铺列表
   */
  public static getProductListByKeywords(
    address: string,
    words: string,
    id?: string,
  ): Promise<ProductListResp> {
    // 从 MockStore.list 中筛选出 type 值与 id 相同且名称包含关键词的数据
    const initList = address.includes('南京市') ? MockStore.storeList : MockStore.storeListOther;
    const list: StoreResponse[] = words.length ? initList.filter((item) =>
    (id ? item.type.toString() === id : true) &&
      (item.name.includes(words))
    ) : initList.filter((item) => item.type.toString() === id);

    // 按评分值倒序排序（评分高的在前）
    list.sort((a, b) => b.score - a.score);

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
