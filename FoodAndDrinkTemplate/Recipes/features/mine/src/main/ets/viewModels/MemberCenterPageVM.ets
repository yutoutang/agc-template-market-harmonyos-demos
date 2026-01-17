import { getMemberPackages, MemberPackage } from 'network';

@ObservedV2
export class MemberCenterPageVM {
  @Trace memberPackages: MemberPackage[] = [];
  @Trace selectId: number = 0;
  @Trace selectCheckbox: boolean = false;
  @Trace isShow: boolean = false;
  appId: string = '';
  @Trace aliOrderStr: string = '';
  hwOrderStr: string = '';
  @Trace lastPurchaseProductExpireTime: string = '';



  getMemberPackages() {
    getMemberPackages().then(res => {
      if (res.status === 200) {
        this.memberPackages = res.data
        if (res.data.length) {
          this.selectId = res.data[0].id
        }
      }
    })
  }
}
