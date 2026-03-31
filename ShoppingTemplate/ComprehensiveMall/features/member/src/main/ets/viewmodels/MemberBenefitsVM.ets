import { BreakpointSystem, BreakpointTypeEnum, WindowUtil } from 'lib_foundation';
import { UpdateUserPointsReq, UserApis, UserPointRedemptionSku, UserPoints } from 'lib_network';
import { UserPointsUsedType } from '../commons/Enums';

@ObservedV2
export class MemberBenefitsVM {
  @Trace
  userPoints: UserPoints | undefined;
  @Trace
  productList: UserPointRedemptionSku[] = [];

  @Computed
  get isCheckedToday() {
    if (this.userPoints) {
      return new Date(this.userPoints.latestCheck).toDateString() === new Date().toDateString();
    }
    return false;
  }

  @Computed
  get columnTemplate() {
    const map: Map<BreakpointTypeEnum, string> = new Map([
      [BreakpointTypeEnum.SM, '1fr 1fr'],
      [BreakpointTypeEnum.MD, '1fr 1fr 1fr'],
      [BreakpointTypeEnum.LG, '1fr 1fr 1fr 1fr'],
    ]);
    return map.get(BreakpointSystem.currentBreakpoint.value);
  }

  public async getUserPoints() {
    const res = await UserApis.getUserPoints();
    if (res.code === 0) {
      this.userPoints = res.data;
    }
  }

  public async getProductList() {
    const res = await UserApis.getProductForPoints();
    if (res.code === 0) {
      this.productList = res.list;
    }
  }

  public async handleCheckIn() {
    if (this.isCheckedToday) {
      return;
    }
    if (this.userPoints) {
      const newPoints = this.userPoints.pointsArr[this.userPoints.checkedDays];
      const data: UpdateUserPointsReq = {
        type: UserPointsUsedType.INCOME,
        newPoints,
        label: '签到',
      };
      UserApis.updateUserPoints(data).then((res) => {
        if (res.code === 0) {
          WindowUtil.toast('签到成功！');
          this.getUserPoints();
        }
      });
    }
  }

  public isProductValid(points: number) {
    if (!this.userPoints) {
      return false;
    }
    return this.userPoints.totalPoints >= points;
  }
}