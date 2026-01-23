import bundleManager from '@ohos.bundle.bundleManager';
import { SafeJson } from '../json/SafeJson';

/**
 * @description 获取应用包信息
 */
export class BundleInfoUtil {
  public static async getBundleInfo(): Promise<bundleManager.BundleInfo> {
    return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  }

  public static getBundleInfoSync(): bundleManager.BundleInfo {
    return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
  }
}