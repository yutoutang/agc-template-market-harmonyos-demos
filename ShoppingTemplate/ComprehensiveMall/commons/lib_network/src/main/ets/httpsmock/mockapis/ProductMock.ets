import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { PersistenceV2 } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { RequestUrlMap } from '../../constants/Enums';
import { ProductListReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductCardItem,
  ProductCollectStatusResp,
  ProductListResp,
} from '../../types/responses/ProductResponse';
import { MockProductData } from '../mockdata/MockProductData';

@ObservedV2
class CollectedProduct {
  @Trace list: string[] = [];
}

@ObservedV2
class ViewHistoryProduct {
  @Trace list: string[] = [];
}

const enum MockPersistenceMap {
  COLLECTION = 'collection',
  VIEW_HISTORY = 'viewHistory',
}

export class ProductMockApis {
  private readonly PAGE_SIZE = 8;
  private _mockList: ProductCardItem[] = JSON.parse(
    JSON.stringify(MockProductData.PRODUCT_CARD_LIST),
  );

  public start(adapter: AxiosMockAdapter) {
    /** 获取商品列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_LIST)
      .reply((config: AxiosRequestConfig) => {
        const res = this._getFilteredList(this._mockList, config.params);
        return [HttpStatusCode.Ok, res];
      });

    /** 收藏、取消收藏商品 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECT)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.params.productId;
        const collectedList = this._getCollectionList();
        if (!collectedList.list.includes(productId)) {
          collectedList.list.unshift(productId);
        }
        const res: BaseResponse = {
          code: 0,
        };
        return [HttpStatusCode.Ok, res];
      })
      .onDelete(RequestUrlMap.PRODUCT_COLLECT)
      .reply((config: AxiosRequestConfig) => {
        const productIds: string = config.params.productIds;
        const collectedList = this._getCollectionList();
        collectedList.list = collectedList.list.filter(
          (id) => !productIds.includes(id),
        );
        const res: BaseResponse = {
          code: 0,
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取收藏商品列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECTED_LIST)
      .reply((config: AxiosRequestConfig) => {
        const collectedList = this._getCollectionList();
        const initList: ProductCardItem[] = []
        collectedList.list.forEach((id) => {
          const productItem = MockProductData.PRODUCT_CARD_LIST.find((product) => product.productId === id)!
          initList.push(productItem)
        })
        const res = this._getFilteredList(initList, config.params);
        return [HttpStatusCode.Ok, res];
      });

    /** 获取商品是否收藏的状态 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_COLLECT_STATUS)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.params.productId;
        const collectedList = this._getCollectionList();
        const isCollected: boolean = collectedList.list.includes(productId);
        const res: ProductCollectStatusResp = {
          code: 0,
          status: isCollected ? 1 : 0,
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 添加、删除浏览记录 */
    adapter
      .onPost(RequestUrlMap.PRODUCT_VIEW_HISTORY)
      .reply((config: AxiosRequestConfig) => {
        const productId: string = config.data;
        const historyList = this._getMockHistoryList();
        historyList.list = historyList.list.filter((id) => id !== productId);
        historyList.list.unshift(productId);
        const res: BaseResponse = {
          code: 0,
        };
        return [HttpStatusCode.Ok, res];
      })
      .onDelete(RequestUrlMap.PRODUCT_VIEW_HISTORY)
      .reply((config: AxiosRequestConfig) => {
        const productIds: string = config.params.productIds;
        const historyList = this._getMockHistoryList();
        historyList.list = historyList.list.filter(
          (id) => !productIds.includes(id),
        );
        const res: BaseResponse = {
          code: 0,
        };
        return [HttpStatusCode.Ok, res];
      });

    /** 获取浏览记录列表 */
    adapter
      .onGet(RequestUrlMap.PRODUCT_VIEW_HISTORY_LIST)
      .reply((config: AxiosRequestConfig) => {
        const historyList = this._getMockHistoryList();
        const initList: ProductCardItem[] = []
        historyList.list.forEach((id) => {
          const productItem = MockProductData.PRODUCT_CARD_LIST.find((product) => product.productId === id)!
          initList.push(productItem)
        })
        const res = this._getFilteredList(initList, config.params);
        return [HttpStatusCode.Ok, res];
      });
  }

  private _getCollectionList() {
    const data = PersistenceV2.connect(
      CollectedProduct,
      MockPersistenceMap.COLLECTION,
      () => new CollectedProduct(),
    )!;
    return data;
  }

  private _getMockHistoryList() {
    const data = PersistenceV2.connect(
      ViewHistoryProduct,
      MockPersistenceMap.VIEW_HISTORY,
      () => new ViewHistoryProduct(),
    )!;
    return data;
  }

  private _getFilteredList(
    initList: ProductCardItem[],
    params: ProductListReq,
  ) {
    const curPage = params.curPage;
    const sortType = params.sortType;
    const filterList = params.filterList;
    const categoryId = params.categoryId;
    const keyword = params.keyword;
    const targetId = params.targetId;
    const pageSize = this.PAGE_SIZE;
    const startIndex = (curPage - 1) * pageSize;
    let filteredList = initList;

    // 根据分类ID过滤
    if (categoryId) {
      const category = categoryId.split('_');
      filteredList = filteredList.filter((item) => {
        return item.categoryId.startsWith(category[0]);
      });
    }

    // 根据关键字过滤
    if (keyword) {
      filteredList = filteredList.filter((item) =>
      item.title.includes(keyword),
      );
    }

    // 根据筛选条件过滤
    if (filterList?.length && filterList.length > 0) {
      filteredList = filteredList.filter((item) => {
        return filterList.every((filter) => {
          if (filter.value.includes('all') ) {
            return true;
          }
          if (filter.id === 'size') {
            return item.summary.size.some((size)=>filter.value.includes(size));
          }
          if (filter.id === 'price') {
            const prices = filter.value[0].split('-').map((item) => Number(item));
            return (
              item.summary.maxPrice >= prices[0] &&
                item.summary.minPrice <= prices[1]
            );
          }
          return true;
        });
      });
    }

    // 排序逻辑
    switch (sortType) {
      case 1:
        filteredList.sort((a, b) => a.price - b.price);
        break;
      case 2:
        filteredList.sort((a, b) => b.price - a.price);
        break;
      case 3:
        filteredList.sort((a, b) => b.sales - a.sales);
        break;
      default:
        break;
    }

    // 传入targetId时获取指定商品放在第一个
    if (targetId && curPage === 1) {
      const targetProduct = this._mockList.find(
        (item) => item.productId === targetId,
      );
      if (targetProduct) {
        filteredList = filteredList.filter((product) => product.productId !== targetId);
        filteredList.unshift(targetProduct);
      }
    }

    const endIndex = startIndex + this.PAGE_SIZE;
    const list = filteredList.slice(startIndex, endIndex);
    const isFinal =
      list.length < this.PAGE_SIZE || endIndex === filteredList.length;
    const total = filteredList.length;
    const res: ProductListResp = {
      code: 0,
      isFinal,
      list,
      curPage,
      total,
    };
    return res;
  }
}
