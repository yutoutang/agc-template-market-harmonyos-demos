import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { Logger } from './Logger';
import { storageStatistics } from '@kit.CoreFileKit';
import { CommonConfirmDialog } from '../dialogs/CommonConfirmDialog';

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
  static handleUri(uri: string) {
    if (!uri) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const newPath: string = getContext().filesDir + `/${util.generateRandomUUID(false)}.png`;
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
  static getCache() {
    return storageStatistics.getCurrentBundleStats().then((bundleStats: storageStatistics.BundleStats) => {
      Logger.info(TAG, 'getCurrentBundleStats successfully:' + JSON.stringify(bundleStats));
      Logger.info(TAG, 'appSize :' + bundleStats.appSize);
      Logger.info(TAG, 'cacheSize :' + bundleStats.cacheSize);
      Logger.info(TAG, 'dataSize :' + bundleStats.dataSize);
      return bundleStats.cacheSize;
    });
  }

  /**
   * 清除缓存
   * @param cacheDir
   */
  static clearCache() {
    // 假设你有一个全局的弹窗方法，例如 AlertDialog
    // 这里展示的是概念性代码，具体实现依赖于你的 UI 框架
    CommonConfirmDialog.show({
      primaryTitle: '清理缓存',
      content: '您确定要清除缓存吗？(该操作不会删除已缓的视频）',
      secBtnV: '确认',
      secBtnFg: $r('sys.color.warning'),
      confirm: () => {
        // 用户点击确认后执行清理逻辑
        // 1. 清理下载任务
        const cacheDir = getContext().cacheDir;
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
      },
      cancel: () => {
        // 用户点击取消，不执行任何操作
        Logger.info(TAG, 'User cancelled cache clearing');
      }
    });
  }
}