import { util } from '@kit.ArkTS';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[FileUtils]';
const BYTE_CONVERSION: number = 1024;
const REDUCE_SCALE: number = 0.2;
const TARGET_BUFFER_SIZE: number = 1.5 * BYTE_CONVERSION * BYTE_CONVERSION;
const IMAGE_TYPES = ['jpg', 'png', 'webp', 'heif'];

export class FileUtils {
  /**
   * uri对应文件复制到沙箱
   * @param uiContext
   * @param uri
   * @returns
   */
  public static async handleUri(uiContext: UIContext, uri: string): Promise<string> {
    if (!uri) {
      return '';
    }
    let tempFile: fs.File | null = null;
    let targetFile: fs.File | null = null;

    const suffix = FileUtils.getFileExtension(uri);
    let newPath: string = uiContext.getHostContext()?.cacheDir + `/${util.generateRandomUUID(false)}.${suffix}`;

    try {
      tempFile = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      const stat: fs.Stat = fs.statSync(tempFile.fd);
      // 针对大图片进行压缩
      if (IMAGE_TYPES.includes(suffix) && stat.size > TARGET_BUFFER_SIZE) {
        const buffer: ArrayBuffer = new ArrayBuffer(stat.size);
        fs.readSync(tempFile.fd, buffer);
        const pixel = image.createImageSource(buffer).createPixelMapSync();
        const afterBuffer = await FileUtils.scalePriorityCompress(pixel, TARGET_BUFFER_SIZE / BYTE_CONVERSION, 50);
        if (afterBuffer) {
          targetFile = fs.openSync(newPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          fs.writeSync(targetFile.fd, afterBuffer as ArrayBuffer);
          UtilLog.info(TAG, 'handleUri writeSync success, cache path: ' + newPath);
        } else {
          fs.copyFileSync(tempFile.fd, newPath);
          UtilLog.info(TAG, 'compress fail, handleUri copyFileSync success, cache path: ' + newPath);
        }
      } else {
        fs.copyFileSync(tempFile.fd, newPath);
        UtilLog.info(TAG, 'no need compress, handleUri copyFileSync success, cache path: ' + newPath);
      }

      return fileUri.getUriFromPath(newPath);
    } catch (e) {
      UtilLog.error(TAG, 'handleUri fail, error: ' + JSON.stringify(e));
      return '';
    } finally {
      try {
        if (tempFile) {
          fs.closeSync(tempFile);
        }
        if (targetFile) {
          fs.closeSync(targetFile);
        }
      } catch (e) {
        UtilLog.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }

  /**
   * 动态图片写入沙箱
   * @param context
   * @param movingPhoto
   * @returns
   */
  public static async saveMovingPhotoToSandbox(context: Context, movingPhoto: photoAccessHelper.MovingPhoto) {
    try {
      const imageFileUri: string = context.cacheDir + `/${util.generateRandomUUID(false)}.jpg`;
      const videoFileUri: string = context.cacheDir + `/${util.generateRandomUUID(false)}.mp4`;

      await movingPhoto.requestContent(imageFileUri, videoFileUri);
      return [fileUri.getUriFromPath(imageFileUri), fileUri.getUriFromPath(videoFileUri)];
    } catch (e) {
      UtilLog.error(TAG, 'requestContent error: ' + JSON.stringify(e));
      return [];
    }
  }

  /**
   * 优先压缩图片尺寸
   * @param sourcePixelMap 原始待压缩图片的PixelMap
   * @param maxCompressedImageSize 指定图片的压缩目标大小，单位KB
   * @param quality
   */
  static async scalePriorityCompress(sourcePixelMap: image.PixelMap, maxCompressedImageSize: number,
    quality: number): Promise<ArrayBuffer | null> {
    let compressedImageData: ArrayBuffer | null = await FileUtils.packing(sourcePixelMap, quality);
    if (!compressedImageData) {
      return null;
    }
    // 如果调整过最低图片质量，先计算最低图片质量是否满足要求。如果设定的最低图片质量已经满足目标大小，则直接返回
    if (compressedImageData.byteLength <= maxCompressedImageSize * BYTE_CONVERSION) {
      UtilLog.info(TAG,
        'first afterCompressionSize(KB)=' + (compressedImageData.byteLength / BYTE_CONVERSION).toFixed(1))
      return compressedImageData;
    }

    // 定义图片宽高的缩放倍数，1表示原比例。
    let imageScale = 1;

    // 判断压缩后的图片大小是否大于指定图片的压缩目标大小，如果大于，继续降低缩放倍数压缩。
    while (compressedImageData.byteLength > maxCompressedImageSize * BYTE_CONVERSION) {
      if (imageScale > 0) {
        // 如果对图片压缩质量要求不高，建议调高每次递减的缩放倍数REDUCE_SCALE，减少循环，提升scale压缩性能。
        imageScale = imageScale - REDUCE_SCALE;
        await sourcePixelMap.scale(imageScale, imageScale);
        compressedImageData = await FileUtils.packing(sourcePixelMap, quality);
        if (!compressedImageData) {
          break;
        }
      } else {
        break;
      }
    }
    if (!compressedImageData) {
      return null;
    }
    UtilLog.info(TAG, 'final afterCompressionSize(KB)=' + (compressedImageData.byteLength / BYTE_CONVERSION).toFixed(1))
    return compressedImageData;
  }

  /**
   * packing压缩
   * @param sourcePixelMap 原始待压缩图片的PixelMap
   * @param imageQuality 图片质量参数
   * @returns data 返回压缩后的图片数据
   */
  static async packing(sourcePixelMap: image.PixelMap, imageQuality: number): Promise<ArrayBuffer | null> {
    try {
      const imagePackerApi = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: imageQuality };
      const data: ArrayBuffer = await imagePackerApi.packToData(sourcePixelMap, packOpts);
      return data;
    } catch (e) {
      UtilLog.error(TAG, `imagePackerApi.packToData fail. Code: ${e.code}, message: ${e.message}`);
      return null;
    }
  }

  /**
   * pixelMap写入沙箱
   * @param pixelMap
   * @returns
   */
  public static async writePixelMap(uiContext: UIContext, pixelMap?: image.PixelMap): Promise<string> {
    if (!pixelMap) {
      return '';
    }
    let file: fs.File | null = null;
    try {
      const newPath: string = uiContext.getHostContext()?.cacheDir + `/${util.generateRandomUUID(false)}.png`;
      file = fs.openSync(newPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
      let imagePacker: image.ImagePacker = image.createImagePacker();
      let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
      await imagePacker.packToFile(pixelMap, file.fd, packOpts);
      return fileUri.getUriFromPath(newPath);
    } catch (e) {
      UtilLog.error(TAG, 'writePixelMap fail, error: ' + JSON.stringify(e));
      return '';
    } finally {
      try {
        if (file) {
          fs.closeSync(file);
        }
      } catch (e) {
        UtilLog.error(TAG, 'fs.closeSync error: ' + JSON.stringify(e));
      }
    }
  }

  /**
   * 获取文件后缀名
   * @param filePath
   * @returns
   */
  public static getFileExtension(filePath: string): string {
    // 先拆分路径，取最后一段（文件名）
    const fileName = filePath.split(/[\/\\]/).pop();
    if (fileName) {
      const dotIndex = fileName.lastIndexOf('.') ?? -1;
      return dotIndex > 0 ? fileName.slice(dotIndex + 1) : '';
    }
    return '';
  }
}