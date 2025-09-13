/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { ISubmitOrderRequest, payOrder, preOrder, RouterModule, FullOrderInfo, } from 'lib_foundation';
import { CommonUtils, TypeGood, IJumpAddrParam, GoodInfo, Logger, RouterMap, SystemSceneUtils } from 'module_base';
import { AddrList, AddrViewModel } from 'module_address_manage';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

const TAG = '[OrderVM]';

@ObservedV2
export class OrderVM {
  @Trace addrList: AddrList = AppStorageV2.connect(AddrList, () => new AddrList())!;

  @Monitor('addrList.list')
  onChange(monitor: IMonitor) {
    Logger.info(TAG, `inner.num change from ${monitor.value()?.before} to ${monitor.value()?.now}`);
    const list = monitor.value()?.now as AddrViewModel[];
    const item = list.find(v => v.id === this.addrSelected.id);
    if (item) {
      this.addrSelected = item;
    } else {
      this.addrSelected = new AddrViewModel();
    }
  }

  @Trace goodInfo: GoodInfo = new GoodInfo();
  @Trace addrSelected: AddrViewModel = new AddrViewModel();
  @Trace selectServiceOutIndex: number = 0;
  @Trace selectServiceInsideIndex: number = 0;
  @Trace selectedDateTime: Date | null = null;
  @Trace remark: string = '';
  @Trace showServiceDetail: boolean = true;
  @Trace showTimeSheet: boolean = false;
  private _orderId: string = '';
  scroller: Scroller = new Scroller();
  uiAbilityContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  context?: UIContext;
  // 由于没有商户环境，不能真实调用华为支付api
  ignoreRequestPayment: boolean = true;
  static _instance: OrderVM;

  static instance(isNew?: boolean) {
    if (isNew || !OrderVM._instance) {
      OrderVM._instance = new OrderVM();
      return OrderVM._instance;
    }
    return OrderVM._instance;
  }

  init(context: UIContext) {
    this.context = context;
    const paramList: GoodInfo[] = RouterModule.getNavParam({ url: RouterMap.ORDER_PAGE });
    if (paramList.length && paramList[paramList.length - 1]) {
      this.goodInfo = paramList[paramList.length - 1];
    }
    if (this.addrList.list.length) {
      this.addrSelected = this.addrList.list[0];
    }
  }

  // 是否包含选择服务环节
  showServiceSelect() {
    return Boolean(this.goodInfo.serviceDetailList?.length ?? 0);
  }

  // 是否包含选择上门时间的环节
  showTimeSelect() {
    return this.goodInfo.type === TypeGood.PAY;
  }

  // 是否包含商品信息
  showGoodCard() {
    return !this.goodInfo.serviceDetailList?.length;
  }

  onClickServiceItem(out: number, inside: number) {
    this.selectServiceOutIndex = out;
    this.selectServiceInsideIndex = inside;
  }

  isServiceItemSelected(out: number, inside: number) {
    return this.selectServiceOutIndex === out && this.selectServiceInsideIndex === inside;
  }

  getAddressName() {
    if (this.addrSelected.id) {
      return `${this.addrSelected.name} ${this.addrSelected.address}`;
    }
    return '添加地址';
  }

  jumpAddressManage() {
    const params: IJumpAddrParam = {
      selectedId: this.addrSelected.id,
      needOnPop: true,
    };
    RouterModule.push({
      url: RouterMap.ADDRESS_MANAGE,
      param: params,
      onPop: (info: PopInfo) => {
        const resp = info.result as AddrViewModel;
        this.addrSelected.id = resp.id;
        this.addrSelected.name = resp.name;
        this.addrSelected.address = resp.address;
        this.addrSelected.contactName = resp.contactName;
        this.addrSelected.contactPhone = resp.contactPhone;
      },
    });
  }

  isValid() {
    if (!this.addrSelected.name) {
      this.context?.getPromptAction().showToast({ message: '请填写地址' });
      return false;
    }

    if (!this.selectedDateTime) {
      this.context?.getPromptAction().showToast({ message: '请选择上门时间' });
      return false;
    }

    return true;
  }

  getTimeText() {
    if (!this.selectedDateTime) {
      return '请选择';
    }
    return CommonUtils.formatDateTime(this.selectedDateTime.getTime());
  }

  getTotalCash() {
    try {
      if (!this.goodInfo?.serviceDetailList?.length) {
        return this.goodInfo.vipPrice?.toString();
      }
      const serviceItem =
        this.goodInfo.serviceDetailList[this.selectServiceOutIndex].prices[this.selectServiceInsideIndex];
      if (serviceItem) {
        return CommonUtils.handleCash(serviceItem.count * serviceItem.price * (serviceItem.extraCount ?? 1));
      }
      return CommonUtils.handleCash(this.goodInfo.vipPrice);
    } catch (e) {
      Logger.error(TAG, 'getTotalCash fail, error: ' + JSON.stringify(e));
      return CommonUtils.handleCash(this.goodInfo.vipPrice);
    }
  }

  buildSubmitParam() {
    const selectedDateTime = this.selectedDateTime;
    const param: ISubmitOrderRequest = {
      goodId: this.goodInfo.id,
      addressName: this.addrSelected.name,
      addressStr: this.addrSelected.address,
      contactName: this.addrSelected.contactName,
      contactPhone: this.addrSelected.contactPhone,
      selectServiceId: this.selectServiceOutIndex + this.selectServiceInsideIndex,
      appointTime: selectedDateTime?.getTime() || 0,
      remark: this.remark,
      actualPay: Number(this.getTotalCash()),
    };
    return param;
  }

  buildJumpParam() {
    const selectedDateTime = this.selectedDateTime;
    const orderInfo: FullOrderInfo = new FullOrderInfo();
    orderInfo.id = this.goodInfo.id;
    orderInfo.title = this.goodInfo.title;
    orderInfo.subTitle = this.goodInfo.subTitle;
    orderInfo.vipPrice = this.goodInfo.vipPrice;
    orderInfo.image = this.goodInfo.image;
    orderInfo.addressName = this.addrSelected.name;
    orderInfo.appointTime = selectedDateTime?.getTime() || 0;
    orderInfo.remark = this.remark;
    orderInfo.actualPay = Number(this.getTotalCash());
    return orderInfo;
  }

  // 提交订单
  onSubmit() {
    if (!this.isValid()) {
      return;
    }
    CommonUtils.showLoading();
    const param = this.buildSubmitParam();
    const jumpParam = this.buildJumpParam();
    preOrder(param).then((resp) => {
      this._orderId = resp;
      CommonUtils.hideLoading();
      RouterModule.push({ url: RouterMap.TO_PAY, param: jumpParam });
    });
  }

  // 付款
  payOrder() {
    CommonUtils.showLoading();
    const jumpParam = this.buildJumpParam();
    // todo: 传入false，不走mock
    SystemSceneUtils.requestPaymentPromise(true, this.uiAbilityContext).then(() => {
      payOrder(this._orderId).then(() => {
        CommonUtils.hideLoading();
        RouterModule.push({ url: RouterMap.SUCCESS_PAY, param: jumpParam });
      })
    })
  }
}