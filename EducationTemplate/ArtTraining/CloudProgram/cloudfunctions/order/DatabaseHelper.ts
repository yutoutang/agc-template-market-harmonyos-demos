import { cloud, CloudDBCollection, CloudDBZoneObjectOperator, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import { OrderInfo } from './models/OrderInfo';
import { CloudUserCourseInfo } from './models/CloudUserCourseInfo';
import { GetOrderListReq, GetOrderDetailReq, CourseOrderReq, OrderNoReq } from './types/RequestTypes';
import { OrderInfoResp } from './types/ResponseTypes';
import { ListResp } from './models/ListResp';
import { OrderTriggerMap, OrderStatusMap } from './constants';
import { CourseInfoResp } from './types/ResponseTypes';

const ZONE_NAME = 'ArtTraining';
const TAG = '[order-db]';

export class DatabaseHelper {
  logger;
  private userId: string;
  private orderList: CloudDBCollection<OrderInfo>;
  private userCourseList: CloudDBCollection<CloudUserCourseInfo>;

  constructor(logger, userId) {
    this.logger = logger;
    this.userId = userId;
    this.orderList = cloud.database({ zoneName: ZONE_NAME }).collection(OrderInfo);
    this.userCourseList = cloud.database({ zoneName: ZONE_NAME }).collection(CloudUserCourseInfo);
  }

  public async getOrderList(params: GetOrderListReq): Promise<ListResp<OrderInfoResp> | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.GET_ORDER_LIST;
    const statusArr = params.orderStatus;
    try {
      const orderQuery: CloudDBZoneQuery<OrderInfo> = this.orderList
        .query()
        .orderByDesc('orderNo')
        .equalTo('userId', this.userId);
      if (statusArr.length) {
        orderQuery.in('orderStatus', statusArr);
      }
      const listResp = this._createOrderInfoRespList(orderQuery);
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async getOrderDetail(params: GetOrderDetailReq): Promise<OrderInfoResp | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.GET_ORDER_DETAIL;
    const orderNo = params.orderNo;
    try {
      const orderQuery: CloudDBZoneQuery<OrderInfo> = this.orderList
        .query()
        .orderByDesc('orderNo')
        .equalTo('userId', this.userId)
        .equalTo('orderNo', orderNo);
      const orderData: OrderInfo[] = await orderQuery.get();
      if (orderData.length === 1) {
        const orderDetail = this._createOrderInfoRespItem(orderData[0]);
        return orderDetail;
      } else {
        this.logger.error(LOGGER_TAG + 'cannot find target order');
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async createCourseOrder(params: CourseOrderReq): Promise<OrderInfoResp | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.CREATE_COURSE_ORDER;
    try {
      const courseInfo = await this._getCourseDetail(params.courseId);
      if (courseInfo) {
        const orderItem = new OrderInfo();
        const orderTime = new Date();
        const expireTime = new Date(orderTime.getTime() + 60 * 60 * 24 * 1000);
        const timestamp = orderTime.getTime().toString();
        orderItem.setUserId(this.userId);
        orderItem.setOrderTime(orderTime);
        orderItem.setOrderNo(`order${timestamp}`);
        orderItem.setOrderStatus(1);
        orderItem.setPaymentMethod(params.paymentMethod);
        orderItem.setStudent(params.student);
        orderItem.setPhone(params.phone);
        orderItem.setTotalPrice(params.price);
        orderItem.setCourseInfo(JSON.stringify(courseInfo));
        orderItem.setExpireTime(expireTime);
        orderItem.setRemark(params.remark);
        // 此处需要对接真实商户后获取orderStr，参考README中配置准备-配置支付服务章节
        const mockOrderStr =
          `{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":${timestamp},"noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}`;
        orderItem.setOrderStr(mockOrderStr);
        const res = await this.orderList.upsert(orderItem);
        if (res) {
          this.logger.info(LOGGER_TAG, 'insert order item success');
          const orderResp = this._createOrderInfoRespItem(orderItem);
          return orderResp;
        } else {
          this.logger.error(LOGGER_TAG + ` upsert order item failed`);
        }
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async cancelCourseOrder(params: OrderNoReq): Promise<number | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.CANCEL_COURSE_ORDER;
    const orderNo = params.orderNo;
    try {
      const orderResource = await this._queryOrderItem(orderNo);
      if (!orderResource) {
        this.logger.error(LOGGER_TAG + 'cannot find order');
        return undefined;
      }
      if (orderResource.orderStatus === OrderStatusMap.CANCEL) {
        this.logger.error(LOGGER_TAG + 'order has been canceled');
        return undefined;
      }
      const res = await this._updateCourseStatus(orderResource, OrderStatusMap.CANCEL);
      this.logger.info(LOGGER_TAG + 'update order status to cancel success');
      return res;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async requestRefundCourseOrder(params: OrderNoReq): Promise<number | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.REQUEST_REFUND_COURSE_ORDER;
    const orderNo = params.orderNo;
    try {
      const orderResource = await this._queryOrderItem(orderNo);
      if (!orderResource) {
        this.logger.error(LOGGER_TAG + 'cannot find order');
        return undefined;
      }
      const res = await this._updateCourseStatus(orderResource, OrderStatusMap.REFUND_IN_PROGRESS);
      if (res) {
        this.logger.info(LOGGER_TAG + 'update order status to request refund success');
        return res;
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async cancelRefundCourseOrder(params: OrderNoReq): Promise<number | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.CANCEL_REFUND_COURSE_ORDER;
    const orderNo = params.orderNo;
    try {
      const orderResource = await this._queryOrderItem(orderNo);
      if (!orderResource) {
        this.logger.error(LOGGER_TAG + 'cannot find order');
        return undefined;
      }
      const res = await this._updateCourseStatus(orderResource, OrderStatusMap.COMPLETE);
      if (res) {
        this.logger.info(LOGGER_TAG + 'update order status to request refund success');
        return res;
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  public async deleteCourseOrder(params: OrderNoReq): Promise<number | undefined> {
    const LOGGER_TAG = TAG + OrderTriggerMap.DELETE_COURSE_ORDER;
    const orderNo = params.orderNo;
    try {
      const orderResource = await this._queryOrderItem(orderNo);
      if (!orderResource) {
        this.logger.error(LOGGER_TAG + 'cannot find order');
        return;
      }
      const res = await this.orderList.delete(orderResource);
      if (res) {
        this.logger.info(LOGGER_TAG + 'delete order success');
        return res;
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return;
  }

  private async _queryOrderItem(orderNo: string): Promise<OrderInfo | undefined> {
    const LOGGER_TAG = TAG + '[query-order-item]';
    try {
      const orderQuery: CloudDBZoneQuery<OrderInfo> = this.orderList
        .query()
        .orderByDesc('orderNo')
        .equalTo('userId', this.userId)
        .equalTo('orderNo', orderNo);
      const orderData: OrderInfo[] = await orderQuery.get();
      if (orderData?.length === 1) {
        return orderData[0];
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  private async _updateCourseStatus(item: OrderInfo, status: OrderStatusMap): Promise<number | undefined> {
    const LOGGER_TAG = TAG + 'update-course-status.';
    const curStatus = item.getOrderStatus();
    let flag = false;
    switch (status) {
      case OrderStatusMap.CANCEL:
        flag = curStatus === OrderStatusMap.PENDING_PAYMENT;
        break;
      case OrderStatusMap.COMPLETE:
        flag = curStatus === OrderStatusMap.PENDING_PAYMENT || curStatus === OrderStatusMap.REFUND_IN_PROGRESS;
        break;
      case OrderStatusMap.REFUND_IN_PROGRESS:
        flag = curStatus === OrderStatusMap.COMPLETE;
        break;
      case OrderStatusMap.REFUNDED:
        flag = curStatus === OrderStatusMap.REFUND_IN_PROGRESS;
        break;
      default:
        this.logger.error(LOGGER_TAG, 'cannot find target order status::' + status);
        break;
    }
    if (flag) {
      try {
        const operator = CloudDBZoneObjectOperator.build(item).update('orderStatus', status);
        const res = await this.orderList.update(operator);
        if (res) {
          this.logger.info(LOGGER_TAG + 'update order status to cancel success');
          return res;
        }
      } catch (err) {
        this.logger.error(LOGGER_TAG, `update order status failed::${err}}`);
      }
    } else {
      this.logger.error(LOGGER_TAG, `init order status:${curStatus} doesn not match target status:${status}`);
    }
    return undefined;
  }

  private async _getCourseDetail(courseId: number): Promise<CourseInfoResp | undefined> {
    const LOGGER_TAG = TAG + 'get course detail';
    try {
      const courseQuery: CloudDBZoneQuery<CloudUserCourseInfo> = this.userCourseList
        .query()
        .orderByAsc('courseId')
        .equalTo('userId', this.userId)
        .equalTo('courseId', courseId);
      const courseData = await courseQuery.get();
      if (courseData?.length) {
        const res = this._createCourseInfoRespItem(courseData[0]);
        return res;
      } else {
        this.logger.error(LOGGER_TAG + ` cannot find activity`);
      }
    } catch (err) {
      this.logger.error(LOGGER_TAG + `error: ${err}`);
    }
    return undefined;
  }

  private async _createOrderInfoRespList(query: CloudDBZoneQuery<OrderInfo>): Promise<ListResp<OrderInfoResp> | undefined> {
    const LOGGER_TAG = TAG + 'create activity resp list';
    try {
      const userData = await query.get();
      const totalCount: number = await query.countQuery('orderNo');
      const listResp: ListResp<OrderInfoResp> = new ListResp<OrderInfoResp>(0, 0, []);
      if (!userData.length) {
        return listResp;
      }
      userData.forEach(async (item: OrderInfo) => {
        const curTime = new Date().getTime();
        const expireTime = item.getExpireTime().getTime();
        if (expireTime && curTime > expireTime && item.getOrderStatus() === OrderStatusMap.PENDING_PAYMENT) {
          await this._updateCourseStatus(item, OrderStatusMap.CANCEL);
          item.setOrderStatus(OrderStatusMap.CANCEL);
        }
        const activityResp: OrderInfoResp = this._createOrderInfoRespItem(item);
        listResp.orderList.push(activityResp);
      });
      listResp.totalCount = totalCount;
      listResp.returnCount = totalCount;
      return listResp;
    } catch (err) {
      this.logger.error(LOGGER_TAG + ` error: ${err}`);
    }
    return undefined;
  }

  private _createCourseInfoRespItem(item: CloudUserCourseInfo): CourseInfoResp {
    const res: CourseInfoResp = {
      courseId: item.getCourseId(),
      type: item.getType(),
      name: item.getName(),
      summary: item.getSummary(),
      detail: item.getDetail(),
      mainDiagram: item.getMainDiagram(),
      price: item.getPrice(),
      expireType: item.getExpireType(),
      startTime: item.getStartTime(),
      endTime: item.getEndTime(),
      orderTime: item.getOrderTime(),
      classHour: item.getClassHour(),
      status: item.getStatus(),
      currentHour: item.getCurrentHour(),
      timetable: JSON.parse(item.getTimetable()),
    };
    return res;
  }

  private _createOrderInfoRespItem(item: OrderInfo): OrderInfoResp {
    const res: OrderInfoResp = {
      orderTime: item.getOrderTime().toString(),
      expireTime: item.getExpireTime().toString(),
      orderStatus: item.getOrderStatus(),
      orderNo: item.getOrderNo(),
      paymentMethod: item.getPaymentMethod(),
      totalPrice: item.getTotalPrice(),
      orderStr: item.getOrderStr(),
      student: item.getStudent(),
      phone: item.getPhone(),
      courseInfo: JSON.parse(item.getCourseInfo() ?? '{}'),
      remark: item.getRemark(),
    };
    return res;
  }
}
