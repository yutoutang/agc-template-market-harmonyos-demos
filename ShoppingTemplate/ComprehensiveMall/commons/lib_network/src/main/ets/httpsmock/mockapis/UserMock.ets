import { PersistenceV2 } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import dayjs from 'dayjs';
import { iData } from 'lib_foundation';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { UpdateUserInfoReq, UpdateUserPointsReq, UserLoginReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductForPointsResp,
  UserPointsRecordItem,
  UserPoints,
  UserPointsRecordResp,
  UserPointsResp,
  UserPointRedemptionSku,
  MembershipInfo,
  MembershipInfoResp,
} from '../../types/responses/UserResponse';
import { MOCK_POINTS_RECORD_LIST, MOCK_POINTS_REDEMPTION_LIST } from '../mockdata/MockUserData';

@ObservedV2
export class UserPointsModel implements UserPoints {
  @Trace totalPoints: number = 35;
  @Trace checkedDays: number = 1;
  @Trace latestCheck: number = 0;
  @Trace pointsArr: number[] = [5, 10, 15, 20, 25, 30, 40];
}

@ObservedV2
export class MembershipInfoModel implements MembershipInfo {
  startDate: string = '';
  expireDate: string = '';
  isSubscribed: boolean = false;
}

export class UserMockApis {
  private _mockList: UserPointsRecordItem[] = MOCK_POINTS_RECORD_LIST;
  private userPointModel: UserPointsModel = new UserPointsModel();

  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onGet(RequestUrlMap.USER_LOGIN).reply((config: AxiosRequestConfig) => {
      const params = config.params as UserLoginReq;
      iData.global.isLogin = true;
      iData.global.userInfo.reset();
      iData.global.userInfo.nickname = '华为用户';
      const phone = params?.phoneNumbers ?? '12345678900';
      iData.global.userInfo.phone = phone;
      iData.global.userInfo.anonymousPhone = phone.slice(0, 3) + '****' + phone.slice(7);
      iData.global.userInfo.avatar = '';
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });
    // 用户登出
    adapter.onGet(RequestUrlMap.USER_LOGOUT).reply(() => {
      iData.global.userInfo.reset();
      iData.global.isLogin = false;
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });
    // 更新用户信息
    adapter.onPut(RequestUrlMap.USER_INFO).reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as UpdateUserInfoReq;
      switch (data.type) {
        case 'avatar':
          iData.global.userInfo.avatar = data.value;
          break;
        case 'nickname':
          iData.global.userInfo.nickname = data.value;
          break;
        case 'phone':
          iData.global.userInfo.phone = data.value;
          if (data.value.length === 11) {
            iData.global.userInfo.anonymousPhone = data.value.slice(0, 3) + '****' + data.value.slice(7);
          }
          break;
        default:
          break;
      }
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取用户积分信息
    adapter.onGet(RequestUrlMap.USER_POINTS).reply(() => {
      const res: UserPointsResp = {
        code: 0,
        data: {
          checkedDays: this.userPointModel.checkedDays,
          totalPoints: this.userPointModel.totalPoints,
          latestCheck: this.userPointModel.latestCheck,
          pointsArr: this.userPointModel.pointsArr,
        },
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取用户积分明细
    adapter.onGet(RequestUrlMap.USER_POINTS_DETAIL).reply((config: AxiosRequestConfig) => {
      const date: string = config.params.date;
      const list = this._mockList.filter((item) => {
        const str = dayjs(item.time).format('YYYY-MM');
        return str === date;
      });
      const res: UserPointsRecordResp = {
        code: 0,
        list,
        totalPoints: this.userPointModel.totalPoints,
        month: date,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 更新用户积分
    adapter.onPut(RequestUrlMap.USER_POINTS).reply((config: AxiosRequestConfig) => {
      const data: UpdateUserPointsReq = JSON.parse(config.data);
      const model = this.userPointModel;
      model.totalPoints = model.totalPoints + data.newPoints;
      model.latestCheck = Date.now();
      model.checkedDays++;
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: data.type,
        label: data.label,
        points: data.newPoints,
      };
      this._mockList.unshift(newItem);
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 获取积分可兑换的商品列表
    adapter.onGet(RequestUrlMap.USER_POINTS_PRODUCT).reply(() => {
      const res: ProductForPointsResp = {
        code: 0,
        list: MOCK_POINTS_REDEMPTION_LIST,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 积分兑换商品
    adapter.onPost(RequestUrlMap.USER_POINTS_REDEMPTION).reply((config: AxiosRequestConfig) => {
      const product: UserPointRedemptionSku = JSON.parse(config.data);
      this.userPointModel.totalPoints = this.userPointModel.totalPoints - product.price;
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: 1,
        label: '积分兑换: ' + product.title,
        points: -product.price,
      };
      this._mockList.unshift(newItem);
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 开通/续费年卡会员
    adapter.onPost(RequestUrlMap.USER_MEMBERSHIP).reply(() => {
      const infoModel = PersistenceV2.connect(
        MembershipInfoModel,
        'membershipInfo',
        () => new MembershipInfoModel())!;
      if (!infoModel.isSubscribed || (infoModel.isSubscribed && !infoModel.startDate)) {
        infoModel.isSubscribed = true;
        const curDate = dayjs();
        infoModel.startDate = dayjs(curDate).format('YYYY-MM-DD');
        infoModel.expireDate = dayjs(curDate).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      } else {
        const curDate: dayjs.Dayjs = dayjs(infoModel.expireDate);
        infoModel.expireDate =
          dayjs(new Date(infoModel.expireDate)).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      }
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 查询会员信息
    adapter.onGet(RequestUrlMap.USER_MEMBERSHIP).reply(() => {
      const infoModel = PersistenceV2.connect(
        MembershipInfoModel,
        'membershipInfo',
        () => new MembershipInfoModel())!;
      if (iData.global.userInfo.isMember && !infoModel.isSubscribed) {
        infoModel.isSubscribed = true;
        const curDate = dayjs();
        infoModel.startDate = dayjs(curDate).format('YYYY-MM-DD');
        infoModel.expireDate = dayjs(curDate).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      }
      const res: MembershipInfoResp = {
        code: 0,
        data: {
          isSubscribed: infoModel.isSubscribed,
          startDate: infoModel.startDate,
          expireDate: infoModel.expireDate,
        },
      };
      return [HttpStatusCode.Ok, res];
    });
  }
}
