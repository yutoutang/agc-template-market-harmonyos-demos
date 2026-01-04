import { OrderActionMap, OrderButtonStyleMap, OrderStatusMap, OrderTabsMap, } from './Enums';
import { OrderStatusInfo, OrderType } from './Types';

/**
 * 订单状态 - 已取消
 */
export const ORDER_STATUS_COMPLETE: OrderStatusInfo = {
  status: OrderStatusMap.CANCELED,
  action: [
    {
      style: OrderButtonStyleMap.GREY,
      actionType: OrderActionMap.DELETE,
      label: '删除订单',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    }
  ],
};

/**
 * 订单状态 - 待支付
 */
export const ORDER_STATUS_PENDING_PAYMENT: OrderStatusInfo = {
  status: OrderStatusMap.PENDING_PAYMENT,
  action: [
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.IMMEDIATE_PAYMENT,
      label: '去付款',
      fountColor: $r('app.color.pay_red'),
      borderColor: $r('app.color.pay_red'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

/**
 * 订单状态 - 待发货
 */
export const ORDER_STATUS_PENDING_SHIPMENT: OrderStatusInfo = {
  status: OrderStatusMap.PENDING_SHIPMENT,
  action: [
    {
      style: OrderButtonStyleMap.GREY,
      actionType: OrderActionMap.REQUEST_REFUND,
      label: '退款',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

/**
 * 订单状态 - 待收货
 */
export const ORDER_STATUS_PENDING_RECEIPT: OrderStatusInfo = {
  status: OrderStatusMap.PENDING_RECEIPT,
  action: [
    {
      style: OrderButtonStyleMap.GREY,
      actionType: OrderActionMap.REQUEST_REFUND,
      label: '退款',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    }
  ],
};

/**
 * 订单状态 - 待评价
 */
export const ORDER_STATUS_PENDING_REVIEW: OrderStatusInfo = {
  status: OrderStatusMap.PENDING_REVIEW,
  action: [

    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.REVIEW,
      label: '去评价',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    },
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.REORDER,
      label: '再来一单',
      fountColor: $r('app.color.app_theme'),
      borderColor: $r('app.color.app_theme'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

/**
 * 订单状态 - 已评价
 */
export const ORDER_STATUS_REVIEWED: OrderStatusInfo = {
  status: OrderStatusMap.REVIEWED,
  action: [
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.REORDER,
      label: '再来一单',
      fountColor: $r('app.color.app_theme'),
      borderColor: $r('app.color.app_theme'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

/**
 * 订单状态 - 退款中
 */
export const ORDER_STATUS_REFUND_IN_PROGRESS: OrderStatusInfo = {
  status: OrderStatusMap.REFUND_IN_PROGRESS,
  action: [
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.CANCEL_REFUND,
      label: '取消退款',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

/**
 * 订单状态 - 已退款
 */
export const ORDER_STATUS_REFUNDED: OrderStatusInfo = {
  status: OrderStatusMap.REFUNDED,
  action: [
    {
      style: OrderButtonStyleMap.GREY,
      actionType: OrderActionMap.DELETE,
      label: '删除订单',
      fountColor: $r('sys.color.black'),
      borderColor: $r('sys.color.black'),
      backgroundColor: $r('sys.color.white'),
    },
  ],
};

export const ORDER_TAB_LIST: OrderType[] = [
  {
    type: OrderTabsMap.ALL,
    label: '全部订单',
    statusInfo: [
      ORDER_STATUS_COMPLETE,
      ORDER_STATUS_PENDING_PAYMENT,
      ORDER_STATUS_PENDING_SHIPMENT,
      ORDER_STATUS_PENDING_RECEIPT,
      ORDER_STATUS_PENDING_REVIEW,
      ORDER_STATUS_REVIEWED,
      ORDER_STATUS_REFUND_IN_PROGRESS,
      ORDER_STATUS_REFUNDED,
    ],
  },
  {
    type: OrderTabsMap.PENDING_PAYMENT,
    label: '待付款',
    statusInfo: [ORDER_STATUS_PENDING_PAYMENT],
  },
  {
    type: OrderTabsMap.PENDING_SHIPMENT,
    label: '进行中',
    statusInfo: [ORDER_STATUS_PENDING_SHIPMENT, ORDER_STATUS_PENDING_RECEIPT],
  },
  {
    type: OrderTabsMap.REVIEW,
    label: '已完成',
    statusInfo: [ORDER_STATUS_PENDING_REVIEW],
  },
  {
    type: OrderTabsMap.AFTER_SALE,
    label: '退款/售后',
    statusInfo: [ORDER_STATUS_REFUND_IN_PROGRESS, ORDER_STATUS_REFUNDED],
  },
];

export const RECEIVING_METHOD_LIST: string[] = [
  '外卖',
  '自取'
]
