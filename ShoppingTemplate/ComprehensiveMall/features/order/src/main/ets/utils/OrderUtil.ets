import { common } from '@kit.AbilityKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { paymentService } from '@kit.PaymentKit';
import {
  buildMakeCallComponent,
  Logger,
  PopViewUtil,
  RouterMap,
  routerStack,
  WindowUtil,
} from 'lib_foundation';
import { AddressInfo, OrderApis, OrderInfo, OrderSkuItem } from 'lib_network';
import { OrderReviewReq } from 'lib_network';
import { CommonConfirmDialog } from 'lib_widget';
import { CartApi } from 'module_shopping_cart';
import {
  ORDER_STATUS_COMPLETE,
  ORDER_STATUS_PENDING_PAYMENT,
  ORDER_STATUS_PENDING_RECEIPT,
  ORDER_STATUS_PENDING_REVIEW,
  ORDER_STATUS_PENDING_SHIPMENT,
  ORDER_STATUS_REFUNDED,
  ORDER_STATUS_REFUND_IN_PROGRESS,
  ORDER_STATUS_REVIEWED,
} from '../common/Constants';
import { OrderActionMap, OrderShipmentMap, OrderStatusMap } from '../common/Enums';
import { OrderActionReq, OrderStatusInfo } from '../common/Types';
import { data } from '@kit.TelephonyKit';

const TAG: string = '[OrderUtil]';

export class OrderUtil {
  public static getStatusLabel(status: number) {
    const labelMap: Map<OrderStatusMap, string> = new Map([
      [OrderStatusMap.PENDING_PAYMENT, '待付款'],
      [OrderStatusMap.CANCELED, '已取消'],
      [OrderStatusMap.PENDING_SHIPMENT, '待发货'],
      [OrderStatusMap.PENDING_RECEIPT, '待收货'],
      [OrderStatusMap.PENDING_REVIEW, '交易成功'],
      [OrderStatusMap.REVIEWED, '已完成'],
      [OrderStatusMap.REFUND_IN_PROGRESS, '退款中'],
      [OrderStatusMap.REFUNDED, '退款成功'],
    ]);
    return labelMap.get(status) ?? '';
  }

  public static getReceiveMethodLabel(method: number) {
    if (method === OrderShipmentMap.EXPRESS) {
      return '快递到家';
    } else if (method === OrderShipmentMap.SELF_PICK_UP) {
      return '到店自取';
    }
    return '';
  }

  public static getButtonList(status: number) {
    const actionMap: Map<OrderStatusMap, OrderStatusInfo> = new Map([
      [OrderStatusMap.CANCELED, ORDER_STATUS_COMPLETE],
      [OrderStatusMap.PENDING_PAYMENT, ORDER_STATUS_PENDING_PAYMENT],
      [OrderStatusMap.PENDING_SHIPMENT, ORDER_STATUS_PENDING_SHIPMENT],
      [OrderStatusMap.PENDING_RECEIPT, ORDER_STATUS_PENDING_RECEIPT],
      [OrderStatusMap.PENDING_REVIEW, ORDER_STATUS_PENDING_REVIEW],
      [OrderStatusMap.REVIEWED, ORDER_STATUS_REVIEWED],
      [OrderStatusMap.REFUND_IN_PROGRESS, ORDER_STATUS_REFUND_IN_PROGRESS],
      [OrderStatusMap.REFUNDED, ORDER_STATUS_REFUNDED],
    ]);
    return actionMap.get(status)?.action ?? [];
  }

  public static handleOrderAction(
    actionType: OrderActionMap,
    param: OrderActionReq,
  ) {
    type Handler = (param: OrderActionReq) => void;
    const actionMap: Map<OrderActionMap, Handler> = new Map([
      [OrderActionMap.IMMEDIATE_PAYMENT, OrderUtil.handleImmediatePayment],
      [OrderActionMap.URGE_SHIPMENT, OrderUtil.handleUrgeShipment],
      [OrderActionMap.CONFIRM_RECEIPT, OrderUtil.handleConfirmReceipt],
      [OrderActionMap.CANCEL_ORDER, OrderUtil.handleCancelOrder],
      [OrderActionMap.UPDATE_ADDRESS, OrderUtil.handleUpdateAddress],
      [OrderActionMap.REVIEW, OrderUtil.handleReview],
      [OrderActionMap.VIEW_REVIEW, OrderUtil.handleViewReview],
      [
        OrderActionMap.CONTACT_CUSTOMER_SERVICE,
        OrderUtil.handleContactCustomerService,
      ],
      [OrderActionMap.REQUEST_REFUND, OrderUtil.handleRequestRefund],
      [OrderActionMap.CANCEL_REFUND, OrderUtil.handleCancelRefund],
      [OrderActionMap.REORDER, OrderUtil.handleReorder],
      [OrderActionMap.DELETE, OrderUtil.handleDelete],
    ]);
    const handler = actionMap.get(actionType);
    if (handler) {
      handler(param);
    } else {
      Logger.error(TAG, 'invalid action type.' + actionType);
    }
  }

