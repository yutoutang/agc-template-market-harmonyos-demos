import { PersistenceV2 } from '@kit.ArkUI';
import { CouponItem } from '../params/response/GetCouponsResp';
import { MockCouponItem } from './mockdata/MockCouponItem';
import { UserInfoModel } from 'lib_common';
import { StoreEnum } from '../constants/Constants';

/**
 * 优惠券类
 */
export class CouponsService {
  /**
   * 查询数据库字段
   * @returns
   */
  public getAll(): CouponItem[] {
    return [...MockCouponItem.list, ...MockCouponItem.toBeClaimedList].filter(v => v.receiveStatus === '1');
  }

  public getMyCoupons(): CouponItem[] {
    let userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
    return [...MockCouponItem.list, ...MockCouponItem.toBeClaimedList].filter(v => v.receiveStatus === '1')
      .filter(v => !userInfoModel.usedCouponList.includes(v.couponID));
  }

  public getByTypeAndReceiveStatus(categoryGroup: StoreEnum): CouponItem[] {
    return [...MockCouponItem.list, ...MockCouponItem.toBeClaimedList].filter(v => v.categoryGroup === categoryGroup)
      .filter(v => v.receiveStatus === '1');
  }

  public getCanUseCoupons(categoryGroup: StoreEnum): CouponItem[] {
    let userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
    return [...MockCouponItem.list, ...MockCouponItem.toBeClaimedList].filter(v => v.categoryGroup === categoryGroup ||
      v.categoryGroup === StoreEnum.ALL)
      .filter(v => v.receiveStatus === '1')
      .filter(v => !userInfoModel.usedCouponList.includes(v.couponID));
  }

  public useCoupons(couponId: string) {
    let userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
    userInfoModel.usedCouponList.push(couponId)
  }

  public getByStoreType(categoryGroup: StoreEnum): CouponItem[] {
    return MockCouponItem.toBeClaimedList.filter(v => v.categoryGroup === categoryGroup);
  }
}

const instance = new CouponsService();

export { instance as CouponsServiceApi };