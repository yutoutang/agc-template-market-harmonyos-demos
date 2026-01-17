import { RequestUrlMap } from '../../constants/Enums';
import { UpdateUserInfoReq, UpdateUserPointsReq, UserLoginReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  MembershipInfoResp,
  ProductForPointsResp,
  UserPointRedemptionSku,
  UserPointsRecordResp,
  UserPointsResp,
} from '../../types/responses/UserResponse';
import request from '../Request';

class UserApis {
  /**
   * 用户登录
   */
  public login(params?: UserLoginReq): Promise<BaseResponse> {
    return request.get(RequestUrlMap.USER_LOGIN, { params })
  }

  /**
   * 用户登出
   */
  public logout(): Promise<BaseResponse> {
    return request.get(RequestUrlMap.USER_LOGOUT)
  }

  /**
   * 修改用户信息
   */
  public updateUserInfo(data: UpdateUserInfoReq): Promise<BaseResponse> {
    return request.put(RequestUrlMap.USER_INFO, data)
  }

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
  public updateUserPoints(data: UpdateUserPointsReq): Promise<BaseResponse> {
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

  /**
   * 开通/续费年卡会员
   */
  public subscribeMembership(): Promise<BaseResponse> {
    return request.post(RequestUrlMap.USER_MEMBERSHIP)
  }

  /**
   * 查询会员信息
   */
  public getMembershipInfo(): Promise<MembershipInfoResp> {
    return request.get(RequestUrlMap.USER_MEMBERSHIP)
  }
}

const instance = new UserApis();

export { instance as UserApis };
