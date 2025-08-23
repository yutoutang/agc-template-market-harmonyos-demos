import { RequestUrl } from '../constants/NetworkEnums';
import request from '../models/AxiosRequest';
import {
  BaseSuccessResponse,
  CancelOrderRequest,
  ExplainTicketRequest,
  GetBannerImgRequest,
  OrderDetailRequest,
  OrderFreeRequest,
  OrderListRequest,
  PreActiveOrderBody,
  PreExplainOrderBody,
  PrepayBuyTicketRequest,
  RepayOrderBody
} from '../types/RequestTypes';
import {
  ActiveInfo,
  ActiveOrder,
  BaseResponse,
  CloudUrl,
  ExplainOrder,
  GetDayTicketResp,
  GetExplainResp,
  GetExplainTicketInfoResp,
  GetIntroduceResp,
  GetOrderDetailResp,
  GetOrderListInfoResp,
  GetPerformanceInfoResp,
  GetRecommendListResp,
  GetTicketTypeInfoResp,
  GetTimeTicketResp,
  GetTrafficDetailResp,
  GetUserInfoResp,
  ParkTextResp,
  PrepayBuyTicketResp,
  TreasureItem,
  UpdateUserInfoRequest,
  UserLoginResp,
} from '../types/ResponseTypes';

class HttpApi {
  public bindPhone(authCode: string): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_BIND_PHONE,
      data: { authCode },
    });
  }

  public cancelPhone(): Promise<BaseResponse<undefined>> {
    return request.post({
      url: RequestUrl.USER_CANCEL_PHONE,
    });
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    return request.get({ url: RequestUrl.USER_GET_INFO });
  }

  public userLogin(): Promise<BaseResponse<UserLoginResp>> {
    return request.post({ url: RequestUrl.USER_LOGIN });
  }

  public getRecommendList(): Promise<BaseResponse<GetRecommendListResp>> {
    return request.get({ url: RequestUrl.HOME_RECOMMEND_LIST });
  }

  // 获取订单列表
  public getOrderList(data: OrderListRequest): Promise<BaseResponse<GetOrderListInfoResp>> {
    return request.get({
      url: RequestUrl.ORDER_LIST_INFO, data,
    });
  }

  //   获取订单详情
  public getOrderDetail(data: OrderDetailRequest): Promise<BaseResponse<GetOrderDetailResp>> {
    return request.get({
      url: RequestUrl.ORDER_TICKET_DETAIL, data,
    });
  }

  // 取消展览预定
  public cancelOrder(data: CancelOrderRequest): Promise<BaseSuccessResponse> {
    return request.post({
      url: RequestUrl.CANCEL_ORDER, data,
    });
  }

  //   获取特展信息
  public getPerformanceInfo(): Promise<BaseResponse<GetPerformanceInfoResp>> {
    return request.get({ url: RequestUrl.PERFORMANCE_INFO });
  }

  //  免费约展时间信息
  public getDayTicket(): Promise<BaseResponse<GetDayTicketResp>> {
    return request.get({ url: RequestUrl.ORDER_DAY_TICKET });
  }

  // 付费约展时间信息
  public getTimeTicket(data: string): Promise<BaseResponse<GetTimeTicketResp>> {
    return request.get({ url: RequestUrl.BUY_TIME_TICKET, data });
  }

  //  讲解服务信息
  public getExplain(): Promise<BaseResponse<GetExplainResp>> {
    return request.get({ url: RequestUrl.EXPLAIN });
  }

  //   省博介绍文本
  public getIntroduceText(): Promise<BaseResponse<GetIntroduceResp>> {
    return request.get({ url: RequestUrl.INTRODUCE_TEXT });
  }

  //   停车缴费文本
  public getParkingText(): Promise<BaseResponse<ParkTextResp[]>> {
    return request.get({ url: RequestUrl.PARKING_TEXT });
  }

  //   隐私政策文本
  public getPrivacyText(): Promise<BaseResponse<string[][]>> {
    return request.get({ url: RequestUrl.PRIVACY_TEXT });
  }

  // 更新用户信息
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseSuccessResponse> {
    return request.post({
      url: RequestUrl.UPDATE_USERINFO,
      data,
    });
  }



  // 免费预定
  public orderFree(data: OrderFreeRequest): Promise<BaseSuccessResponse<GetOrderDetailResp>> {
    return request.post({ url: RequestUrl.ORDER_FREE, data });
  }

  //   获取票种信息
  public getTicketType(data: string): Promise<BaseResponse<GetTicketTypeInfoResp>> {
    return request.post({ url: RequestUrl.TICKET_TYPE_INFO, data });
  }

  //   预支付
  public prePayBuyTicket(data: PrepayBuyTicketRequest): Promise<BaseResponse<PrepayBuyTicketResp>> {
    return request.post({ url: RequestUrl.BUY_TICKET, data });
  }

  //   获取banner图
  public getBannerImg(data: GetBannerImgRequest): Promise<BaseResponse<string | string[]>> {
    return request.get({ url: RequestUrl.BANNER_IMG, data });
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
    return request.get({ url: RequestUrl.TRAFFIC_DETAIL });
  }

  // 获取讲解余票列表
  public getExplainTicketList(data: ExplainTicketRequest): Promise<BaseResponse<GetExplainTicketInfoResp>> {
    return request.get({
      url: RequestUrl.EXPLAIN_TICKET, data
    });
  }

  // 获取讲解余票列表
  public getExplainOrders(): Promise<BaseResponse<ExplainOrder[]>> {
    return request.get({
      url: RequestUrl.EXPLAIN_ORDERS
    });
  }

  // 讲解门票预支付
  public preOrderExplain(data: PreExplainOrderBody): Promise<BaseResponse<ExplainOrder>> {
    return request.post({url:RequestUrl.EXPLAIN_PREPAY,data})
  }

  //  获取云存储资源
  public getCloudUrl(): Promise<BaseResponse<CloudUrl>> {
    return request.get({url:RequestUrl.CLOUD_URL})
  }

  //  获取珍品馆藏信息
  public getTreasureInfo(): Promise<BaseResponse<TreasureItem[]>> {
    return request.get({url:RequestUrl.TREASURE_INFO})
  }

  // 取消讲解预定
  public cancelExplainOrder(data: CancelOrderRequest): Promise<BaseResponse<null>> {
    return request.post({
      url: RequestUrl.CANCEL_EXPLAIN_ORDER, data,
    });
  }

  // 取消活动预定
  public cancelActiveOrder(data: CancelOrderRequest): Promise<BaseResponse<null>> {
    return request.post({
      url: RequestUrl.CANCEL_ACTIVE_ORDER, data,
    });
  }

  //  获取活动信息
  public getActiveInfo(): Promise<BaseResponse<ActiveInfo[]>> {
    return request.get({url:RequestUrl.ACTIVE_INFO})
  }

  //  获取活动订单
  public getActiveOrders(): Promise<BaseResponse<ActiveOrder[]>> {
    return request.get({url:RequestUrl.ACTIVE_ORDERS})
  }


  // 活动门票预支付
  public preOrderActive(data:PreActiveOrderBody): Promise<BaseResponse<ActiveOrder>> {
    return request.post({url:RequestUrl.ACTIVE_PREPAY,data})
  }

  // 重新支付订单
  public repayOrder(data: RepayOrderBody): Promise<BaseResponse<null | ActiveOrder | ExplainOrder>> {
    return request.post({
      url: RequestUrl.REPAY_ORDER,
      data,
    });
  }


}

const https = new HttpApi();

export { https };