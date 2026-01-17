import { bundleManager, common, Want } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  /**
   * 跳转到华为地图
   * @param address
   * @param coords
   */
  public static async jumpPetalMap(context: common.UIAbilityContext, address: string, coords: string[]) {
    if (coords.length < 2) {
      return;
    }
    const bundleInfo = SystemSceneUtils.getBundleInfo();
    if (!bundleInfo) {
      return
    }
    let petalMapWant: Want = {
      bundleName: 'com.huawei.hmos.maps.app',
      uri: 'maps://routes',
      parameters: {
        // 接入方业务名或包名，Link请求来源
        linkSource: bundleInfo.name,
        // 终点纬度
        destinationLatitude: coords[1],
        // 终点经度
        destinationLongitude: coords[0],
        // 终点名称
        destinationName: address,
      },
    }

    context?.startAbility(petalMapWant);
  }
  /**
   * 获取包信息
   * @returns
   */
  public static getBundleInfo() {
    let bundleInfo: bundleManager.BundleInfo | null = null;
    try {
      bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
    } catch (err) {
      UtilLog.error('[SystemSceneUtils]', `getBundleInfo failed. error: ${JSON.stringify(err)}`);
    }
    return bundleInfo;
  }
}