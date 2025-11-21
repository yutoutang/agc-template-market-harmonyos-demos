import { ProductApis, ProductCardItem } from 'lib_network';
import { ProductResource } from 'module_product_share';

@ObservedV2
export class ProductSwiperVM {
  @Trace
  productResource: ProductResource | undefined;
  @Trace
  productList: ProductCardItem[] = [];
  @Trace
  curPage: number = 1;

  async getProductList() {
    const res = await ProductApis.getProductList({
      curPage: this.curPage,
    });
  }
}
