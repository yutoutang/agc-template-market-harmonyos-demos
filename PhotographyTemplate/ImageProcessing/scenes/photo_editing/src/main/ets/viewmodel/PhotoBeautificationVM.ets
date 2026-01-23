import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { AppStorageV2, componentSnapshot } from '@kit.ArkUI';
import { CanvasTextItem, StickerModel } from '../model/BeautificationParam';
import { MyPosition } from '../model/PageParams';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { Constants } from '../constant/Constants';
import { ActionType } from '../constant/Enum';
import { UserInfo } from 'commonlib';
import { DrawPathPointModel } from '../model/Index';


@ObservedV2
export class PhotoBeautificationVM {
  // 图片资源的宽高比
  @Trace ratio: number = 1;
  // 旋转时的宽高比
  @Trace rotateRatio: undefined | number = undefined;
  @Trace pixelMapList: image.PixelMap[] = [];
  @Trace currentPixelMap?: image.PixelMap = undefined;
  @Trace originImagePixelMap?: image.PixelMap = undefined;
  @Trace currentPixelMapIndex: number = 0;
  @Trace totalPixelMapCount: number = 0;
  @Trace barIndex: number = -1;
  @Trace filterName: string = '';
  @Trace imageArea: MyPosition = new MyPosition();
  @Trace touchPosition: MyPosition = new MyPosition();
  @Trace clipRect: MyPosition = new MyPosition();
  @Trace cropRatio: number = 0;
  @Trace clipRectMaxH: number = 0;
  @Trace clipRectMaxW: number = 0;
  @Trace carouselCutTabIndex: number = 0;
  @Trace stickerList: StickerModel[] = [];
  @Trace canvasItemStack: CanvasTextItem =
    new CanvasTextItem('#000000', 16, 100, false, false, false, 'Noto', '', 25, 25);
  @Trace saveText: boolean = false;
  @Trace selectedFilterIndex: number = 0;
  // 是否叠加马赛克图层
  @Trace isAddMosaic: boolean = false;
  // 当前马赛克资源路径
  @Trace mosaicSource: string = '';
  // 马赛克线条宽度
  @Trace lineWidth: number = 8;
  @Trace mosaicIndex: number = -1;
  // 水印组件id
  @Trace waterMarkId: string = 'photoWaterMark';
  @Trace isShowPosition: boolean = true;
  // 水印图片
  @Trace waterMarkPixelMap: image.PixelMap | undefined = undefined;
  // 登录信息
  @Trace loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  // 会员提示是否展示
  @Trace showRemind: boolean = false;
  // 是否选择vip马赛克
  @Trace isVipMosaic: boolean = false;
  // 是否绘制了vip马赛克
  @Trace hasDrawVip: boolean = false;
  filterController: SwiperController = new SwiperController();
  settings: RenderingContextSettings = new RenderingContextSettings(true);
  maskContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  cropContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  actionType: ActionType = ActionType.MOVE;
  public renderSettings: RenderingContextSettings = new RenderingContextSettings(true);
  public context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderSettings);
  public canvasHeight: number = 0;
  public canvasWidth: number = 0;
  // 马赛克的类型
  private pattern: CanvasPattern | null = null;
  private points: DrawPathPointModel[] = [];
  private drawPath = new Path2D();
  private static _instance: PhotoBeautificationVM;

  public static get instance() {
    if (!PhotoBeautificationVM._instance) {
      PhotoBeautificationVM._instance = new PhotoBeautificationVM();
    }
    return PhotoBeautificationVM._instance;
  }


  // 创造马赛克样式
  createPattern() {
    const img = new ImageBitmap(this.mosaicSource);
    this.pattern = this.context.createPattern(img, 'repeat');
  }

  moveStart(x: number, y: number) {
    this.points.push({ x: x, y: y });
    this.drawPath.moveTo(x, y);
    this.drawCurrentPathModel();
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
  }

  moveUpdate(x: number, y: number) {
    let lastPoint = this.points[this.points.length - 1];
    this.points.push({ x: x, y: y });
    this.drawPath.quadraticCurveTo((x + lastPoint.x) / 2, (y + lastPoint.y) / 2, x, y);
    this.drawCurrentPathModel();
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
  }

  moveEnd() {
    this.points = [];
    this.drawPath = new Path2D();
    if (this.isVipMosaic) {
      this.hasDrawVip = true;
    }
  }

  // 清空马赛克
  clearPath() {
    this.showRemind = false;
    this.mosaicSource = '';
    this.mosaicIndex = -1;
    this.points = [];
    this.drawPath = new Path2D();
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);
    this.hasDrawVip = false;
    this.isVipMosaic = false;
  }

  // 获取canvas画布大小
  canvasAreaChange(area: Area) {
    this.canvasHeight = area.height as number;
    this.canvasWidth = area.width as number;
  }

  // 保存马赛克
  saveMosaic() {
    this.saveImage();
    this.clearPath();
  }


  @Monitor('saveText')
  refreshSaveText() {
    if (this.saveText) {
      setTimeout(() => {
        this.saveImage();
        this.saveText = false;
        this.canvasItemStack = new CanvasTextItem('#000000', 16, 100, false, false, false, 'Noto', '', 25, 25);
      }, 200);
    }
  }

  @Monitor('clipRect')
  refreshDrawMask() {
    this.maskContext.clearRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.fillStyle = 'rgba(0,0,0,0.7)';
    this.maskContext.fillRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.clearRect(this.clipRect.x - this.imageArea.x, this.clipRect.y - this.imageArea.y,
      this.clipRect.width, this.clipRect.height);
  }

  initData(uri: string) {
    let resFile: fs.File = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    try {
      const imageSource: image.ImageSource = image.createImageSource(resFile.fd);
      imageSource.createPixelMap().then((result: PixelMap) => {
        this.pushPixelMap(result);
      });
    } catch (err) {
      console.error('init data failed with error message: ' + err.message + ', error code: ' + err.code);
    } finally {
      fs.closeSync(resFile);
    }
  }

  getRotate(index: number): number {
    switch (index) {
      case 0:
        return -90;
      case 1:
        return 90;
      case 2:
        return 180;
      case 3:
        return 360;
      default:
        return 0;
    }
  }

  determineCropType() {
    let cropRatio = this.cropRatio;
    let imageRatio = (this.imageArea.height!) / this.imageArea.width!;
    if (cropRatio === 0) {
      this.clipRectMaxH = this.imageArea.height!;
      this.clipRectMaxW = this.imageArea.width!;
      this.clipRect = {
        x: Math.round(this.imageArea.x),
        y: Math.round(this.imageArea.y),
        width: Math.round(this.clipRectMaxW),
        height: Math.round(this.clipRectMaxH),
      };
    } else {
      if (this.imageArea.width! > this.imageArea.height!) {
        if (cropRatio < imageRatio) {
          this.clipRectMaxH = this.imageArea.width! * cropRatio;
          this.clipRectMaxW = this.imageArea.width!;
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.imageArea.width! * cropRatio) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        } else {
          this.clipRectMaxH = this.imageArea.height!;
          this.clipRectMaxW = (this.imageArea.height!) / cropRatio;
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - (this.imageArea.height!) / cropRatio) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        }

      } else {
        if (cropRatio > 1) {
          this.clipRectMaxH = this.imageArea.height!;
          this.clipRectMaxW = (this.imageArea.height!) / cropRatio;
          this.clipRect = {
            x: Math.round(this.imageArea.x + (this.imageArea.width! - this.clipRectMaxW) / 2),
            y: Math.round(this.imageArea.y),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        } else {
          this.clipRectMaxH = this.imageArea.width! * cropRatio;
          this.clipRectMaxW = this.imageArea.width!;
          this.clipRect = {
            x: Math.round(this.imageArea.x),
            y: Math.round(this.imageArea.y + (this.imageArea.height! - this.clipRectMaxH) / 2),
            width: Math.round(this.clipRectMaxW),
            height: Math.round(this.clipRectMaxH),
          };
        }
      }
    }
  }

  // 去除剪切
  cleanReact() {
    this.clipRect.x = this.imageArea.x;
    this.clipRect.y = this.imageArea.y;
    this.clipRect.width = this.imageArea.width;
    this.clipRect.height = this.imageArea.height;
  }

  // 绘制蒙层
  drawMask() {
    this.maskContext.clearRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.fillStyle = 'rgba(0,0,0,0.7)';
    this.maskContext.fillRect(0, 0, this.imageArea.width, this.imageArea.height);
    this.maskContext.clearRect(this.clipRect.x - this.imageArea.x, this.clipRect.y - this.imageArea.y,
      this.clipRect.width, this.clipRect.height);
  }

  // 绘制裁剪框
  drawClipImage(uiContext: UIContext) {
    let lineWidth = uiContext.vp2px(2);
    let clipRectW = this.clipRect.width! + 4;
    let clipRectH = this.clipRect.height! + 4;
    this.cropContext.clearRect(2, 2, this.clipRect.width, this.clipRect.height);
    this.cropContext.lineWidth = lineWidth;
    this.cropContext.strokeStyle = '#FFFFFF';
    this.cropContext.beginPath();

    this.cropContext.moveTo(0, 20);
    this.cropContext.lineTo(0, 0);
    this.cropContext.lineTo(20, 0);

    this.cropContext.moveTo(clipRectW / 2 - 10, 0);
    this.cropContext.lineTo(clipRectW / 2 + 10, 0);

    this.cropContext.moveTo(clipRectW - 20, 0);
    this.cropContext.lineTo(clipRectW, 0);
    this.cropContext.lineTo(clipRectW, 20);

    this.cropContext.moveTo(clipRectW, clipRectH / 2 - 10);
    this.cropContext.lineTo(clipRectW, clipRectH / 2 + 10);

    this.cropContext.moveTo(0, clipRectH - 20);
    this.cropContext.lineTo(0, clipRectH);
    this.cropContext.lineTo(20, clipRectH);

    this.cropContext.moveTo(clipRectW / 2 - 10, clipRectH);
    this.cropContext.lineTo(clipRectW / 2 + 10, clipRectH);

    this.cropContext.moveTo(clipRectW - 20, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH);
    this.cropContext.lineTo(clipRectW, clipRectH - 20);

    this.cropContext.moveTo(0, clipRectH / 2 - 10);
    this.cropContext.lineTo(0, clipRectH / 2 + 10);

    this.cropContext.stroke();

    this.cropContext.beginPath();
    this.cropContext.lineWidth = 0.55;
    let height = Math.round((this.clipRect.height!) / 3);
    for (let index = 0; index <= 3; index++) {
      let y = index === 3 ? (this.clipRect.height) : height * index;
      this.cropContext.moveTo(2, y! + 2);
      this.cropContext.lineTo(this.clipRect.width, y! + 2);
    }
    let width = Math.round((this.clipRect.width!) / 3);
    for (let index = 0; index <= 3; index++) {
      let x = index === 3 ? (this.clipRect.width) : width * index;
      this.cropContext.moveTo(x! + 2, 2);
      this.cropContext.lineTo(x! + 2, this.clipRect.height! + 2);
    }
    this.cropContext.stroke();
  }

  // 判断操作类型
  isMove(area: Area, touch: TouchObject) {
    let touchW = 20;
    if (this.cropRatio === 0) {
      if (touch.x < touchW && touch.y < touchW) { // 左上角
        this.actionType = ActionType.TOP_LEFT;
      } else if (touch.x < touchW && touch.y > (Number(area.height) - touchW)) { // 左下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else if (touch.x > Number(area.width) - touchW && touch.y < touchW) { // 右上
        this.actionType = ActionType.TOP_RIGHT;
      } else if (touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) - touchW)) { // 右下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) && touch.y < touchW) { //上面
        this.actionType = ActionType.TOP;
      } else if (touch.x > touchW && (touch.x < Number(area.width) - touchW) &&
        touch.y > (Number(area.height) - touchW)) { //下面
        this.actionType = ActionType.BOTTOM;
      } else if (touch.x < touchW && (touch.y < Number(area.height) - touchW) && touch.y > touchW) { //左面
        this.actionType = ActionType.LEFT;
      } else if (touch.x > Number(area.width) - touchW && (touch.y < Number(area.height) - touchW) &&
        touch.y > touchW) { //右面
        this.actionType = ActionType.RIGHT;
      } else {
        this.actionType = ActionType.MOVE;
      }
    } else {
      if (touch.x < (Number(area.width) / 2) && touch.y < touchW ||
        touch.x < touchW && touch.y < (Number(area.height) / 2)) { // 左上角
        this.actionType = ActionType.TOP_LEFT;
      } else if (touch.x < (Number(area.width) / 2) && touch.y > (Number(area.height) - touchW) ||
        touch.x < touchW && touch.y > (Number(area.height) / 2)) { // 左下
        this.actionType = ActionType.BOTTOM_LEFT;
      } else if (touch.x > Number(area.width) / 2 && touch.y < touchW ||
        touch.x > Number(area.width) - touchW && touch.y < (Number(area.height) / 2)) { // 右上
        this.actionType = ActionType.TOP_RIGHT;
      } else if (touch.x > Number(area.width) / 2 && touch.y > (Number(area.height) - touchW) ||
        touch.x > Number(area.width) - touchW && touch.y > (Number(area.height) / 2)) { // 右下
        this.actionType = ActionType.BOTTOM_RIGHT;
      } else {
        this.actionType = ActionType.MOVE;
      }
    }
  }

  // 自由裁剪框变换
  moveClipCanvasFreeType(moveX: number, moveY: number) {
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height,
    };
    switch (this.actionType) {
      case ActionType.MOVE:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.TOP_LEFT:
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.TOP_RIGHT:
        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM_LEFT:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.BOTTOM_RIGHT:
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.TOP:
        clipRect.y += moveY;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM:
        clipRect.height! += moveY;
        break;
      case ActionType.LEFT:
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        break;
      case ActionType.RIGHT:
        clipRect.width! += moveX;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {

        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!),
    };
  }

  // 固定裁剪框位置和大小变化    初始位置为图片的初始坐标 移动的坐标
  moveClipCanvasRatioType(moveX: number, moveY: number) {
    let clipRect: MyPosition = {
      x: this.clipRect.x,
      y: this.clipRect.y,
      width: this.clipRect.width,
      height: this.clipRect.height,
    };

    switch (this.actionType) {
      case ActionType.MOVE:
        clipRect.x += moveX;
        clipRect.y += moveY;
        break;
      case ActionType.TOP_LEFT:
        if (moveX > (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio;
        } else {
          moveY = moveX * this.cropRatio;
        }
        clipRect.x += moveX;
        clipRect.y += moveY;
        clipRect.width! += -moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.TOP_RIGHT:
        //moveX和moveY，一种正数，另外一个必然是负数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        }

        clipRect.y += moveY;
        clipRect.width! += moveX;
        clipRect.height! += -moveY;
        break;
      case ActionType.BOTTOM_LEFT:
        //moveX和moveY，一种正数，另外一个必然是负数
        if (moveX > 0) {
          if (moveX > -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        } else {
          if (moveX < -(moveY / this.cropRatio)) {
            moveX = -moveY / this.cropRatio;
          } else {
            moveY = -moveX * this.cropRatio;
          }
        }
        clipRect.x += moveX;
        clipRect.width! += -moveX;
        clipRect.height! += moveY;
        break;
      case ActionType.BOTTOM_RIGHT:
        if (moveX < (moveY / this.cropRatio)) {
          moveX = moveY / this.cropRatio;
        } else {
          moveY = moveX * this.cropRatio;
        }
        clipRect.width! += moveX;
        clipRect.height! += moveY;
        break;
      default:
        break;
    }

    // 偏移坐标小于初始位置
    if (clipRect.x < this.imageArea.x) {
      clipRect.x = this.imageArea.x;
    }

    if (clipRect.y < this.imageArea.y) {
      clipRect.y = this.imageArea.y;
    }

    // 横坐标限制位置
    if (clipRect.width! + clipRect.x > this.imageArea.width! + this.imageArea.x) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.x = this.imageArea.width! + this.imageArea.x - clipRect.width!;
      } else {
        clipRect.width = this.imageArea.width! + this.imageArea.x - clipRect.x;
      }
    }

    // 纵坐标限制
    if (clipRect.height! + clipRect.y > this.imageArea.height! + this.imageArea.y) {
      if (this.actionType === ActionType.MOVE) {
        clipRect.y = this.imageArea.height! + this.imageArea.y - clipRect.height!;
      } else {
        clipRect.height = this.imageArea.height! + this.imageArea.y - clipRect.y;
      }
    }
    if (clipRect.height! > this.clipRectMaxH) {
      clipRect.height = this.clipRectMaxH;
    }

    if (clipRect.width! > this.clipRectMaxW) {
      clipRect.width = this.clipRectMaxW;
    }

    this.clipRect = {
      x: Math.round(clipRect.x),
      y: Math.round(clipRect.y),
      width: Math.round(clipRect.width!),
      height: Math.round(clipRect.height!),
    };
  }

  deleteSticker: (id: string) => void = (id: string) => {
    this.stickerList = this.stickerList.filter(item => item.id !== id);
  };
  // 保存图片
  saveImage: () => void = () => {
    let pixelMapOrigin = componentSnapshot.getSync('ImageContent');
    let imageInfo = pixelMapOrigin.getImageInfoSync();
    let ratioX = imageInfo.size.width / this.imageArea.width!;
    let ratioY = imageInfo.size.height / this.imageArea.height!;
    let x = this.clipRect.x - this.imageArea.x;
    let y = this.clipRect.y - this.imageArea.y;
    let pixelMap = ImageProcessingUtil.getRectanglePixelMap(pixelMapOrigin as PixelMap, Math.round(x * ratioX),
      Math.round(y * ratioY), Math.round(this.clipRect.width! * ratioX), Math.round(this.clipRect.height! * ratioY));
    if (pixelMap) {
      this.pushPixelMap(pixelMap);
      this.barIndex = -1;
    }
  };
  saveImageWithText: () => void = () => {
    this.saveText = true;
  };
  // 旋转图片
  rotateImage: (rotate: number) => void = (rotate: number) => {
    let pixelMap = this.currentPixelMap?.cloneSync();
    if (rotate === 360) {
      pixelMap?.flipSync(true, false);
      if (pixelMap) {
        const imgInfo = pixelMap.getImageInfoSync();
        this.rotateRatio = imgInfo.size.width / imgInfo?.size.height;
      }
    } else {
      pixelMap?.rotateSync(rotate);
      if (pixelMap) {
        const imgInfo = pixelMap.getImageInfoSync();
        this.rotateRatio = imgInfo.size.width / imgInfo?.size.height;
      }
    }
    this.currentPixelMap = pixelMap;
  };

  // 获取当前图片的宽高比
  getCurrentRatio() {
    if (this.currentPixelMap) {
      const imgInfo = this.currentPixelMap.getImageInfoSync();
      this.ratio = imgInfo.size.width / imgInfo.size.height;
    }
  }


  pushPixelMap(pixelMap: PixelMap) {
    // 获取宽高比
    const imgInfo = pixelMap.getImageInfoSync();
    this.ratio = imgInfo.size.width / imgInfo.size.height;
    this.currentPixelMap = pixelMap;
    this.originImagePixelMap = pixelMap;
    if (this.pixelMapList.length - 1 > this.currentPixelMapIndex) {
      this.pixelMapList = this.pixelMapList.slice(0, this.currentPixelMapIndex);
    }
    this.pixelMapList.push(pixelMap);
    this.totalPixelMapCount = this.pixelMapList.length;
    this.currentPixelMapIndex = this.pixelMapList.length - 1;

    // 热门滤镜入口
    let index = Constants.filterList.findIndex(item => item.name === this.filterName);
    if (index !== -1) {
      ImageProcessingUtil.filterImage(Constants.filterList[index], this.currentPixelMap)
        .then(data => {
          this.currentPixelMap = data;
        });
      this.selectedFilterIndex = index;
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

  // 保存水印
  async saveWaterMark(uiContext: UIContext) {
    if (this.currentPixelMap && this.waterMarkPixelMap && this.imageArea.width) {
      let waterPixelMap =
        await this.addWaterMark(this.currentPixelMap, this.waterMarkPixelMap, this.imageArea!.width, uiContext);
      this.pushPixelMap(waterPixelMap);
      this.barIndex = -1;
    }
  }

  // 绘制
  private drawCurrentPathModel() {
    this.context.globalCompositeOperation = 'source-over';
    this.context.lineWidth = this.lineWidth;
    if (this.pattern) {
      this.context.strokeStyle = this.pattern;
    }
    this.context.lineJoin = 'round';
    this.context.stroke(this.drawPath);
  }
}