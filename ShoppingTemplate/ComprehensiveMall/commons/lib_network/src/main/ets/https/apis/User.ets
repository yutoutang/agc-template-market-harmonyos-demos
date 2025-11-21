import { RequestUrlMap } from '../../constants/Enums';
import { updateUserPointsReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  ProductForPointsResp,
  UserPointRedemptionSku,
  UserPointsRecordResp,
  UserPointsResp,
} from '../../types/responses/UserResponse';
import request from '../Request';

class UserApis {
  /**
   * 获取用户积分信息
   */
  public getUserPoints(): Promise<UserPointsResp> {
    return request.get(RequestUrlMap.USER_POINTS);
  }

  /**
   * 获取用户积分明细
   * @param date YYYY-DD
   */
  public getUserPointsRecord(date: string): Promise<UserPointsRecordResp> {
    return request.get(RequestUrlMap.USER_POINTS_DETAIL, { params: { date } })
  }

  /**
   * 更新用户积分
   */
  public updateUserPoints(data: updateUserPointsReq): Promise<BaseResponse> {
    return request.put(RequestUrlMap.USER_POINTS, data);
  }

  /**
   * 获取积分可兑换的商品列表
   */
  public getProductForPoints(): Promise<ProductForPointsResp> {
    return request.get(RequestUrlMap.USER_POINTS_PRODUCT)
  }

  /**
   * 积分兑换商品
   */
  public redeemPointsForProducts(product: UserPointRedemptionSku): Promise<BaseResponse> {
    return request.post(RequestUrlMap.USER_POINTS_REDEMPTION, product)
  }
}

const instance = new UserApis();

export { instance as UserApis };
