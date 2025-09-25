import { photoAccessHelper } from '@kit.MediaLibraryKit';
import fs from '@ohos.file.fs';
import { buffer } from '@kit.ArkTS';
import { fileUri } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export class PhotoUtils {
  /**
   * 用系统picker，拉起相册或者相机
   * @param params
   * @returns
   */
  public static selectPhoto(): Promise<string[]> {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;

    let uris: string[] = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    return photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
      return uris;
    }).catch((err: BusinessError) => {
      console.error(
        `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
      return uris;
    })
  }

  /**
   * 保存图片至系统相册
   *
   * @param context
   * @param imageBuffer
   */
  static async saveImageToAlbum(context: Context, base64image: string) {
    const reg = new RegExp('data:image/\\w+;base64,')
    const base64 = base64image.replace(reg, '');
    const decodeBuffer = buffer.from(base64, 'base64').buffer;
    const filesDir = context.cacheDir;
    const savePath = `${filesDir}/${new Date().getTime()}.png`;
    let file: fs.File = null!;
    let file1: fs.File = null!;
    let file2: fs.File = null!;
    try {
      file = await fs.open(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(file.fd, decodeBuffer);
    } finally {
      await fs.close(file);
    }
    let uri = fileUri.getUriFromPath(savePath)
    let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    try {
      let srcFileUris: Array<string> = [
        uri,
      ];
      let photoCreationConfigs: Array<photoAccessHelper.PhotoCreationConfig> = [
        {
          fileNameExtension: 'jpg',
          photoType: photoAccessHelper.PhotoType.IMAGE,
        },
      ];
      /*
       * 调用此接口时请确保module.json5文件中的abilities标签中配置了label和icon项。
       * */
      let desFileUris: Array<string> = await phAccessHelper.showAssetsCreationDialog(srcFileUris, photoCreationConfigs);
      file1 = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let arrayBuffer = new ArrayBuffer(4096000);
      let readLen = fs.readSync(file1.fd, arrayBuffer);
      let buf = buffer.from(arrayBuffer, 0, readLen);
      file2 = fs.openSync(desFileUris[0], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file2.fd, arrayBuffer);
      promptAction.showToast({ message: '保存成功' })
    } catch (err) {
      promptAction.showToast({ message: '保存失败' })
    } finally {
      fs.closeSync(file2);
      fs.closeSync(file1);
    }
  }
}