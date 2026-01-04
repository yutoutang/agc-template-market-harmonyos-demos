import { BaseViewModel, LazyDataSource, ObservedArray, RouterMap, RouterUtils } from 'lib_common';
import { OrderItem, OrderServiceApi } from 'lib_takeaway_api';
import { ORDER_TAB_LIST } from '../common/Constants';
import { OrderActionMap, OrderStatusMap, OrderTabsMap } from '../common/Enums';
import { OrderUtil } from '../utils/OrderUtil';

@ObservedV2
export class OrderListPageVM extends BaseViewModel {
  @Trace
  isLoading: boolean = false;
  @Trace
  isRefreshing: boolean = false;
  @Trace
  currentIndex: number = 0;
  @Trace
  orderList: LazyDataSource<OrderItem> = new LazyDataSource();
  @Trace
  curPage: number = 1;
  @Trace
  totalNum: number = 0;
  @Trace
  reachEnd: boolean = false;
  @Trace
  reviewTabIndex: number = 0;
  @Trace
  keywords: string = '';
  // 是否展示支付弹窗
  @Trace isShowPay: boolean = false;
  searchController: SearchController = new SearchController();
  tabController: TabsController = new TabsController();
  listScroller: Scroller = new Scroller();

  public async initOrderTab(index: number) {
    this.currentIndex = index;
    this.tabController.changeIndex(index);
    this.isLoading = true;
    await this.getOrderList();
    this.isLoading = false;
  }

  public async changeTab(index: number) {
    this.currentIndex = index;
    this.orderList.clear();
    this.refreshOrderList();
  }

  public async refreshOrderList() {
    this.reachEnd = false;
    this.curPage = 1;
    this.totalNum = 0;
    await this.getOrderList(true);
  }

  public async getOrderList(isRefresh: boolean = false, keywords?: string) {
    if (this.reachEnd || this.isRefreshing) {
      return;
    }
    if (isRefresh) {
      this.isRefreshing = true;
    }
    let status: number[] = [];
    if (this.currentIndex === OrderTabsMap.REVIEW) {
      status =
        this.reviewTabIndex === 0 ?
          [OrderStatusMap.PENDING_REVIEW] :
          [OrderStatusMap.REVIEWED];
    } else {
      status = ORDER_TAB_LIST[this.currentIndex].statusInfo.map(
        (item) => item.status,
      );
    }
    const res = await OrderServiceApi.queryOrderList(this.curPage, status, keywords);
    if (res.code === 0) {
      this.totalNum = res.total;
      const newOrders = new ObservedArray(res.orderList);
      if (isRefresh) {
        this.orderList.clear();
      }
      this.orderList.appendArrayData(newOrders);
      if (this.curPage * 6 >= this.totalNum) {
        this.reachEnd = true;
      }
      this.curPage++;
    }
    this.isRefreshing = false;
  }

  public switchReviewTab(index: number) {
    this.reviewTabIndex = index;
    this.refreshOrderList();
  }

  public handleOrderItem(orderItem: OrderItem, action: OrderActionMap) {
    if (action === OrderActionMap.REVIEW) { //评价
      let onPop: Callback<PopInfo> = (pop: PopInfo) => {
        OrderServiceApi.updateOrderStatus(orderItem.orderInfo.orderNo, OrderStatusMap.REVIEWED)
      }
      RouterUtils.pushPathByName(RouterMap.ORDER_SUBMITCOMMENT_PAGE, orderItem.orderInfo.orderNo, onPop)
    } else if (action === OrderActionMap.REORDER) { //重新下单
      const carGoodsInfo = orderItem.carGoodsInfo;
      OrderUtil.handleReorder({
        orderNo: orderItem.orderInfo.orderNo,
        storeId: orderItem.storeInfo.id,
        data: carGoodsInfo,
      });
    } else if (action === OrderActionMap.IMMEDIATE_PAYMENT) {
      this.isShowPay = true;
    } else {
      OrderUtil.handleOrderAction(action, {
        orderNo: orderItem.orderInfo.orderNo,
        storeId: orderItem.storeInfo.id,
        callback: () => {
          this.refreshOrderList();
        },
      });
    }
  }

  public async searchOrder(value: string) {
    this.keywords = value;
    this.reachEnd = false;
    this.curPage = 1;
    this.totalNum = 0;
    this.currentIndex = 0;
    this.getOrderList(true, this.keywords);
  }
}
