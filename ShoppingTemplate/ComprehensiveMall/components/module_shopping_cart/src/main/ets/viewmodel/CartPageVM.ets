import { JSON } from '@kit.ArkTS';
import { LoadingStatus } from '../commons/Constants';
import { Product } from '../commons/Model';
import { CartApi } from '../http/CartApi';

@ObservedV2
export class CartPageVM {
  // 是否登录
  @Trace isLogin: boolean = false;
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
  @Trace cartCards: Product[] = [];
  // 选择的商品总价
  @Trace totalPrice: number = 0;
  // 商品的活动优惠
  @Trace discountAmount: number = 0;
  // 选择的商品个数
  @Trace quantity: number = 0;

  // 初始化
  init() {
    this.loading = LoadingStatus.LOADING;

    CartApi.getCartList()
      .then((resp: Product[]) => {
        if (resp.length) {
          const respSkuCodes = resp.map((item: Product) => item.skuCode);
          this.cartCards.forEach((item: Product) => {
            let data = resp.find(
              (good: Product) => good.skuCode === item.skuCode,
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
          let newCartList: Product[] = [];
          let cartSkuCodes = this.cartCards.map(
            (item: Product) => item.skuCode,
          );
          resp.forEach((item: Product) => {
            if (!cartSkuCodes.includes(item.skuCode)) {
              newCartList.push(item);
            }
          });
          if (newCartList.length) {
            this.cartCards.unshift(...newCartList);
          }
        } else {
          this.cartCards = resp;
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
    let data = this.cartCards.find((item: Product) => item.skuCode === skuCode);
    CartApi.updateProductCount({
      skuCode: skuCode,
      count: data?.count ?? 1,
    }).then(() => {
      // 计算总价
      this.calcTotalPrice();
      // 计算优惠
      this.calcDiscountAmount();
    });
  }

  // 计算总价
  calcTotalPrice() {
    let selectedGoodList: Product[] = this.cartCards.filter(
      (good: Product) => good.isSelected,
    );
    if (selectedGoodList.length > 0) {
      // 总价
      this.totalPrice = selectedGoodList.reduce((pre: number, cur: Product) => {
        return pre + cur.price * Number(cur.count || 1);
      }, 0);
    } else {
      this.totalPrice = 0;
    }
  }

  // 计算优惠
  calcDiscountAmount() {
    let selectedGoodList: Product[] = this.cartCards.filter(
      (good: Product) => good.isSelected,
    );
    if (selectedGoodList.length > 0) {
      const dashPriceGoodList = selectedGoodList.filter(
        (item: Product) => item.dashPrice,
      );
      // 实际总价
      const totalDashPrice = dashPriceGoodList.reduce(
        (pre: number, cur: Product) => {
          return pre + (cur.dashPrice || 0) * Number(cur.count || 1);
        },
        0,
      );
      // 优惠后的总价
      const actualPrice = dashPriceGoodList.reduce(
        (pre: number, cur: Product) => {
          return pre + cur.price * Number(cur.count || 1);
        },
        0,
      );
      this.discountAmount = totalDashPrice - actualPrice;
    } else {
      this.discountAmount = 0;
    }
  }

  // 计算选择的商品个数
  calcQuantity() {
    let selectedGoodList: Product[] = this.cartCards.filter(
      (good: Product) => good.isSelected,
    );
    this.quantity = selectedGoodList.length;
  }

  // 删除商品
  onDeleteProduct(skuCode: string = '') {
    // 侧滑删除商品
    if (skuCode) {
      let idx = this.cartCards.findIndex(
        (good: Product) => good.skuCode === skuCode,
      );
      this.cartCards.splice(idx, 1);
    } else {
      // 删除已选的商品
      this.cartCards = this.cartCards.filter(
        (good: Product) => !good.isSelected,
      );
    }
    let list: string[] = this.cartCards.map((item: Product) => item.skuCode);

    CartApi.deleteCartProduct(list).then((res) => {
      console.log('delete success: ', JSON.stringify(res));
    });
  }

  // 商品结算
  public onCheckout(): Product[] {
    // 已选的购物车商品
    const selectedGoodList: Product[] = this.cartCards.filter(
      (good: Product) => good.isSelected,
    );
    return selectedGoodList;
  }
}
