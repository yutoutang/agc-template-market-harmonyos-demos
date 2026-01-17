import { CartProductInfo } from './Types';

@ObservedV2
export class ProductModel implements CartProductInfo {
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

  constructor(product?: CartProductInfo) {
    if(product){
      this.productId = product.productId
      this.skuCode = product.skuCode
      this.skuDesc = product.skuDesc
      this.stock = product.stock
      this.count = product.count
      this.banner = product.banner
      this.title = product.title
      this.serviceDesc = product.serviceDesc
      this.price = product.price
      this.dashPrice = product.dashPrice
    }
  }
}

@ObservedV2
export class MockCart {
  @Trace data: string = '';
}


export class PopupSheetController {
  hide: () => void = () => {
  };
}
