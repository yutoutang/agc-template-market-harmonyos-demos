import { ProductOperationType } from './Enums';
import { ProductInfo, ProductReviewItem, ProductSaleOptions } from './Types';
import {
  REVIEW_ITEM_MOCK1,
  REVIEW_ITEM_MOCK2,
  REVIEW_ITEM_MOCK3,
} from '../https/MockData';

@ObservedV2
export class SpecViewModel {
  @Trace specKey: string;
  @Trace label: string;
  @Trace id: string;
  @Trace value: string;
  @Trace image?: ResourceStr;
  @Trace isOutOfStock: boolean;
  @Trace isSelected: boolean;
  @Trace isTempOutOfStock: boolean = false;

  constructor(
    specKey: string,
    label: string,
    id: string,
    value: string,
    isOutOfStock: boolean,
    isSelected: boolean,
  ) {
    this.specKey = specKey;
    this.label = label;
    this.id = id;
    this.value = value;
    this.isOutOfStock = isOutOfStock;
    this.isSelected = isSelected;
  }
}

@ObservedV2
export class ProductSaleOptionsModel implements ProductSaleOptions {
  productId: string = '';
  isLogin: boolean = false;
  cartProdNum: number = 0;
  operationType?: ProductOperationType = ProductOperationType.ADD_TO_CART;
  productInfo?: ProductInfo;
  clickCart?: () => void;
  handleAddCart?: (skuCode: string, count: number) => void;
  handlePayNow?: (skuCode: string, count: number) => void;
  handleNotLogin?: () => void;
  getProductInfo?: (data: ProductInfo) => void;

  constructor(options?: ProductSaleOptions) {
    this.init(options);
  }

  init(options?: ProductSaleOptions) {
    this.productId = options?.productId ?? this.productId;
    this.isLogin = options?.isLogin ?? this.isLogin;
    this.cartProdNum = options?.cartProdNum ?? this.cartProdNum;
    this.clickCart = options?.clickCart ?? this.clickCart;
    this.handleAddCart = options?.handleAddCart ?? this.handleAddCart;
    this.handlePayNow = options?.handlePayNow ?? this.handlePayNow;
    this.handleNotLogin = options?.handleNotLogin ?? this.handleNotLogin;
    this.getProductInfo = options?.getProductInfo ?? this.getProductInfo;
  }
}
