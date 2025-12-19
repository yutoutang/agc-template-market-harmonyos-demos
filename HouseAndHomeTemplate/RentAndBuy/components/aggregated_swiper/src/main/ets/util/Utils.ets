import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string, context: Context): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = '';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = context.resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        hilog.info(0xff00, 'CommonUtils', `get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return url;
  };
}