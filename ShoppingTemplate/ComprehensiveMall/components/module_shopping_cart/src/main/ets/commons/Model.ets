@ObservedV2
export class Product {
  public productId: string = '';
  public skuCode: string = '';
  @Trace public skuDesc: string = '';
  @Trace public stock: number = 0;
  @Trace public count: number = 0;
  @Trace public banner: ResourceStr = '';
  @Trace public title: string = '';
  @Trace public serviceDesc: string = '';
  @Trace public price: number = 0;
  @Trace public dashPrice?: number = 0;
  @Trace public isSelected: boolean = false;
}

@ObservedV2
export class MockCart {
  @Trace data: string = '';
}

export interface CartCardDto {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  count: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
  isSelected: boolean;
}

export interface CartDto {
  version: string;
  total: number;
  cards: CartCardDto[];
}

export interface ProductSkuItem {
  productId: string;
  skuCode: string;
  skuDesc: string;
  stock: number;
  banner: string;
  title: string;
  serviceDesc: string;
  price: number;
  dashPrice?: number;
}

export interface UpdateCartReq {
  skuCode: string;
  count: number;
}

export class PopupSheetController {
  hide: () => void = () => {};
}
