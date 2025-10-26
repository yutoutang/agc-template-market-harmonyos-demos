import { AddressInfo } from 'add_address';
import { AddressInfo as AddressInfoResp } from 'common';

export const getAddressInfoMapper = (address: AddressInfoResp): AddressInfo => {
  const addressInfo: AddressInfo = new AddressInfo()
  addressInfo.id = address.id
  addressInfo.addressPre = address.addressPre
  addressInfo.addressNum = address.addressNum
  addressInfo.name = address.name
  addressInfo.sex = address.sex
  addressInfo.tel = address.tel
  addressInfo.tag = address.tag
  addressInfo.latitude = address.latitude
  addressInfo.longitude = address.longitude
  return addressInfo;
}

export const getAddressInfoResp = (address: AddressInfo): AddressInfoResp => {
  const addressInfo: AddressInfoResp = new AddressInfoResp()
  addressInfo.id = address.id
  addressInfo.addressPre = address.addressPre
  addressInfo.addressNum = address.addressNum
  addressInfo.name = address.name
  addressInfo.sex = address.sex
  addressInfo.tel = address.tel
  addressInfo.tag = address.tag
  addressInfo.latitude = address.latitude
  addressInfo.longitude = address.longitude
  return addressInfo;
}