import { bundleManager } from '@kit.AbilityKit';

export class AppUtil {
  /**
   * 获取应用包的名称。
   */
  static getBundleName(): string {
    return AppUtil.getBundleInfoSync().name;
  }

  /**
   * 获取应用版本号。
   */
  static getVersionCode(): number {
    return AppUtil.getBundleInfoSync().versionCode;
  }

  /**
   * 获取应用版本名。
   */
  static getVersionName(): string {
    return AppUtil.getBundleInfoSync().versionName;
  }

  /**
   * 获取运行应用包所需要最高SDK版本号。
   */
  static getTargetVersion(): number {
    return AppUtil.getBundleInfoSync().targetVersion;
  }

  /**
   * 获取应用程序的配置信息
   * @returns
   */
  static getAppInfoSync(): bundleManager.ApplicationInfo {
    return AppUtil.getBundleInfoSync().appInfo;
  }

  /**
   * 获取当前应用的BundleInfo
   */
  static getBundleInfoSync(): bundleManager.BundleInfo {
    return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  }

}