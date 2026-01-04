import { shippingAddress } from '@kit.AccountKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { geoLocationManager } from '@kit.LocationKit';
import { util } from '@kit.ArkTS';
import { IAddrInfo } from '../database/IAddrType';
import { Logger } from 'module_ui_base';

const TAG = 'module_address_manage'

/**
 * 通用Utils
 */
export class AddressUtils {
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  public static async chooseAddress(): Promise<IAddrInfo | null> {
    try {
      const data: shippingAddress.AddressInfo = await shippingAddress.chooseAddress(getContext())
      if (data) {
        const address: IAddrInfo = {
          id: 0,
          name: data.userName,
          cellphone: data.mobileNumber,
          province: data.provinceName,
          city: data.cityName,
          area: data.districtName,
          detailAddress: data.streetName + data.detailedAddress,
          isDefault: false
        }
        return address
      }
      return null
    } catch (error) {
      AddressUtils._dealAllError(error);
    }
    return null
  }

  private static _dealAllError(error: BusinessError): void {
    Logger.error(TAG, `Failed to login, errorCode: ${error.code}, errorMsg: ${error.message}`);
  }

  /**
   * 号码中间四位隐藏
   * @param phoneNo
   * @returns
   */
  public static encryptPhoneNo(phoneNo: string): string {
    if (phoneNo && phoneNo.length === 11) {
      const str = phoneNo.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2')
      return str
    }
    return phoneNo
  }

  /**
   * 根据地址获取经纬度
   * @param position
   * @returns
   */
  public static async getAddressesFromLocationName(position: string) {
    let geocodeRequest: geoLocationManager.GeoCodeRequest = { 'description': position, 'maxItems': 1 };
    let data: geoLocationManager.GeoAddress[] = []
    try {
      data = await geoLocationManager.getAddressesFromLocationName(geocodeRequest);
    } catch (err) {
      Logger.error('errCode:' + err.code + ', message:' + err.message);
    }
    return data
  }

  public static uint8ArrayToString(array: Uint8Array) {
    let textDecoderOptions: util.TextDecoderOptions = {
      fatal: false,
      ignoreBOM: true
    }
    let decodeToStringOptions: util.DecodeToStringOptions = {
      stream: false
    }
    let textDecoder = util.TextDecoder.create('utf-8', textDecoderOptions);
    let retStr = textDecoder.decodeToString(array, decodeToStringOptions);
    return retStr;
  }
}