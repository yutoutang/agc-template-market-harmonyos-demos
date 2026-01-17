import { WindowUtil } from 'module_ui_base';
import { LoadingStatus } from '../commons/Constants';
import { ProductModel } from '../commons/Model';
import { CartPrice } from '../commons/Types';
import { ShoppingCartApis } from '../https/Apis';

@ObservedV2
export class CartPageVM {
  // 是否登录
  @Trace isLogin: boolean = false;
  // 是否是会员
  @Trace isMember: boolean = false;
  /* 是否是编辑态 */
  @Trace isEdit: boolean = false;
  // 页面加载loading
  @Trace loading: LoadingStatus = LoadingStatus.OFF;
  // 下拉刷新
  @Trace isRefreshing: boolean = false;
  // 跟手滑动系数
  @Trace ratio: number = 1;
  // 下拉最到高度
  @Trace maxRefreshingHeight: number = 160.0;
  // 下拉刷新组件的状态
  @Trace refreshStatus: RefreshStatus = RefreshStatus.Inactive;
  // 购物车的数据
  @Trace cartCards: ProductModel[] = [];
  // 选择的商品个数
  @Trace quantity: number = 0;
  // 购物车金额
  @Trace cartPrice: CartPrice = {
    originalPrice: 0,
    finalPrice: 0,
    discountList: [],
  }

  // 初始化
  init() {
    this.loading = LoadingStatus.LOADING;

    ShoppingCartApis.getCartList()
      .then((resp) => {
        if (resp.length) {
          const respSkuCodes = resp.map((item) => item.skuCode);
          this.cartCards.forEach((item: ProductModel) => {
            let data = resp.find(
              (good) => good.skuCode === item.skuCode,
            );
            if (data?.count) {
              item.count = data.count;
            }
          });
          for (let i = this.cartCards.length - 1; i >= 0; i--) {
            if (!respSkuCodes.includes(this.cartCards[i].skuCode)) {
              this.cartCards.splice(i, 1);
            }
          }
          let newCartList: ProductModel[] = [];
          let cartSkuCodes = this.cartCards.map(
            (item: ProductModel) => item.skuCode,
          );
          resp.forEach((item) => {
            if (!cartSkuCodes.includes(item.skuCode)) {

              newCartList.push(new ProductModel(item));
            }
          });
          if (newCartList.length) {
            this.cartCards.unshift(...newCartList);
          }
        } else {
          this.cartCards = resp.map((item) => new ProductModel(item));
        }
      })
      .finally(() => {
        this.loading = LoadingStatus.SUCCESS;
      });
  }

  // 下拉刷新
  onRefreshStateChange(state: RefreshStatus) {
    this.refreshStatus = state;
  }

  // 更新购物车商品的数量
  updateProductCount(skuCode: string) {
    let data = this.cartCards.find((item: ProductModel) => item.skuCode === skuCode);
    ShoppingCartApis.updateProductSkuCount({
      skuCode: skuCode,
      count: data?.count ?? 1,
    }).then(() => {
      // 计算总价
      this.calcTotalPrice();
    });
  }

  // 计算总价
  calcTotalPrice() {
    let selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good: ProductModel) => good.isSelected,
    );
    ShoppingCartApis.calcCartPrice({
      isMember: this.isMember,
      skuList: selectedGoodList,
    }).then((res) => {
      this.cartPrice = res
    })
  }

  // 计算选择的商品个数
  calcQuantity() {
    let selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good) => good.isSelected,
    );
    this.quantity = selectedGoodList.length;
  }

  // 删除商品
  onDeleteProduct(skuCode: string = '') {
    // 侧滑删除商品
    if (skuCode) {
      let idx = this.cartCards.findIndex(
        (good: ProductModel) => good.skuCode === skuCode,
      );
      this.cartCards.splice(idx, 1);
    } else {
      // 删除已选的商品
      this.cartCards = this.cartCards.filter(
        (good: ProductModel) => !good.isSelected,
      );
    }
    let list: string[] = this.cartCards.map((item: ProductModel) => item.skuCode);

    ShoppingCartApis.deleteSkuFromCart({
      skuList: list,
      isRemain: true,
    }).then(() => {
      WindowUtil.toast('删除成功！')
    });
  }

  // 商品结算
  public onCheckout(): ProductModel[] {
    // 已选的购物车商品
    const selectedGoodList: ProductModel[] = this.cartCards.filter(
      (good: ProductModel) => good.isSelected,
    );
    return selectedGoodList;
  }
}
