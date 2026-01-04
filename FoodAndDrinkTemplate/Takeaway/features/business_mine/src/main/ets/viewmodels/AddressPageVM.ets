import { promptAction } from '@kit.ArkUI';
import { BaseViewModel } from 'lib_common';
import { AddressUtils, AddrMgtApi } from 'lib_takeaway_api';
import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';

@ObservedV2
export class AddressPageVM extends BaseViewModel {
  private static _instance: AddressPageVM;
  stack: NavPathStack = new NavPathStack();
  @Trace list: IAddrInfo[] = [];
  @Trace selectedAddress: IAddrInfo | undefined

  public static get instance() {
    if (!AddressPageVM._instance) {
      AddressPageVM._instance = new AddressPageVM();
    }
    return AddressPageVM._instance;
  }

  init() {
    this.queryList()
  }

  setStack(stack: NavPathStack) {
    this.stack = stack;
  }

  async queryList() {
    this.list = AddrMgtApi.ADDRESS_LIST
  }

  public async modifyAddress() {
    if (!this.selectedAddress) {
      return
    }
    this.queryList()
    promptAction.showToast({ message: '修改成功！', alignment: Alignment.Center, duration: 2000 });
  }

  async deleteAddr() {
    const targetIndex = AddrMgtApi.ADDRESS_LIST.findIndex(v => v.id === this.selectedAddress?.id);
    if (targetIndex !== -1) {
      AddrMgtApi.ADDRESS_LIST.splice(targetIndex, 1);
    }
    this.queryList();
  }

  update(data: IAddrInfo) {
    const target = AddrMgtApi.ADDRESS_LIST.find(v => v.id === data.id);
    if (target) {
      AddressUtils.assign(target, data);
      this.userInfoModel.defaultAddress = target.id;
    }
    this.queryList();
    promptAction.showToast({ message: '修改成功！' })
  }
}
