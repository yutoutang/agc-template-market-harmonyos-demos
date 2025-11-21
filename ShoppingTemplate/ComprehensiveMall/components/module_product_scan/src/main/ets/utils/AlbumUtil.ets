import { photoAccessHelper } from '@kit.MediaLibraryKit';

class AlbumUtil {
  public static selectPicture(callback: Function) {
    // 通过选择模式拉起photoPicker界面，用户可以选择一个图片
    let photoOption = new photoAccessHelper.PhotoSelectOptions();
    photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoOption.maxSelectNumber = 1;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select(photoOption).then((result) => {
      callback(result);
    });
  }
}

export { AlbumUtil };
