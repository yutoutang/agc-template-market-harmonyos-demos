import { util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContextUtils } from './ContextUtils';
import { Logger } from './Logger';

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
      const newPath: string = GlobalContextUtils.globalContext.cacheDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(file.fd, newPath);
      return 'file://' + newPath;
    } catch (error) {
      Logger.error(TAG, 'fs.copyFileSync error: ' + JSON.stringify(error));
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        Logger.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }

  /**
   * 沙箱图片转换成base64
   * @param imgUri
   * @returns
   */
  static sandboxToBase64(imgUri: string): string {
    let file: fs.File | null = null;
    try {
      file = fs.openSync(imgUri);
      let buffer: ArrayBuffer = new ArrayBuffer(fs.statSync(file.fd).size);
      fs.readSync(file.fd, buffer);
      let unit = new Uint8Array(buffer);
      let base64 = new util.Base64Helper();
      let base64string = base64.encodeToStringSync(unit, util.Type.MIME);
      return `data:image/jpeg;base64,${base64string}`;
    } catch (e) {
      Logger.error(TAG, 'sandboxToBase64 fail, error: ' + JSON.stringify(e));
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        Logger.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }

  /**
   * 下载图片
   * @param url
   * @returns
   */
  static downloadImage(url: string): Promise<ArrayBuffer> {
    return new Promise((resolve, reject) => {
      http.createHttp()
        .request(url, { method: http.RequestMethod.GET })
        .then((data: http.HttpResponse) => {
          if (http.ResponseCode.OK === data.responseCode) {
            const buffer: ArrayBuffer = data.result as ArrayBuffer;
            resolve(buffer);
          } else {
            Logger.error(TAG, `downloadImage fail, url: ${url}, responseCode: ${data.responseCode}`);
            reject();
          }
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, `downloadImage fail, url: ${url}, err: ${JSON.stringify(err)}`);
          reject();
        })
    })
  }

  /**
   * 写入buffer到沙箱地址
   * @param buffer
   * @returns
   */
  static saveBufferToSandbox(buffer: ArrayBuffer): string {
    let file: fs.File | null = null;
    try {
      const savePath = `${GlobalContextUtils.globalContext.cacheDir}/${new Date().getTime()}.png`;
      file = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd, buffer);
      return fileUri.getUriFromPath(savePath);
    } catch (e) {
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        Logger.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }
}