import { AccountUtil, UserInfo } from 'commonlib';
import { MockStorageMap } from './Constants';
import { UserDatasetMock } from './MockData/UserMockData';
import { BannerDatasetMock } from './MockData/BannerMockData';
import { ExplainDatasetMock } from './MockData/ExplainMockData';
import { recommendListResp, introduceTextResp, parkingTextResp } from './MockData/HomeMockData';
import { privacyTextResp } from './MockData/MineMockData';
import { OrderDatasetMock } from './MockData/OrderMockData';
import { PerformanceDatasetMock } from './MockData/PerformanceMockData';
import { ActiveDataSetMock } from '../mocks/MockData/ActiveMockData';
import { treasureInfoResp } from '../mocks/MockData/TreasureMockData';
import {
  BaseResponse,
  GetUserInfoResp,
  GetRecommendListResp,
  GetOrderListInfoResp,
  GetOrderDetailResp,
  GetPerformanceInfoResp,
  GetDayTicketResp,
  GetExplainResp,
  GetIntroduceResp,
  GetTimeTicketResp,
  GetTicketTypeInfoResp,
  PrepayBuyTicketResp,
  UpdateUserInfoRequest,
  UserLoginResp,
  ParkTextResp,
  GetTrafficDetailResp,
  GetExplainTicketInfoResp,
  ExplainOrder,
  CloudUrl,
  TreasureItem,
  ActiveInfo,
  ActiveOrder,
} from '../types/ResponseTypes';
import {
  BaseSuccessResponse,
  OrderListRequest,
  CancelOrderRequest,
  OrderDetailRequest,
  OrderFreeRequest,
  PrepayBuyTicketRequest,
  GetBannerImgRequest,
  ExplainTicketRequest,
  PreExplainOrderBody,
  PreActiveOrderBody,
  RepayOrderBody,
  OrderType,
} from '../types/RequestTypes';


