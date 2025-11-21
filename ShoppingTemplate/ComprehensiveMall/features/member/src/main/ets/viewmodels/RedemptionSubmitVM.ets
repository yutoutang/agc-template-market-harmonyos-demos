import { routerStack, WindowUtil } from 'lib_foundation';
import { UserApis, UserPointRedemptionSku } from 'lib_network';
import { getDefaultAddress } from 'module_address_manage';

@ObservedV2
export class RedemptionSubmitVM {
  @Trace
  customerAddress: string = '';
  @Trace
  customerName: string = '请填写收件人信息';
  @Trace
  customerPhone: string = '';
  @Trace
  product: UserPointRedemptionSku | undefined

  @Computed
  get displayAddress() {
    return this.customerAddress ? this.customerAddress : '';
  }

  @Computed
  get displayCustomerInfo() {
    if (!this.customerName && !this.customerPhone) {
      return '请填写收件人信息'
    }
    return this.customerName + ' ' + this.customerPhone;
  }

  init() {
    getDefaultAddress().then((res) => {
      if (res) {
        this.customerName = res.name;
        this.customerPhone = res.phone;
        this.customerAddress =
          res.province + res.city + res.district + res.street + res.detail;
      }
    });
  }

  async onSubmit() {
    if (!this.product) {
      return;
    }
    if (!this.customerAddress || !this.customerName || !this.customerPhone) {
      WindowUtil.toast('请填写正确的收件信息');
      return;
    }
    const res = await UserApis.redeemPointsForProducts(this.product)
    if (res.code === 0) {
      WindowUtil.toast('兑换成功！')
      routerStack.pop(1)
    }
  }
}