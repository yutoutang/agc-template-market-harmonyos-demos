import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import { RequestUrlMap } from '../../constants/Enums';
import {
  ProductForPointsResp,
  UserPointsRecordItem,
  UserPoints,
  UserPointsRecordResp,
  UserPointsResp,
  UserPointRedemptionSku,
} from '../../types/responses/UserResponse';
import { updateUserPointsReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import { MOCK_POINTS_RECORD_LIST, MOCK_POINTS_REDEMPTION_LIST } from '../mockdata/MockUserData';

@ObservedV2
export class UserPointsModel implements UserPoints {
  @Trace totalPoints: number = 35
  @Trace checkedDays: number = 1
  @Trace latestCheck: number = 0
  @Trace pointsArr: number[] = [5, 10, 15, 20, 25, 30, 40]
}

export class UserMockApis {
  private _mockList: UserPointsRecordItem[] = MOCK_POINTS_RECORD_LIST
  private userPointModel:UserPointsModel = new UserPointsModel()

  public start(adapter: AxiosMockAdapter) {
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
      const date: string = config.params.date
      const list = this._mockList.filter((item) => {
        const temp = new Date(item.time)
        const str = temp.getFullYear() + '-' + (temp.getMonth() + 1)
        return str === date
      })
      const res: UserPointsRecordResp = {
        code: 0,
        list,
        totalPoints: this.userPointModel.totalPoints,
        month: date,
      }
      return [HttpStatusCode.Ok, res];
    })

    // 更新用户积分
    adapter.onPut(RequestUrlMap.USER_POINTS).reply((config: AxiosRequestConfig) => {
      const data: updateUserPointsReq = JSON.parse(config.data)
      const model = this.userPointModel;
      model.totalPoints = model.totalPoints + data.newPoints;
      model.latestCheck = Date.now();
      model.checkedDays++;
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: data.type,
        label: data.label,
        points: data.newPoints,
      }
      this._mockList.unshift(newItem);
      const res: BaseResponse = {
        code: 0,
      }
      return [HttpStatusCode.Ok, res]
    })

    // 获取积分可兑换的商品列表
    adapter.onGet(RequestUrlMap.USER_POINTS_PRODUCT).reply(() => {
      const res: ProductForPointsResp = {
        code: 0,
        list: MOCK_POINTS_REDEMPTION_LIST,
      }
      return [HttpStatusCode.Ok, res]
    })

    // 积分兑换商品
    adapter.onPost(RequestUrlMap.USER_POINTS_REDEMPTION).reply((config: AxiosRequestConfig) => {
      const product: UserPointRedemptionSku = JSON.parse(config.data)
      this.userPointModel.totalPoints = this.userPointModel.totalPoints - product.price;
      const newItem: UserPointsRecordItem = {
        time: new Date().getTime(),
        type: 1,
        label: '积分兑换: ' + product.title,
        points: -product.price,
      }
      this._mockList.unshift(newItem);
      const res: BaseResponse = {
        code: 0,
      }
      return [HttpStatusCode.Ok, res]
    })
  }
}
