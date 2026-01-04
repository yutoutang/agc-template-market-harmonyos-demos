import { BusinessError, pasteboard } from '@kit.BasicServicesKit';

import {
  ORDER_STATUS_COMPLETE,
  ORDER_STATUS_PENDING_PAYMENT,
  ORDER_STATUS_PENDING_RECEIPT,
  ORDER_STATUS_PENDING_REVIEW,
  ORDER_STATUS_PENDING_SHIPMENT,
  ORDER_STATUS_REFUND_IN_PROGRESS,
  ORDER_STATUS_REFUNDED,
  ORDER_STATUS_REVIEWED,
} from '../common/Constants';
import { OrderActionMap, OrderStatusMap } from '../common/Enums';
import { OrderActionReq, OrderStatusInfo } from '../common/Types';
import { CommonConfirmDialog, Logger, RouterMap, RouterUtils } from 'lib_common';
import { CarGoodsInfo, MyCartServiceApi, OrderServiceApi } from 'lib_takeaway_api';
import { promptAction } from '@kit.ArkUI';

const TAG: string = '[OrderUtil]';

export class OrderUtil {
  public static getStatusLabel(status: number) {
    const labelMap: Map<OrderStatusMap, string> = new Map([
      [OrderStatusMap.PENDING_PAYMENT, '待付款'],
      [OrderStatusMap.CANCELED, '已取消'],
      [OrderStatusMap.PENDING_SHIPMENT, '进行中'],
      [OrderStatusMap.PENDING_RECEIPT, '进行中'],
      [OrderStatusMap.PENDING_REVIEW, '交易成功'],
      [OrderStatusMap.REVIEWED, '已完成'],
      [OrderStatusMap.REFUND_IN_PROGRESS, '退款中'],
      [OrderStatusMap.REFUNDED, '退款成功'],
    ]);
    return labelMap.get(status) ?? '';
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
      [OrderActionMap.CONFIRM_RECEIPT, OrderUtil.handleConfirmReceipt],
      [OrderActionMap.CANCEL_ORDER, OrderUtil.handleCancelOrder],
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
   * 确认收货
   * @param param
   */
  public static handleConfirmReceipt(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '提示',
      content: '为了保证您的售后权益，请收到商品确认无误后再确认收货',
      confirm: () => {
        OrderServiceApi.updateOrderStatus(param.orderNo, OrderStatusMap.PENDING_REVIEW).then((res) => {
          if (res.code === 0) {
            promptAction.showToast({ message: '订单确认收货成功' })
            param.callback?.();
          }
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
        OrderServiceApi.updateOrderStatus(param.orderNo, OrderStatusMap.CANCELED).then((res) => {
          if (res.code === 0) {
            promptAction.showToast({ message: '订单取消成功' })
            param.callback?.();
          }
        });
      },
    });
  }

  /**
   * 申请退款
   * @param param
   */
  public static handleRequestRefund(param: OrderActionReq) {
    CommonConfirmDialog.show({
      primaryTitle: '确认取消订单吗？',
      content: '会为您发起退款处理，请耐心等待到账。',
      secBtnV: '确认取消',
      priBtnV: '再想想',
      confirm: () => {
        OrderServiceApi.updateOrderStatus(param.orderNo, OrderStatusMap.REFUND_IN_PROGRESS).then((res) => {
          if (res.code === 0) {
            promptAction.showToast({ message: '订单申请退款成功，请等待商家确认' })
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
        OrderServiceApi.updateOrderStatus(param.orderNo, OrderStatusMap.PENDING_RECEIPT).then((res) => {
          if (res.code === 0) {
            promptAction.showToast({ message: '订单取消退款成功，请在收到商品确认无误后确认收货' })
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
    const data = param.data as CarGoodsInfo[];

    if (data?.length) {
      let flag = MyCartServiceApi.batchAddCarGoods(data, param.storeId)
      if (flag === 1) {
        RouterUtils.pushPathByName(RouterMap.STORE_PAGE, param.storeId)
      } else {
        promptAction.showToast({ message: '再来一单失败' })
      }
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
        OrderServiceApi.deleteOrder(param.orderNo).then((res) => {
          if (res.code === 0) {
            promptAction.showToast({ message: '删除成功' })
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
        promptAction.showToast({ message: '复制成功' })
      })
      .catch((err: BusinessError) => {
        promptAction.showToast({ message: '复制失败' })
        Logger.error(TAG, 'copy order number failed. error:' + JSON.stringify(err));
      });
  }
}
