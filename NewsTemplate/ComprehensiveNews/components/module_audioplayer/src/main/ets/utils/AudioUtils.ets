import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[AudioUtils]';

export class AudioUtils {
  /**
   * 获取本地封面图片的PixelMap
   * @param context - 上下文
   * @return name - 资源名称
   */
  static async getPixelMapFromResource(context: common.UIAbilityContext,
    name: resourceManager.Resource): Promise<PixelMap | null> {
    let fileData: Uint8Array = new Uint8Array([]);
    try {
      let resourceMgr = context.resourceManager;
      fileData = await resourceMgr.getMediaContent(name.id);
      return await image.createImageSource(fileData.buffer as ArrayBuffer).createPixelMap();
    } catch (e) {
      UtilLog.error(TAG, `getPixelMapFromResource error: ${JSON.stringify(e)}`);
      return null;
    }
  }

  static async getPixelMapFromFile(id: string, path: string): Promise<image.PixelMap | null> {
    UtilLog.info(TAG, 'getPixelMapFromFile id:' + id + ', path:' + path);
    try {
      return await image.createImageSource(path).createPixelMap();
    } catch (e) {
      UtilLog.error(TAG, ` fail. Code: ${e.code}, message: ${e.message}`);
      return null;
    }
  }

  /**
   * 日期不足两位补 0
   * @param {string} value - 数据值
   * @return {string} - 日期不足两位补 0
   */
  private static fill(value: number): string {
    return value.toString().padStart(2, '0');
  }

  /**
   * 格式化时间为 00:00:00 格式
   * @param ms - 数据值
   * @return 00:00:00格式数据值
   */
  static msToCountdownTime(ms: number): string {
    if (!ms) {
      return '00:00';
    }
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((ms % (1000 * 60)) / 1000);
    return `${(days ? AudioUtils.fill(days) + ':' : '')}${(hours ? AudioUtils.fill(hours) + ':' : '')}
      ${AudioUtils.fill(minutes)}:${AudioUtils.fill(seconds)} `.trim();
  }
}