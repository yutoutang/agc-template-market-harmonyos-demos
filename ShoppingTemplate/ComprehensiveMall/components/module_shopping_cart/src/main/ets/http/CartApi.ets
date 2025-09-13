import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { CartCardDto, Product, CartDto, MockCart, UpdateCartReq } from '../commons/Model';
import { MockProductData } from './MockProductData';

function handleBannerIcon(banner: string): ResourceStr {
  if (banner.startsWith('app://')) {
    const imgPath: string = banner.split('/spec/')[1];
    const imgUrl = imgPath.split('.')[0];
    const path: string = 'app.media.' + imgUrl;
    return $r(path);
  }
  return banner;
}

export class CartApi {
  public static getCartData(): Promise<CartDto> {
    let data = CartApi._getCartData();
    return Promise.resolve(data);
  }

  // 获取购物车列表数据
  public static getCartList(): Promise<Product[]> {
    let mockCart: MockCart = PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
    let resList: Product[] = [];
    if (mockCart.data) {
      const resData = JSON.parse(mockCart.data) as CartDto;
      resList = resData.cards.map((item: CartCardDto) => {
        let itemData: Product = new Product();
        itemData.productId = item.productId;
        itemData.skuCode = item.skuCode;
        itemData.skuDesc = item.skuDesc;
        itemData.stock = 10;
        itemData.count = item.count;
        itemData.banner = handleBannerIcon(item.banner);
        itemData.title = item.title;
        itemData.serviceDesc = item.serviceDesc;
        itemData.price = item.price;
        itemData.dashPrice = item.dashPrice;
        itemData.isSelected = item.isSelected;
        return itemData;
      });
    }
    return Promise.resolve(resList);
  }

  // 删除购物车商品
  public static deleteCartProduct(
    data: string[],
    isRemain: boolean = true,
  ): Promise<string> {
    let mockCart: MockCart = PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
    const mockCartData = CartApi._getCartData()
    let remainList: CartCardDto[] = mockCartData.cards.filter(
      (item: CartCardDto) =>
        isRemain ? data.includes(item.skuCode) : !data.includes(item.skuCode),
    );
    let cacheData = {
      version: util.generateRandomUUID(false),
      total: remainList.length,
      cards: remainList,
    } as CartDto;
    mockCart.data = JSON.stringify(cacheData);

    return Promise.resolve('0');
  }

  // 更新购物车商品的数量
  public static updateProductCount(
    data: UpdateCartReq,
  ): Promise<string> {
    let mockCart: MockCart = PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
    const mockCartData = JSON.parse(mockCart.data) as CartDto;
    for (let i = 0; i < mockCartData.cards.length; i++) {
      if (mockCartData.cards[i].skuCode === data.skuCode) {
        mockCartData.cards[i].count = Number(data.count);
        break;
      }
    }
    mockCartData.version = util.generateRandomUUID(false);
    mockCart.data = JSON.stringify(mockCartData);
    return Promise.resolve('0');
  }

  public static addSkuToCart(skuCode: string, count: number): Promise<string> {
    const cartData = CartApi._getCartData();
    const card = cartData.cards.find((item) => item.skuCode === skuCode);
    if (card) {
      card.count = Math.min(card.stock, card.count + count);
    } else {
      const skuItem = MockProductData.PRODUCT_SKU_TABLE.find(
        (sku) => sku.skuCode === skuCode,
      );
      if (skuItem) {
        const cartItem: CartCardDto = {
          productId: skuItem.productId,
          skuCode: skuItem.skuCode,
          skuDesc: skuItem.skuDesc,
          stock: skuItem.stock,
          count: count,
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
    CartApi._setCartData(cartData);
    return Promise.resolve('0');
  }

  private static _getCartData() {
    let mockCart: MockCart = PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
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

  private static _setCartData(data: CartDto) {
    let mockCart: MockCart = PersistenceV2.connect(
      MockCart,
      'MockCart',
      () => new MockCart(),
    )!;
    mockCart.data = JSON.stringify(data);
  }
}
