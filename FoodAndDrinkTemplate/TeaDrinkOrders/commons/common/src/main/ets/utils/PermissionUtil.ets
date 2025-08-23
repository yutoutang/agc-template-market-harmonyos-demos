import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { Constants } from '../constants/Common';
import { BusinessError } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { promptAction } from '@kit.ArkUI';

class PermissionUtil {
  private static instance?: PermissionUtil

  private constructor() {
  }

  static getInstance(): PermissionUtil {
    if (!PermissionUtil.instance) {
      PermissionUtil.instance = new PermissionUtil()
    }
    return PermissionUtil.instance
  }

  initPermission(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(getContext() as common.UIAbilityContext,
        ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'])
        .then((data) => {
          let grantStatus: Array<number> = data.authResults;
          let hasMapPermission = grantStatus.every(item => item === Constants.USER_GRANT_SUCCESS)
          resolve(hasMapPermission)
        }).catch((err: BusinessError) => {
        reject(err.message)
        console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
      });
    })
  }

  async getLocation(): Promise<geoLocationManager.Location> {
    return new Promise(async (resolve, reject) => {
      if (!await this.initPermission()) {
        promptAction.showToast({ message: $r('app.string.permission_failed') })
        reject()
        return
      }
      let locationChange = (err: BusinessError, location: geoLocationManager.Location) => {
        if (err) {
          console.error('getCurrentLocation failed', 'getCurrentLocation error: ' + JSON.stringify(err));
          reject(err)
        }
        if (location) {
          resolve(location);
        }
      };
      try {
        geoLocationManager.getCurrentLocation(locationChange);
      } catch (err) {
        if (err.code === '3301100') {
          promptAction.showToast({ message: '检测到您尚未打开位置开关，请到设置里打开“访问我的位置”。', duration: 3000 })
        }
        console.error('errCode:' + err.code + ', message:' + err.message);
      }
    })
  }
}

export const permissionUtil = PermissionUtil.getInstance()