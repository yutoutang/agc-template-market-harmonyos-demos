import { PopViewUtil, WindowUtil } from 'module_ui_base';
import { Constants } from '../commons/Constants';
import { ProductOperationType } from '../commons/Enums';
import { ProductSaleOptionsModel } from '../commons/Models';
import { ProductSaleOptions } from '../commons/Types';
import { ProductDetailApis } from '../https/Apis';
import { ProductSelector } from '../views/ProductSelector';

@ObservedV2
export class ProductSaleUtil {
  @Trace options: ProductSaleOptionsModel = new ProductSaleOptionsModel()

  async init(options?: ProductSaleOptions,uiContext?:UIContext) {
    if(uiContext){
      WindowUtil.initWindowUtil(uiContext)
    }
    this.options.init(options)
    this.options.productInfo = await ProductDetailApis.getProductDetail(this.options.productId);
    if(this.options.productInfo){
      this.options.getProductInfo?.(this.options.productInfo)
    }
  }

  async handleButtonClick(operationType: ProductOperationType, updateProduct: boolean = false) {
    if (!this.options.isLogin) {
      this.options.handleNotLogin?.();
      return;
    }
    this.options.operationType = operationType;
    if (updateProduct) {
      this.options.productInfo = await ProductDetailApis.getProductDetail(this.options.productId);
    }
    PopViewUtil.openSheet(
      wrapBuilder(buildProductSelector),
      {
        title: { title: '商品规格选择' },
        detents: [SheetSize.LARGE],
        preferType:SheetType.CENTER,
        backgroundColor: Constants.BACKGROUND_COLOR,
        onWillDismiss: (action: DismissSheetAction) => {
          if (action.reason === DismissReason.PRESS_BACK || action.reason === DismissReason.CLOSE_BUTTON) {
            action.dismiss();
          }
        },
      },
      this.options,
    )
  }
}

@Builder
function buildProductSelector(options: ProductSaleOptions) {
  ProductSelector({
    operationType: options.operationType,
    productInfo: options.productInfo,
    handleCancel: () => {
      PopViewUtil.closeSheet()
    },
    handleAddCart: (skuCode: string, count: number) => {
      options.handleAddCart?.(skuCode, count);
      PopViewUtil.closeSheet()
    },
    handlePayNow: (skuCode: string, count: number) => {
      options.handlePayNow?.(skuCode, count);
      PopViewUtil.closeSheet()
    },
  });
}