import { bundleManager } from '@kit.AbilityKit';
import { BundleInfo } from '../models/BundleInfo';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class BundleUtils {
  public static async getBundleInfo() {
    try {
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appName = getContext().resourceManager.getStringSync(bundleInfo.appInfo.labelId);
      let appVersionName = bundleInfo.versionName;
      let appInfo: BundleInfo = {
        appName,
        appVersionName,
      }
      AppStorage.setOrCreate('appInfo', appInfo)
    } catch (error) {
      hilog.error(0x0001, 'BundleUtils', `Face verification start error: ${error.message}`);
    }
  }
}