  /**
   * 立即支付
   * @param param
   */
  public static handleImmediatePayment(param: OrderActionReq) {
    const context: common.UIAbilityContext =
      getContext() as common.UIAbilityContext;
    paymentService
      .requestPayment(context, '')
      .then(() => {
      })
      .catch(() => {
      });
  }

  /**
   * 催发货
   * @param param
   */
  public static handleUrgeShipment(param: OrderActionReq) {
    // 处理催促发货逻辑
    WindowUtil.toast('已提交催发货申请，请耐心等待~');
  }

  /**
   * 确认收货
   * @param param
   */
  public static handleConfirmReceipt(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '为了保证您的售后权益，请收到商品确认无误后再确认收货',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.PENDING_REVIEW,
        }).then(() => {
          WindowUtil.toast('订单确认收货成功');
          param.callback?.();
        });
      },
    });
  }

  /**
   * 取消订单
   * @param param
   */
  public static handleCancelOrder(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '取消后无法恢复，是否确认取消订单',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.CANCELED,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单取消成功');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 更新地址
   * @param param
   */
  public static handleUpdateAddress(param: OrderActionReq) {
    OrderApis.updateDetail(param.orderNo, {
      addressInfo: param.data as AddressInfo,
    }).then((res) => {
      if (res.code === 0) {
        WindowUtil.toast('地址更新成功！');
        param.callback?.();
      }
    });
  }

  /**
   * 评价商品
   * @param param
   */
  public static handleReview(param: OrderActionReq) {
    OrderApis.addComment(param.orderNo, param.data as OrderReviewReq).then(
      (res) => {
        if (res.code === 0) {
          WindowUtil.toast('添加评论成功！');
          param.callback?.();
        }
      },
    );
  }

  /**
   * 查看商品评价
   * @param param
   */
  public static handleViewReview(param: OrderActionReq) {
    routerStack.pushPath({
      name: RouterMap.ORDER_REVIEW_INFO,
      param: param.data,
    })
  }

  /**
   * 联系客服
   * @param param
   */
  public static handleContactCustomerService(param: OrderActionReq) {
    PopViewUtil.openSheet(wrapBuilder(buildMakeCallComponent), {
      title: { title: '联系客服' },
      dragBar: true,
      detents: [SheetSize.FIT_CONTENT],
    });
  }

  /**
   * 申请退款
   * @param param
   */
  public static handleRequestRefund(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认申请退款？',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.REFUND_IN_PROGRESS,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单申请退款成功，请等待商家确认');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 取消退款申请
   * @param param
   */
  public static handleCancelRefund(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认取消退款申请？',
      confirm: () => {
        OrderApis.updateDetail(param.orderNo, {
          status: OrderStatusMap.PENDING_RECEIPT,
        }).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast(
              '订单取消退款成功，请在收到商品确认无误后确认收货',
            );
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 重新下单，将本单商品加入购物车
   * @param param
   */
  public static handleReorder(param: OrderActionReq) {
    const data = param.data as OrderSkuItem[];
    if (data?.length) {
      let promises: Promise<string>[] = [];
      let skuTable: Record<string, string | number> = {};
      data.forEach((item) => {
        skuTable[item.skuCode] = item.count;
        const promise = CartApi.addSkuToCart(item.skuCode, item.count);
        promises.push(promise);
      });
      Promise.all(promises).then(() => {
        WindowUtil.toast('成功加入购物车');
        routerStack.pushPath({ name: RouterMap.PRODUCT_CART });
      });
    }
  }

  /**
   * 删除订单
   * @param param
   */
  public static handleDelete(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '是否确认删除订单，删除后不可恢复',
      confirm: () => {
        OrderApis.deleteDetail(param.orderNo).then((res) => {
          if (res.code === 0) {
            WindowUtil.toast('订单删除成功！');
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 复制订单号
   * @param orderNo
   */
  public static copyOrderNumber(orderNo: string) {
    const pasteboardData = pasteboard.createData(
      pasteboard.MIMETYPE_TEXT_PLAIN,
      orderNo,
    );
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard
      .setData(pasteboardData)
      .then(() => {
        WindowUtil.toast('复制成功!');
      })
      .catch((err: BusinessError) => {
        WindowUtil.toast('复制失败!');
        Logger.error(TAG, 'copy order number failed. error:' + JSON.stringify(err));
      });
  }
}
