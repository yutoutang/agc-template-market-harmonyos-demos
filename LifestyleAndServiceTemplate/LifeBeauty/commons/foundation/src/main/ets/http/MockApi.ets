import { HttpStatusCode, AxiosRequestConfig } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import {
  ICancelReserveRequest,
  ICreateAppointmentRequest,
  IQueryAppointList,
  IQueryUserInfo,
  IRefundGroup,
  ISubmitOrderRequest,
  IUpdateAppointmentRequest,
  IUpdateUserInfo,
} from '../model/IRequest';
import {
  BindMobileWithCodeResp,
  IAppointment,
  IMyGroupInfo,
  IMySingleCardInfo,
} from '../model/IResponse';
import { MockData } from './MockData';
import { AppointState, GroupOrderStatus, OrderType } from '../constants/AppConstant';
import { MyGroupInfo } from '../model/Model';
import { HttpUrlMap } from '../constants/HttpUrlMap';

export class MockApi {
  // 我的预约
  static myAppointmentList: IAppointment[] = [];
  // 我的团购
  static myGroupList: IMyGroupInfo[] = [];
  // 我的次卡
  static mySingleCardList: IMySingleCardInfo[] = [];

  static transAppointment(raw: ICreateAppointmentRequest): IAppointment {
    let goodName = raw.goodId;
    if (raw.goodType === OrderType.SINGLE_CARD) {
      MockData.GOOD_LIST.forEach(v => {
        v.goods.forEach(g => {
          if (g.id === Number(raw.goodId)) {
            goodName = g.title;
          }
        })
      })
    } else {
      MockData.GROUP_LIST.forEach((v) => {
        if (v.id === Number(raw.goodId)) {
          goodName = v.title;
        }
      })
    }
    const resp: IAppointment = {
      id: MockData.initialAppointId++,
      storeId: MockData.STORE_INFO.id,
      userId: MockData.USER_ID,
      type: 0,
      reserveTime: Number(raw.reserveTime),
      duration: 0,
      remarks: raw.remarks,
      state: 10,
      contactName: raw.name,
      contactPhone: raw.phone,
      itemName: goodName,
      itemPic: '',
      numbers: Number(raw.numbers),
      setSchedule: 0,
      setSubscription: 0,
      completedTime: null,
      createdTime: new Date().getTime().toString(),
      nickName: '',
      avatar: '',
      orderNo: raw.orderNo,
    };
    return resp;
  }

