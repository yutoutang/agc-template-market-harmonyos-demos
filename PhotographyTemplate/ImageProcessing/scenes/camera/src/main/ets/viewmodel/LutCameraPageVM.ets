import { image } from '@kit.ImageKit';
import { ToastDialog as promptAction } from '@hw-agconnect/ui-toast';
import { RouterMap, RouterModule, Logger } from 'commonlib';
import { LutModel } from '../model/Index';


@ObservedV2
export class LutCameraPageVM {
  @Trace markId: string = 'watermarkFlag';
  // 外层容器宽高
  @Trace containerWidth: number = 0;
  @Trace containerHeight: number = 0;
  // 预览容器宽高
  @Trace preWidth: number = 360;
  @Trace preHeight: number = 640;
  // 默认宽高比
  @Trace ratio: number = 16 / 9;
  // 是否展示水印
  @Trace isShowWatermark: boolean = false;
  // 是否展示滤镜
  @Trace isLut: boolean = false;
  @Trace hasPermission: boolean = false;
  // 水印图片
  @Trace markPixelMap: image.PixelMap | undefined = undefined;
  // 照片
  @Trace currentPixelMap: image.PixelMap | undefined = undefined;
  // 滤镜资源
  @Trace lutList: LutModel[] = [
    {
      id: '1',
      lut: $r('app.media.lut'),
      icon: $r('app.media.lut_ic1'),
      label: '暗光提亮',
      isVip: false,
    },
  ];
  @Trace lutIndex: number = -1;
  private static _instance: LutCameraPageVM;

  public static get instance() {
    if (!LutCameraPageVM._instance) {
      LutCameraPageVM._instance = new LutCameraPageVM();
    }
    return LutCameraPageVM._instance;
  }

  // 处理预览容器宽高
  handlePreSize() {
    let targetWidth = this.containerWidth;
    let targetHeight = targetWidth * this.ratio;
    if (targetHeight <= this.containerHeight) {
      this.preHeight = targetHeight;
      this.preWidth = targetWidth;
    } else {
      this.preHeight = this.containerHeight;
      this.preWidth = this.preHeight / this.ratio;
    }
  }

  // 添加水印
  async addWaterMark(originalPixelmap: image.PixelMap, markPixelmap: image.PixelMap, containerWidth: number,
    uiContext: UIContext) {
    // 获取图片信息
    const originalInfo = await originalPixelmap.getImageInfo();
    const markInfo = await markPixelmap.getImageInfo();
    // 记录原图和水印图片大小
    const originWidth: number = uiContext.px2vp(originalInfo.size.width);
    const originHeight: number = uiContext.px2vp(originalInfo.size.height);
    const markWidth: number = uiContext.px2vp(markInfo.size.width);
    const markHeight: number = uiContext.px2vp(markInfo.size.height);
    // 计算预览容器和图片宽度之间的比例
    const ratio = originWidth / containerWidth;
    // 离屏绘制原图片
    const offscreenCanvas = new OffscreenCanvas(originWidth, originHeight);
    const ctx = offscreenCanvas.getContext('2d');
    ctx.drawImage(originalPixelmap, 0, 0, originWidth, originHeight);
    // 计算水印的绘制位置
    const DEFAULT_PADDING = 16; // 默认的内边距为16vp
    const x = DEFAULT_PADDING * ratio;
    const y = originHeight - (markHeight * ratio + DEFAULT_PADDING * ratio);
    // 绘制水印
    ctx.drawImage(markPixelmap, x, y, markWidth * ratio, markHeight * ratio);

    return ctx.getPixelMap(0, 0, originWidth, originHeight);
  }

  // 拍照
  async handlePhoto(buffer: ArrayBuffer, uiContext: UIContext) {
    if (buffer.byteLength > 0) {
      let opts: image.InitializationOptions = {
        editable: true,
        srcPixelFormat: image.PixelMapFormat.RGBA_8888,
        size: { height: 1920, width: 1080 },
      };
      // 直接调用
      try {
        this.currentPixelMap = await image.createPixelMap(buffer, opts);
        if (this.isShowWatermark && this.markPixelMap) {
          this.currentPixelMap =
            await this.addWaterMark(this.currentPixelMap, this.markPixelMap, this.containerWidth, uiContext);
        }
        RouterModule.push({ url: RouterMap.IMAGE_DOWNLOAD, param: this.currentPixelMap });
      } catch (e) {
        Logger.error(JSON.stringify(e));
      }
    } else {
      promptAction.showToast({ message: '相机未准备好！' });
    }
  }
}
