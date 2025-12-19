import { image } from '@kit.ImageKit';

export class ImageUtil {
  public static async getPixmapFromMedia(ctx:Context,resource: Resource) {
    let unit8Array =  ctx.resourceManager.getMediaContentSync(resource.id);

    let imageSource = image.createImageSource(unit8Array.buffer.slice(0, unit8Array.buffer.byteLength));
    let pixelMap: image.PixelMap = await imageSource.createPixelMap({
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888
    });
    await imageSource.release();
    return pixelMap;
  }








}