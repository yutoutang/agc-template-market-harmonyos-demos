import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { paymentService } from '@kit.PaymentKit';
import { Logger, UserInfo } from 'module_base';
import { IVipPrepayRequest, vipPrepay } from 'lib_foundation';
import { vipList } from '../constants';

@ObservedV2
export class PurchasePageVM {
  private static _instance: PurchasePageVM;
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @Trace currentIndex: number = 0
  @Trace isSign: boolean = false
  @Trace public isLogin: boolean = false
  @Trace userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('userInfo.id')
  onChange(monitor: IMonitor) {
    const id = monitor.value()?.now as number;
    this.checkLogin(id)
  }

  // 初始化
  init() {
    this.checkLogin(this.userInfo.id)
  }

  checkLogin(id: number) {
    if (id === 0) {
      this.isLogin = false
    } else {
      this.isLogin = true
    }
  }

  public static get instance() {
    if (!PurchasePageVM._instance) {
      PurchasePageVM._instance = new PurchasePageVM();
    }
    return PurchasePageVM._instance;
  }

  public async prepay() {
    if (!this.isSign) {
      promptAction.showToast({ message: '请签署协议', alignment: Alignment.Center })
      return
    }
    const data: IVipPrepayRequest = {
      id: vipList[this.currentIndex].id,
      userId: this.userInfo?.id as number,
      price: vipList[this.currentIndex].discountPrice
    }
    const res = await vipPrepay(data);
    paymentService
      .requestPayment(this.context, res.orderStr)
      .then(() => {
        Logger.info('succeeded in paying');
      })
      .catch((error: BusinessError) => {
        promptAction.showToast({ message: '支付失败！' });
        Logger.error(`failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
      });
  }
}
