import { common, Want } from '@kit.AbilityKit';
import { sceneMap, site } from '@kit.MapKit';
import { shippingAddress } from '@kit.AccountKit';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { Logger } from './Logger';
import { LocationUtil } from './AppStorageV2Util/LocationUtil';
import { promptAction } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

export class SystemUtil {
  static getPoiListByType(pageIndex: number, poiType: string, range?: number) {
    let params: site.NearbySearchParams = {
      // 指定关键字
      query: '',
      // 经纬度坐标
      location: {
        latitude: LocationUtil.getLocationInfo().latitude,
        longitude: LocationUtil.getLocationInfo().longitude,
      },
      // 指定地理位置的范围半径
      radius: 1000,
      // 指定需要展示的poi类别
      poiTypes: [poiType],
      language: 'zh_CN',
      pageSize: 20,
      pageIndex: pageIndex,
    };
    // 返回周边搜索结果
    return site.nearbySearch(params);
  }

  static getPoiListByText(poiText: string, range?: number) {
    let params: site.SearchByTextParams = {
      query: poiText,
      location: {
        latitude: LocationUtil.getLocationInfo().latitude,
        longitude: LocationUtil.getLocationInfo().longitude,
      },
      radius: range,
      language: 'zh_CN',
    };
    return site.searchByText(params);
  }

  static routerToPetalMap(latitude: number, longitude: number, name: string, context: common.UIAbilityContext) {
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        linkSource: 'com.atomicservice.5765880207855657821',
        destinationLatitude: latitude,
        destinationLongitude: longitude,
        destinationName: name
      }
    }
    context.startAbility(petalMapWant);
  }

  static getSystemAddress(context: Context) {
    return new Promise<shippingAddress.AddressInfo>((resolve, reject) => {
      try {
        shippingAddress.chooseAddress(context).then((data: shippingAddress.AddressInfo) => {
          Logger.info('testTag', 'Succeeded in choosing address.');
          resolve(data)
        }).catch((error: BusinessError) => {
          reject(error)
        })
      } catch (error) {
        reject(error)
      }
    })
  }

  static getCascadeInfo(context: common.UIAbilityContext) {
    let district: string = '';
    let districtSelectOptions: sceneMap.DistrictSelectOptions = {
      countryCode: 'CN',
    };

    return new Promise<string>((resolve, reject) => {
      sceneMap.selectDistrict(context, districtSelectOptions).then((data) => {
        Logger.info('SelectDistrict', 'Succeeded in selecting district.');
        for (let i = 1; i < data.districts.length; i++) {
          district += data.districts[i].name;
        }
        resolve(district);
      }).catch((err: BusinessError) => {
        Logger.error('SelectDistrict', `Failed to select district, code: ${err.code}, message: ${err.message}`);
        reject('');
      });
    });
  }

  static triggerForCall(phoneNo: string) {
    call.makeCall(phoneNo, (err) => {
      if (err) {
        Logger.error('make call success');
        promptAction.showToast({ message: '拨打号码失败' });
      } else {
        Logger.info('make call success');
      }
    });
  }

  static doRandBySync(len: number): string {
    let data: string = '';
    let rand = cryptoFramework.createRandom();
    try {
      let randData = rand.generateRandomSync(len);
      if (randData != null) {
        for (let i = 0; i < randData.data.length; i++) {
          data += randData.data[i];
        }
      } else {
        Logger.error('[Sync]: get rand result fail!');
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      Logger.error(`do rand failed, ${e.code}, ${e.message}`);
    }
    return data;
  }

  static copyText(orderNo: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, orderNo);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData);
    systemPasteboard.getData().then((data) => {
      if (data) {
        promptAction.showToast({ message: '复制成功' });
      } else {
        promptAction.showToast({ message: '复制失败' });
      }
    });
  }
}