  public start(adapter: AxiosMockAdapter) {
    /**
     * 华为账号登录
     */
    adapter.onPost(HttpUrlMap.LOGIN_WITH_HUAWEI_ID).reply(() => {
      return [HttpStatusCode.Ok, MockData.LOGIN_RESP];
    });

    /**
     * 刷新用户token
     */
    adapter.onPost(HttpUrlMap.REFRESH_TOKEN).reply(() => {
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 绑定手机号
     */
    adapter.onPost(HttpUrlMap.BIND_MOBILE_WITH_CODE).reply(() => {
      const resp: BindMobileWithCodeResp = {
        status: '0',
        rebindSecret: '',
      };
      return [HttpStatusCode.Ok, resp];
    });

    /**
     * 绑定手机号-确认换绑
     */
    adapter.onPost(HttpUrlMap.CONFIRM_REBIND_MOBILE).reply(() => {
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 读取用户信息
     */
    adapter.onGet(HttpUrlMap.GET_USER_INFO).reply((config: AxiosRequestConfig) => {
      const params: IQueryUserInfo = config?.params;
      const isBindMobile = params?.isBindMobile;
      const resp = isBindMobile ? MockData.USER_INFO_FULL : MockData.USER_INFO_UNBIND;
      return [HttpStatusCode.Ok, resp];
    })

    /**
     * 更新用户信息
     */
    adapter.onPost(HttpUrlMap.UPDATE_USER_INFO).reply((config: AxiosRequestConfig) => {
      const data: IUpdateUserInfo = JSON.parse(config?.data ?? '{}') as IUpdateUserInfo;
      if (data.nickName) {
        MockData.USER_INFO_FULL.nickName = data.nickName;
      }
      if (data.avatarUrl) {
        MockData.USER_INFO_FULL.avatar = data.avatarUrl;
      }
      if (data.mobile) {
        MockData.USER_INFO_FULL.mobile = data.mobile;
      }
      if (data.gender) {
        MockData.USER_INFO_FULL.gender = data.gender;
      }
      if (data.birthDate) {
        MockData.USER_INFO_FULL.birthDate = data.birthDate;
      }
      if (data.fullName) {
        MockData.USER_INFO_FULL.fullName = data.fullName;
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 手机号解绑
     */
    adapter.onPost(HttpUrlMap.UNBIND_MOBILE).reply(() => {
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 查询门店信息
     */
    adapter.onGet(HttpUrlMap.GET_STORE_INFO).reply(() => {
      return [HttpStatusCode.Ok, MockData.STORE_INFO];
    });

    /**
     * 查询所有门店列表信息
     */
    adapter.onGet(HttpUrlMap.GET_STORE_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.STORE_LIST];
    });

    /**
     * 查询商品列表
     */
    adapter.onGet(HttpUrlMap.GET_GOOD_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.GOOD_LIST];
    });

    /**
     * 查询预约列表
     */
    adapter.onGet(HttpUrlMap.GET_APPOINTMENT_LIST).reply((config: AxiosRequestConfig) => {
      const params: IQueryAppointList = config?.params;
      const resp = MockApi.myAppointmentList.filter(v => {
        return (params.status || []).includes(v.state);
      });
      return [HttpStatusCode.Ok, resp];
    });

    /**
     * 创建预约
     */
    adapter.onPost(HttpUrlMap.CREATE_APPOINTMENT_INFO).reply((config: AxiosRequestConfig) => {
      const data: ICreateAppointmentRequest = JSON.parse(config?.data ?? '{}') as ICreateAppointmentRequest;
      const resp = MockApi.transAppointment(data);
      MockApi.myAppointmentList.splice(0, 0, resp);
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 修改预约信息
     */
    adapter.onPost(HttpUrlMap.UPDATE_APPOINTMENT_INFO).reply((config: AxiosRequestConfig) => {
      const data: IUpdateAppointmentRequest = JSON.parse(config?.data ?? '{}') as IUpdateAppointmentRequest;
      const item = MockApi.myAppointmentList.find(v => v.id === data.reserveId);
      if (item) {
        item.setSubscription = data.setSubscription;
        item.setSchedule = data.setSchedule;
        if (data.completedTime) {
          item.completedTime = data.completedTime
        }
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 取消预约
     */
    adapter.onPost(HttpUrlMap.CANCEL_APPOINTMENT).reply((config: AxiosRequestConfig) => {
      const data: ICancelReserveRequest = JSON.parse(config?.data ?? '{}') as ICancelReserveRequest;
      const item = MockApi.myAppointmentList.find(v => v.id === data.reserveId);
      if (item) {
        item.state = AppointState.CANCEL;
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 开通会员卡
     */
    adapter.onPost(HttpUrlMap.ACTIVE_MEMBER_CARD).reply(() => {
      MockData.USER_INFO_FULL.memberId = new Date().getTime().toString();
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 次卡查询
     */
    adapter.onGet(HttpUrlMap.GET_SINGLE_VISIT_CARD_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.SINGLE_CARD_LIST];
    });

    /**
     * 团购查询
     */
    adapter.onGet(HttpUrlMap.GET_GROUP_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockData.GROUP_LIST];
    });

    /**
     * 预下单
     */
    adapter.onPost(HttpUrlMap.PRE_ORDER).reply((config: AxiosRequestConfig) => {
      const data: ISubmitOrderRequest = JSON.parse(config?.data ?? '{}') as ISubmitOrderRequest;
      // 区分类型，团购/次卡
      const orderNo = (new Date().getTime().toString() + new Date().getTime().toString()).slice(0, 15);
      if (data.type === OrderType.SINGLE_CARD) {
        const raw = MockData.SINGLE_CARD_LIST.find(v => v.id === data.projectId);
        const resp: IMySingleCardInfo = {
          singleCardSerialNo: orderNo,
          singleCardId: data.projectId,
          title: raw?.title ?? '',
          availableNums: raw?.availableNum ?? 0,
          leftNums: (raw?.availableNum ?? 0) * data.numbers,
          availableProName: raw?.projectNum.toString() ?? '',
          availablePeriod: -1,
          usageRecord: [],
        };
        MockApi.mySingleCardList.splice(0, 0, resp);
      } else {
        const resp = new MyGroupInfo();
        resp.groupId = data.projectId;
        resp.contactPhone = data.contactPhone;
        resp.purchaseNums = data.numbers;
        resp.actualPay = data.actualPay;
        resp.status = GroupOrderStatus.AVAILABLE;
        resp.groupSerialNo = new Date().getTime().toString();
        resp.orderNo = orderNo;
        resp.orderTime = new Date().getTime();
        resp.payTime = new Date().getTime();
        resp.groupStoreId = data.groupStoreId;
        const raw = MockData.GROUP_LIST.find(v => v.id === data.projectId);
        if (raw) {
          resp.title = raw.title;
          resp.subTitle = raw.subTitle;
          resp.images = raw.images;
          resp.vipPrice = raw.vipPrice;
          resp.price = raw.price;
          resp.groupContent = raw.groupContent;
        }
        MockApi.myGroupList.splice(0, 0, resp);
      }
      return [HttpStatusCode.Ok, orderNo];
    });

    /**
     * 查询用户购买的次卡
     */
    adapter.onGet(HttpUrlMap.GET_MY_SINGLE_VISIT_CARD_LIST).reply(() => {
      return [HttpStatusCode.Ok, MockApi.mySingleCardList];
    });

    /**
     * 使用或核销用户购买的次卡
     */
    adapter.onPut(HttpUrlMap.UPDATE_MY_SINGLE_VISIT_CARD).reply((config: AxiosRequestConfig) => {
      const data: IMySingleCardInfo = JSON.parse(config?.data ?? '{}') as IMySingleCardInfo;
      for (let i = 0; i < MockApi.mySingleCardList.length; i++) {
        const item = MockApi.mySingleCardList[i];
        if (item.singleCardSerialNo === data.singleCardSerialNo) {
          item.leftNums = data.leftNums;
          item.usageRecord = data.usageRecord;
          break;
        }
      }
      return [HttpStatusCode.Ok, true];
    });

    /**
     * 查询用户购买的团购
     */
    adapter.onGet(HttpUrlMap.GET_MY_GROUP_LIST).reply((config: AxiosRequestConfig) => {
      const params: ESObject = config?.params;
      let resp = MockApi.myGroupList;
      if (params?.status !== -1) {
        resp = MockApi.myGroupList.filter(v => v.status === params.status);
      }
      return [HttpStatusCode.Ok, resp];
    });

    /**
     * 团购退款
     */
    adapter.onPost(HttpUrlMap.REFUND_GROUP).reply((config: AxiosRequestConfig) => {
      const data: IRefundGroup = JSON.parse(config?.data ?? '{}') as IRefundGroup;
      MockApi.myGroupList.find((v) => {
        if (v.orderNo === data.orderNo) {
          v.status = GroupOrderStatus.REFUND;
          v.refundTime = new Date().getTime();
        }
      })
      return [HttpStatusCode.Ok, true];
    });
  }

}