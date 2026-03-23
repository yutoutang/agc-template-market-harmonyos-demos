import { abilityAccessCtrl, PermissionRequestResult } from '@kit.AbilityKit';
import { identifier } from '@kit.AdsKit';

const TAG = '[OaidUtils]';

export async function requestOAID(context: Context): Promise<string | undefined> {
  // 向用户请求授权广告跨应用关联访问权限
  let isPermissionGranted: boolean = false;
  try {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const result: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
    isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  } catch (err) {
    console.info(TAG, `Failed to request permission. Code is ${err.code}, message is ${err.message}`);
  }
  if (isPermissionGranted) {
    console.info(TAG, 'Succeeded in requesting permission');
    try {
      const oaid = await identifier.getOAID();
      console.info(TAG, 'Succeeded in getting OAID');
      return oaid;
    } catch (err) {
      console.info(TAG, `Failed to get OAID. Code is ${err.code}, message is ${err.message}`);
    }
  } else {
    console.info(TAG, 'Failed to request permission. User rejected');
  }
  return undefined;
}
