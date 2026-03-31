import { BaseViewModel, BreakpointType, RouterMap, RouterUtils } from 'lib_common';
import { MineGridItem } from '../types/Types';

@ObservedV2
export class MineViewModel extends BaseViewModel {
  jumpLogin() {
    RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE);
  }

  jumpVIP() {
    RouterUtils.pushPathByName(RouterMap.VIP_PAGE);
  }

  jumpRecord() {
    RouterUtils.pushPathByName(RouterMap.RECORD_PAGE);
  }

  gridClick(v: MineGridItem) {
    RouterUtils.pushPathByName(v.routerName);
  }

  isVIP() {
    this.userInfoModel.isVIP = true
  }

  isNotVIP() {
    this.userInfoModel.isVIP = false
  }

  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 6,
    xl: 6,
  });

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
  }

  @Computed get pagePaddingBottom() {
    if (this.tabModel.isTabVertical) {
      return this.windowModel.windowBottomPadding;
    }
    return 0;
  }

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }
}