import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { RouterMap, RouterModule, Logger } from 'commonlib';


@ObservedV2
export class ImageDownloadPageVM {
  @Trace capturePixelmap: image.PixelMap | undefined = undefined;
  private static _instance: ImageDownloadPageVM;

  public static get instance() {
    if (!ImageDownloadPageVM._instance) {
      ImageDownloadPageVM._instance = new ImageDownloadPageVM();
    }
    return ImageDownloadPageVM._instance;
  }


  getRouteParm() {
    this.capturePixelmap = RouterModule.getNavParam({ url: RouterMap.IMAGE_DOWNLOAD });
  }


  async handleSaveButtonClick(context: Context) {
    let file: fileIo.File | undefined = undefined;
    try {
      let imageStyle: string | undefined = AppStorage.get('imageStyle');
      let imageQualityLevel: number | undefined = AppStorage.get('imageQualityLevel');
      if (!imageStyle) {
        imageStyle = 'jpeg';
      }
      let quality = 100;
      if (imageQualityLevel === 1) {
        quality = 60;
      } else if (imageQualityLevel === 2) {
        quality = 30;
      }
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      const filePath = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, imageStyle ?? 'jpeg');
      const imagePacker = image.createImagePacker();
      const imageBuffer =
        await imagePacker.packToData(this.capturePixelmap, { format: `image/${imageStyle}`, quality: quality });
      const mode = fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE;
      file = fileIo.openSync(filePath, mode);
      fileIo.writeSync(file.fd, imageBuffer);
      promptAction.showToast({ message: '保存图片到相册成功~' });
    } catch (err) {
      Logger.error('save to album error', JSON.stringify(err));
    } finally {
      if (file) {
        fileIo.close(file);
      }
    }
  }
}
