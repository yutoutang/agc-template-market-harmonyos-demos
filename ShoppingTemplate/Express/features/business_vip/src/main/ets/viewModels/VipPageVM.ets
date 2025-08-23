import { AppStorageV2 } from '@kit.ArkUI';
import { CheckIn, Coupon, getCheckInList, getCouponList } from 'lib_foundation';
import { UserInfo } from 'module_base'

@ObservedV2
export class VipPageVM {
  private static _instance: VipPageVM;
  @Trace public isLogin: boolean = false
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('userInfo.id')
  onChange(monitor: IMonitor) {
    const id = monitor.value()?.now as number;
    this.checkLogin(id)
  }

  @Trace public checkInList: CheckIn[] = []
  @Trace public couponList: Coupon[] = []
  @Trace public isSign: boolean = false
  @Trace public signInCount: number = 0
  @Trace public currentIndex: number = 0

  static get instance() {
    if (!VipPageVM._instance) {
      VipPageVM._instance = new VipPageVM();
    }
    return VipPageVM._instance;
  }

  // 初始化
  async init() {
    this.checkLogin(this.userInfo.id)
    this.getCheckInList()
    this.getCouponList()
  }

  checkLogin(id: number) {
    if (id === 0) {
      this.isLogin = false
    } else {
      this.isLogin = true
    }
  }

  async getCouponList() {
    const res = await getCouponList()
    this.couponList = res
  }

  async getCheckInList() {
    const res = await getCheckInList()
    this.checkInList = res
    this.checkInList.forEach((item) => {
      if (item.isChecked) {
        this.signInCount += 1
      }
    })
    this.isSign = this.checkInList[this.currentIndex].isChecked
  }
}
