import { IAddrInfo } from '../database/IAddrType';
import { AddressUtils } from '../utils/AddressUtils';

export class AddrMgtApi {
  static ADDRESS_LIST: IAddrInfo[] = [
    {
      id: 1,
      name: '用户1',
      cellphone: '177******64',
      province: '江苏省',
      city: '南京市',
      area: '雨花台区',
      detailAddress: '德融科创中心',
      isDefault: true
    },
    {
      id: 2,
      name: '用户2',
      cellphone: '177******64',
      province: '广东省',
      city: '广州市',
      area: '越秀区',
      detailAddress: 'xx街道xxx小区',
      isDefault: false
    },
    {
      id: 3,
      name: '用户3',
      cellphone: '177******64',
      province: '浙江省',
      city: '杭州市',
      area: '萧山区',
      detailAddress: 'xx街道xxx小区',
      isDefault: false
    },
    {
      id: 4,
      name: '用户4',
      cellphone: '177******64',
      province: '江苏省',
      city: '南京市',
      area: '雨花台区',
      detailAddress: 'xx街道xxx小区',
      isDefault: false
    },
    {
      id: 5,
      name: '用户5',
      cellphone: '177******64',
      province: '江苏省',
      city: '南京市',
      area: '雨花台区',
      detailAddress: 'xx街道xxx小区',
      isDefault: false
    }
  ];

  static getAddressList(): Promise<IAddrInfo[]> {
    return Promise.resolve(AddrMgtApi.ADDRESS_LIST);
  }

  static getAddressMock(): IAddrInfo {
    let res: IAddrInfo = {
      id: 1,
      name: '用户1',
      cellphone: '177******64',
      province: '江苏省',
      city: '南京市',
      area: '雨花台区',
      detailAddress: '德融科创中心',
      isDefault: true
    }
    return res;
  }

  static getAddress(addrId: number): Promise<IAddrInfo | undefined> {
    return Promise.resolve(AddrMgtApi.ADDRESS_LIST.find(v => v.id === addrId));
  }

  static defaultAddress(): IAddrInfo | undefined {
    return AddrMgtApi.ADDRESS_LIST.find(v => v.isDefault);
  }

  static updateAddress(data: IAddrInfo): Promise<boolean> {
    const target = AddrMgtApi.ADDRESS_LIST.find(v => v.id === data.id);
    if (target) {
      AddressUtils.assign(target, data);
    }
    return Promise.resolve(true);
  }

  static deleteAddress(id: number): Promise<boolean> {
    const targetIndex = AddrMgtApi.ADDRESS_LIST.findIndex(v => v.id === id);
    if (targetIndex !== -1) {
      AddrMgtApi.ADDRESS_LIST.splice(targetIndex, 1);
    }
    return Promise.resolve(true);
  }

  static addAddress(data: IAddrInfo): Promise<boolean> {
    data.id = new Date().getTime();
    AddrMgtApi.ADDRESS_LIST.splice(0, 0, data);
    return Promise.resolve(true);
  }
}
