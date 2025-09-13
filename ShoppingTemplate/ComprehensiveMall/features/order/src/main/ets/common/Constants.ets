import {
  OrderActionMap,
  OrderButtonStyleMap,
  OrderStatusMap,
  OrderTabsMap,
} from './Enums';
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
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.REORDER,
      label: '再买一单',
    },
  ],
};

/**
 * 订单状态 - 待支付
 */
export const ORDER_STATUS_PENDING_PAYMENT: OrderStatusInfo = {
  status: OrderStatusMap.PENDING_PAYMENT,
  action: [
    {
      style: OrderButtonStyleMap.GREY,
      actionType: OrderActionMap.CANCEL_ORDER,
      label: '取消订单',
    },
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.UPDATE_ADDRESS,
      label: '修改地址',
      enableHide: true,
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.IMMEDIATE_PAYMENT,
      label: '立即支付',
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
    },
    {
      style: OrderButtonStyleMap.OUTLINE,
      actionType: OrderActionMap.UPDATE_ADDRESS,
      label: '修改地址',
      enableHide: true,
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.URGE_SHIPMENT,
      label: '催发货',
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
      label: '申请退款',
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.CONFIRM_RECEIPT,
      label: '确认收货',
    },
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
      actionType: OrderActionMap.REORDER,
      label: '再买一单',
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.REVIEW,
      label: '评价',
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
      label: '再买一单',
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.VIEW_REVIEW,
      label: '查看评价',
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
      actionType: OrderActionMap.CONTACT_CUSTOMER_SERVICE,
      label: '联系客服',
      enableHide: true,
    },
    {
      style: OrderButtonStyleMap.FULFILL,
      actionType: OrderActionMap.CANCEL_REFUND,
      label: '取消退款',
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
    },
  ],
};

export const ORDER_TAB_LIST: OrderType[] = [
  {
    type: OrderTabsMap.ALL,
    label: '全部',
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
    label: '待发货',
    statusInfo: [ORDER_STATUS_PENDING_SHIPMENT],
  },
  {
    type: OrderTabsMap.PENDING_RECEIPT,
    label: '待收货',
    statusInfo: [ORDER_STATUS_PENDING_RECEIPT],
  },
  {
    type: OrderTabsMap.REVIEW,
    label: '待评价',
    statusInfo: [ORDER_STATUS_PENDING_REVIEW, ORDER_STATUS_REVIEWED],
  },
  {
    type: OrderTabsMap.AFTER_SALE,
    label: '退款/售后',
    statusInfo: [ORDER_STATUS_REFUND_IN_PROGRESS, ORDER_STATUS_REFUNDED],
  },
];
