import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { MockCart, ProductModel } from '../commons/Model';
import {
  UpdateCartReq,
  DeleteCartReq,
  CartPrice,
  CalcCartPriceReq,
  CartCardDto,
  CartDto,
  CartProductInfo,
  DiscountItem,
} from '../commons/Types';
import { request } from './Apis';
import { ShoppingCartApiMap } from './RequestUrlMap';
import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { MockProductData } from './MockProductData';

@ObservedV2
export class ShoppingCartMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取购物车列表数据
    adapter
      .onGet(ShoppingCartApiMap.CART_INFO)
      .reply(() => {
        let data = this._getCartData();
        return [HttpStatusCode.Ok, data];
      });

    // 获取购物车列表数据
    adapter
      .onGet(ShoppingCartApiMap.CART_LIST)
      .reply(() => {
        let mockCart: MockCart = this._getMockCart();
        let resList: CartProductInfo[] = [];
        if (mockCart.data) {
          const resData = JSON.parse(mockCart.data) as CartDto;
          resList = resData.cards.map((item: CartCardDto) => {
            let itemData: CartProductInfo = {
              productId: item.productId,
              skuCode: item.skuCode,
              skuDesc: item.skuDesc,
              stock: 10,
              count: item.count,
              banner: item.banner,
              title: item.title,
              serviceDesc: item.serviceDesc,
              price: item.price,
              dashPrice: item.dashPrice,
            }
            return itemData;
          });
        }
        return [HttpStatusCode.Ok, resList];
      });

    // 新增购物车商品
    adapter
      .onPost(ShoppingCartApiMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as UpdateCartReq
        const cartData = this._getCartData();
        const card = cartData.cards.find((item) => item.skuCode === data.skuCode);
        if (card) {
          card.count = Math.min(card.stock, card.count + data.count);
        } else {
          const skuItem = MockProductData.PRODUCT_SKU_TABLE.find(
            (sku) => sku.skuCode === data.skuCode,
          );
          if (skuItem) {
            const cartItem: CartCardDto = {
              productId: skuItem.productId,
              skuCode: skuItem.skuCode,
              skuDesc: skuItem.skuDesc,
              stock: skuItem.stock,
              count: data.count,
              banner: skuItem.banner,
              title: skuItem.title,
              serviceDesc: skuItem.serviceDesc,
              price: skuItem.price,
              dashPrice: skuItem.dashPrice,
              isSelected: false,
            };
            cartData.cards.unshift(cartItem);
            cartData.version = util.generateRandomUUID(false);
            cartData.total = cartData.cards.length;
          }
        }
        this._setCartData(cartData);
        return [HttpStatusCode.Ok, 0];

      })

    // 更新购物车商品数量
    adapter
      .onPut(ShoppingCartApiMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as UpdateCartReq
        let mockCart: MockCart = this._getMockCart();
        const mockCartData = JSON.parse(mockCart.data) as CartDto;
        for (let i = 0; i < mockCartData.cards.length; i++) {
          if (mockCartData.cards[i].skuCode === data.skuCode) {
            mockCartData.cards[i].count = Number(data.count);
            break;
          }
        }
        mockCartData.version = util.generateRandomUUID(false);
        mockCart.data = JSON.stringify(mockCartData);
        return [HttpStatusCode.Ok, 0];
      });

    // 删除购物车商品
    adapter
      .onDelete(ShoppingCartApiMap.CART_PRODUCT)
      .reply((config: AxiosRequestConfig) => {
        const data = JSON.parse(config.data) as DeleteCartReq;
        let mockCart: MockCart = this._getMockCart();
        const mockCartData = this._getCartData();
        let remainList: CartCardDto[] = mockCartData.cards.filter(
          (item: CartCardDto) =>
          data.isRemain ? data.skuList.includes(item.skuCode) : !data.skuList.includes(item.skuCode),
        );
        let cacheData = {
          version: util.generateRandomUUID(false),
          total: remainList.length,
          cards: remainList,
        } as CartDto;
        mockCart.data = JSON.stringify(cacheData);
        return [HttpStatusCode.Ok, 0];
      });

    // 计算购物车金额
    adapter
      .onGet(ShoppingCartApiMap.CART_PRICE)
      .reply((config: AxiosRequestConfig) => {
        const data = config.params as CalcCartPriceReq
        const originalPrice = data.skuList.reduce((sum, item) => {
          return sum + (item.dashPrice ?? item.price) * 100 * item.count;
        }, 0);
        let tempPrice = data.skuList.reduce((sum, item) => {
          return sum + item.price * 100 * item.count;
        }, 0);
        const discount = originalPrice - tempPrice
        const memberDiscount = data.isMember ? (tempPrice * 0.1) : 0
        const discountList: DiscountItem[] = [
          {
            type: 0,
            label: '活动优惠',
            discountPrice: this._getPriceNum(discount),
          },
          {
            type: 1,
            label: '会员折扣',
            discountPrice: this._getPriceNum(memberDiscount),
          },
        ]
        if (data.extraDiscount?.length) {
          discountList.push(...data.extraDiscount)
          tempPrice -= data.extraDiscount.reduce((sum, item) => sum + item.discountPrice * 100, 0)
        }
        const finalPrice = tempPrice - memberDiscount;
        const cartPrice: CartPrice = {
          finalPrice: this._getPriceNum(finalPrice),
          originalPrice: this._getPriceNum(originalPrice),
          discountList,
        };
        return [HttpStatusCode.Ok, cartPrice];
      });
  }

  private _getCartData() {
    let mockCart: MockCart = this._getMockCart();
    if (!mockCart.data) {
      return {
        version: 'mock_cart_version_empty',
        total: 0,
        cards: [],
      } as CartDto;
    } else {
      return JSON.parse(mockCart.data) as CartDto;
    }
  }

  private _setCartData(data: CartDto) {
    let mockCart: MockCart = this._getMockCart();
    mockCart.data = JSON.stringify(data);
  }

  private _getMockCart() {
    return PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!
  }

  private _getPriceNum(num: number) {
    return Number((num / 100).toFixed(2))
  }
}

export const adapter = new AxiosMockAdapter(request, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const apis = new ShoppingCartMockApis();
  apis.start(adapter);
}
