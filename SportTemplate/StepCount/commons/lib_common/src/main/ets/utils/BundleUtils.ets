import { bundleManager } from '@kit.AbilityKit';
import { BundleInfo } from '../models/BundleInfo';
import { Logger } from './Logger';

export class BundleUtils {
  public static async getBundleInfo() {
    try {
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appName = getContext().resourceManager.getStringSync(bundleInfo.appInfo.labelId);
      let appVersionName = bundleInfo.versionName;
      let appInfo: BundleInfo = {
        appName,
        appVersionName
      }
      AppStorage.setOrCreate('appInfo', appInfo)
    } catch (error) {
      Logger.error('BundleUtils', 'getBundleInfo error: ', JSON.stringify(error))
    }
  }
}