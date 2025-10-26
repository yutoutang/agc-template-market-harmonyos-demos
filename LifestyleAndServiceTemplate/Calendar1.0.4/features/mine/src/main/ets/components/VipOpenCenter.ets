import { EMITTER_TYPE, UserState } from 'common';
import { VipCenter, VipPackageItem } from 'vip_center';
import { PersistenceV2, promptAction } from '@kit.ArkUI';
import { RouterModule } from 'router_module';
import { emitter } from '@kit.BasicServicesKit';
import { baseActionSheet } from 'base_apis';

@Builder
export function VipOpenCenterBuilder() {
  VipOpenCenter()
}

@ComponentV2
export struct VipOpenCenter {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local packageInfo: VipPackageItem = {
    title: '连续包月',
    amount: 29,
    duration: 'month',
    amountDes: '每天仅需0.8元',
  }

  aboutToAppear(): void {
    let innerEvent: emitter.InnerEvent = {
      eventId: EMITTER_TYPE.WX_PAY,
    };

    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      promptAction.showToast({ message: '开通成功' })
      this.userState.userInfo.vipInfo.isVip = true
      this.userState.userInfo.vipInfo.vipType = 'month'
      baseActionSheet.close('VipOpen')
    }
    emitter.on(innerEvent, callback);
  }

  aboutToDisappear(): void {
    emitter.off(EMITTER_TYPE.WX_PAY)
  }

  build() {
    NavDestination() {
      VipCenter({
        userName: this.userState.userInfo.userName as string,
        avatar: this.userState.userInfo.avatar,
        isVip: this.userState.userInfo.vipInfo.isVip,
        vipType: this.userState.userInfo.vipInfo.vipType,
        routerModule: RouterModule.getStack(),
        packageChange: (vipPackage: VipPackageItem) => {
          this.packageInfo = vipPackage
        },
        onVipOpen: () => {
          this.userState.userInfo.vipInfo.isVip = true
          this.userState.userInfo.vipInfo.vipType = this.packageInfo.duration
        },
      })
    }
    .hideTitleBar(true)
  }
}