class HttpApiMock {
  public bindPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    UserDatasetMock.bindPhone();
    return Promise.resolve(resp);
  }

  public cancelPhone(): Promise<BaseResponse<undefined>> {
    const resp: BaseResponse = { code: 0, data: undefined };
    UserDatasetMock.cancelPhone();
    return Promise.resolve(resp);
  }

  public getUserInfo(): Promise<BaseResponse<GetUserInfoResp>> {
    const userInfoMock = AppStorage.get<GetUserInfoResp>(MockStorageMap.USER_INFO);
    if (userInfoMock) {
      const resp: BaseSuccessResponse<GetUserInfoResp> = {
        code: 0,
        data: userInfoMock,
      };
      return Promise.resolve(resp);
    }
    AppStorage.setOrCreate<GetUserInfoResp>(MockStorageMap.USER_INFO, UserDatasetMock.getUserInfo().data);
    return Promise.resolve(UserDatasetMock.getUserInfo());
  }

  public userLogin(): Promise<BaseResponse<UserLoginResp>> {
    return Promise.resolve(UserDatasetMock.userLoginResp());
  }

  public getRecommendList(): Promise<BaseResponse<GetRecommendListResp>> {
    const resp: BaseResponse<GetRecommendListResp> = recommendListResp;
    return Promise.resolve(resp);
  }

  //  订单列表
  public getOrderList(data: OrderListRequest): Promise<BaseResponse<GetOrderListInfoResp>> {
    const resp: BaseResponse<GetOrderListInfoResp> = OrderDatasetMock.getOrderListMock(data.orderClass);
    return Promise.resolve(resp);
  }

  //  取消预定
  public cancelOrder(data: CancelOrderRequest): Promise<BaseSuccessResponse> {
    OrderDatasetMock.cancelOrder(data);
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  //   获取订单详情
  public getOrderDetail(data: OrderDetailRequest): Promise<BaseResponse<GetOrderDetailResp | undefined>> {
    const resp: BaseResponse<GetOrderDetailResp | undefined> = OrderDatasetMock.getOrderDetailMock(data.orderNo);
    return Promise.resolve(resp);
  }

  //   获取特展信息
  public getPerformanceInfo(): Promise<BaseResponse<GetPerformanceInfoResp>> {
    const resp: BaseResponse<GetPerformanceInfoResp> = PerformanceDatasetMock.getPerformanceInfoResp();
    return Promise.resolve(resp);
  }

  //   免费预约时间票务信息
  public getDayTicket(): Promise<BaseResponse<GetDayTicketResp>> {
    const resp: BaseResponse<GetDayTicketResp> = OrderDatasetMock.getDayTicketMock();
    return Promise.resolve(resp);
  }

  //   付费预约时间票务信息
  public getTimeTicket(data: string): Promise<BaseResponse<GetTimeTicketResp>> {
    const resp: BaseResponse<GetTimeTicketResp> = OrderDatasetMock.getTimeTicketMock();
    return Promise.resolve(resp);
  }

  //   讲解服务
  public getExplain(): Promise<BaseResponse<GetExplainResp>> {
    const resp: BaseResponse<GetExplainResp> = ExplainDatasetMock.getExplain();
    return Promise.resolve(resp);
  }

  //   省博介绍
  public getIntroduceText(): Promise<BaseResponse<GetIntroduceResp>> {
    const resp: BaseResponse<GetIntroduceResp> = introduceTextResp;
    return Promise.resolve(resp);
  }

  //   停车缴费
  public getParkingText(): Promise<BaseResponse<ParkTextResp[]>> {
    const resp: BaseResponse<ParkTextResp[]> = parkingTextResp;
    return Promise.resolve(resp);
  }

  //   隐私政策
  public getPrivacyText(): Promise<BaseResponse<string[][]>> {
    const resp: BaseResponse<string[][]> = privacyTextResp;
    return Promise.resolve(resp);
  }

  // 更新用户信息
  public updateUserInfo(data: UpdateUserInfoRequest): Promise<BaseSuccessResponse> {
    const userInfoMock = AppStorage.get<UpdateUserInfoRequest>(MockStorageMap.USER_INFO);
    if (userInfoMock) {
      userInfoMock.name = data.name;
      userInfoMock.nickname = data.nickname;
      userInfoMock.sex = data.sex;
      userInfoMock.cellphone = data.cellphone;
      userInfoMock.birthday = data.birthday;
      userInfoMock.avatar = data.avatar;
      AppStorage.set<UpdateUserInfoRequest>(MockStorageMap.USER_INFO, userInfoMock);
      AccountUtil.updateUserInfo(data as UserInfo);
    }
    const resp: BaseSuccessResponse<undefined> = {
      code: 0,
      data: undefined,
    };
    return Promise.resolve(resp);
  }

  //   免费预定
  public orderFree(data: OrderFreeRequest): Promise<BaseSuccessResponse<GetOrderDetailResp>> {
    const resp: BaseSuccessResponse<GetOrderDetailResp> = OrderDatasetMock.orderFreeMock(data);
    return Promise.resolve(resp);
  }

  //   获取票种信息
  public getTicketType(data: string): Promise<BaseResponse<GetTicketTypeInfoResp>> {
    const resp: BaseResponse<GetTicketTypeInfoResp> = OrderDatasetMock.getTicketType(data);
    return Promise.resolve(resp);
  }

  //   预支付
  public prePayBuyTicket(data: PrepayBuyTicketRequest): Promise<BaseResponse<PrepayBuyTicketResp>> {
    const resp: BaseSuccessResponse<PrepayBuyTicketResp> = OrderDatasetMock.prepayBuyTicket(data);
    return Promise.resolve(resp);
  }

  //   banner图
  public getBannerImg(data: GetBannerImgRequest): Promise<BaseResponse<string | string[]>> {
    const resp: BaseSuccessResponse<string | string[]> = BannerDatasetMock.getBannerSource(data);
    return Promise.resolve(resp);
  }

  // 获取交通信息
  public getTrafficDetail(): Promise<BaseResponse<GetTrafficDetailResp>> {
    const data: GetTrafficDetailResp = {
      name: '博物馆',
      coordinate: '113.8827804,22.9241942',
    };
    const resp: BaseSuccessResponse<GetTrafficDetailResp> = {
      code: 0,
      data: data,
    };
    return Promise.resolve(resp);
  }

  // 获取讲解门票信息
  public getExplainTicketList(data: ExplainTicketRequest): Promise<BaseResponse<GetExplainTicketInfoResp>> {
    const resp: BaseSuccessResponse<GetExplainTicketInfoResp> = ExplainDatasetMock.getExplainTicket(data);
    return Promise.resolve(resp);
  }

  // 获取讲解门票订单
  public getExplainOrders(): Promise<BaseResponse<ExplainOrder[]>> {
    const resp: BaseSuccessResponse<ExplainOrder[]> = ExplainDatasetMock.getExplainOrders();
    return Promise.resolve(resp);
  }

  // 讲解门票预支付
  public preOrderExplain(data: PreExplainOrderBody): Promise<BaseResponse<ExplainOrder>> {
    const resp: BaseSuccessResponse<ExplainOrder> = ExplainDatasetMock.preExplainOrder(data);
    return Promise.resolve(resp);
  }

  // 获取云存储资源
  public getCloudUrl(): Promise<BaseResponse<CloudUrl>> {
    return Promise.resolve(BannerDatasetMock.getCloudUrl());
  }

  //  获取珍品馆藏信息
  public getTreasureInfo(): Promise<BaseResponse<TreasureItem[]>> {
    return Promise.resolve(treasureInfoResp);
  }

  // 取消讲解预定
  public cancelExplainOrder(data: CancelOrderRequest): Promise<BaseResponse<null>> {
    return Promise.resolve(ExplainDatasetMock.cancelExplainOrder(data));
  }

  // 取消活动预定
  public cancelActiveOrder(data: CancelOrderRequest): Promise<BaseResponse<null>> {
    return Promise.resolve(ActiveDataSetMock.cancelActiveOrder(data));
  }

  //  获取活动信息
  public getActiveInfo(): Promise<BaseResponse<ActiveInfo[]>> {
    return Promise.resolve(ActiveDataSetMock.getActiveInfo());
  }

  //  获取活动订单
  public getActiveOrders(): Promise<BaseResponse<ActiveOrder[]>> {
    return Promise.resolve(ActiveDataSetMock.getActiveInOrders());
  }

  // 活动门票预支付
  public preOrderActive(data: PreActiveOrderBody): Promise<BaseResponse<ActiveOrder>> {
    return Promise.resolve(ActiveDataSetMock.preActiveOrder(data));
  }

  // 重新支付订单
  public repayOrder(data: RepayOrderBody): Promise<BaseResponse<null | ActiveOrder | ExplainOrder>> {
    if (data.orderType === OrderType.ACTIVE_ORDER) {
      return Promise.resolve(ActiveDataSetMock.repayOrder(data.orderNo));
    } else if (data.orderType === OrderType.EXPLAIN_ORDER) {
      return Promise.resolve(ExplainDatasetMock.repayOrder(data.orderNo));
    } else {
      return Promise.resolve(OrderDatasetMock.repayOrder(data.orderNo));
    }
  }
}

const httpsMock = new HttpApiMock();

export { httpsMock };
