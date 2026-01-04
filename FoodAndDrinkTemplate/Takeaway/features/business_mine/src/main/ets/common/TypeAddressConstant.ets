import { IAddrInfo } from 'lib_takeaway_api/src/main/ets/database/IAddrType';

export enum TypeAddressPage {
  NEW = 1,
  EDIT = 2,
}

export interface ParamAddressPage {
  type: TypeAddressPage;
  param?: IAddrInfo;
}
