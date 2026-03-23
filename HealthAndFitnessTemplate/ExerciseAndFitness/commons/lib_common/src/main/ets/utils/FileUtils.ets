import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { storageStatistics } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

const TAG = '[FileUtils]';

/**
 * 文件处理类
 */
export class FileUtils {
  /**
   * 写入沙箱
   * @param uri
   * @returns
   */
  static handleUri(context: common.UIAbilityContext, uri: string) {
    if (!uri) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const newPath: string = context.filesDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath;
    } catch (error) {
      Logger.error(TAG, 'fs.copyFileSync error: ' + JSON.stringify(error));
      return '';
    } finally {
      if (file) {
        fs.closeSync(file);
      }
    }
  }

  /**
   * 读取缓存大小，单位Byte
   */
  static async getCache() {
    try {
      let bundleStats = await storageStatistics.getCurrentBundleStats()
      Logger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
      Logger.info(TAG, 'appSize :' + bundleStats.appSize);
      Logger.info(TAG, 'cacheSize :' + bundleStats.cacheSize);
      Logger.info(TAG, 'dataSize :' + bundleStats.dataSize);
      return bundleStats.cacheSize;
    } catch (e) {
      console.error(`Failed to get current bundle stats. error: ${JSON.stringify(e)}`)
      return 0
    }
  }

  /**
   * 清除缓存
   * @param cacheDir
   */
  static clearCache(context: common.UIAbilityContext) {
    const cacheDir = context.cacheDir;
    Logger.info(TAG, 'clear cache dir:' + cacheDir);
    fs.listFile(cacheDir).then((filenames) => {
      for (let i = 0; i < filenames.length; i++) {
        let dirPath = cacheDir + '/' + filenames[i];
        Logger.info(TAG, 'dir path:' + dirPath);
        let isDirectory: boolean = false;
        try {
          isDirectory = fs.statSync(dirPath).isDirectory();
        } catch (e) {
          Logger.error(TAG, 'statSync error:' + JSON.stringify(e));
        }

        if (isDirectory) {
          fs.rmdirSync(dirPath);
        } else {
          fs.unlink(dirPath).then(() => {
            Logger.info(TAG, 'remove file succeed');
          }).catch((err: Error) => {
            Logger.error(TAG, 'remove file failed with error message: ' + err.message);
          });
        }
      }
    })
  }
}