import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import sdk from 'libveditor.so';
import { Sticker } from '../model/Sticker';
import { GestureState, XAdsorbType, YAdsorbType } from '../common/Enum';
import { Constant } from '../common/Constant';
import { Point } from '../model/Index';
import { VideoEditVM } from '../viewmodel/VideoEditVM';

let videoWidth: number = 0; // 视频宽度
let videoHeight: number = 0; // 视频高度
let maxX: number = 0; // x轴最大值
let minX: number = 0; // x轴最小值
let maxY: number = 0; // y轴最大值
let minY: number = 0; // y轴最小值

@ComponentV2
export struct StickerManage {
  vm: VideoEditVM = VideoEditVM.instance;
  @Param @Require sticker: Sticker;
  @Local curGestureState: GestureState = GestureState.NONE; // 手势操作状态
  @Local stickerX: number = 0; // 贴纸x坐标（以视频中心为原点）
  @Local stickerY: number = 0; // 贴纸y坐标（以视频中心为原点）
  @Local widthFromSDK: number = 0; // 原始宽度
  @Local heightFromSDK: number = 0; // 原始高度
  @Local rotateEndAngle: number = 0; // 当前旋转角度
  @Local curPinchValue: number = 1; // 当前缩放值
  @Local pinchValue: number = 1; // 手势中的临时缩放值
  @Local angle: number = 0; // 当前旋转角度
  @Local xAdsorbType: XAdsorbType = XAdsorbType.NONE;
  @Local yAdsorbType: YAdsorbType = YAdsorbType.NONE;
  @Local remove: boolean = false;
  private isPanReject: boolean = false;
  private panStartX: number = 0; // 平移开始时的x坐标
  private panStartY: number = 0; // 平移开始时的y坐标
  private panEndX: number = 0; // 平移结束时的x坐标
  private panEndY: number = 0; // 平移结束时的y坐标
  private panStartGlobalX: number = 0; // 平移开始时的全局x
  private panStartGlobalY: number = 0; // 平移开始时的全局y
  private rotateStartAngle: number = 0; // 旋转开始时的角度
  private pinchStartScale: number = 1; // 缩放开始时的基准值
  public currentLocalX: number = 0;
  public currentLocalY: number = 0;
  private lastGestureTimestamp: number = 0; // 手势时间戳
  private adsorbPosX: number[] = []; // x轴吸附位置（-videoWidth/2, 0, videoWidth/2）
  private adsorbPosY: number[] = []; // y轴吸附位置（-videoHeight/2, 0, videoHeight/2）
  private isAnhleAdsorb: boolean = false;
  private isXAdsorb: boolean = false;
  private isYAdsorb: boolean = false;
  private adsorbAngleValue: number = 0;
  private adsorbXValue: number = 0;
  private adsorbYValue: number = 0;

  // 初始化视频区域信息
  aboutToAppear() {
    // 获取视频区域原始坐标
    const videoArea: Point[] | undefined = sdk.GetDrawableArea();
    if (videoArea && videoArea.length >= 2) {
      // 计算视频实际宽高
      const originalWidth = videoArea[1].x - videoArea[0].x;
      const originalHeight = videoArea[2].y - videoArea[0].y;

      // 初始化中心原点坐标系统参数
      videoWidth = this.getUIContext().px2vp(originalWidth);
      videoHeight = this.getUIContext().px2vp(originalHeight);
      maxX = videoArea[1].x; // x轴最大值
      minX = videoArea[0].x; // x轴最小值
      maxY = videoArea[2].y; // y轴最大值
      minY = videoArea[0].y; // y轴最小值
    }
    // 初始化吸附位置
    this.adsorbPosX = [minX + Constant.PADDING_WIDTH, 0, maxX - Constant.PADDING_WIDTH];
    this.adsorbPosY = [minY + Constant.PADDING_HEIGHT, 0, maxY - Constant.PADDING_HEIGHT];
    this.stickerX = this.getUIContext().px2vp(this.sticker.screenWidth);
    this.stickerY = this.getUIContext().px2vp(this.sticker.screenHeight);
    this.widthFromSDK = this.sticker.width;
    this.heightFromSDK = this.sticker.height;
    this.angle = this.sticker.rotation || 0;
  }

  panStart(event: GestureEvent) {
    if (!event.fingerList?.[0] || this.curGestureState !== GestureState.NONE) {
      this.isPanReject = true;
      return;
    }
    this.isPanReject = false;
    this.curGestureState = GestureState.PAN;
    this.panStartX = this.stickerX;
    this.panStartY = this.stickerY;
    this.panStartGlobalX = event.fingerList[0].globalX;
    this.panStartGlobalY = event.fingerList[0].globalY;
  }

  panUpdate(event: GestureEvent) {
    if (this.isPanReject || !event.fingerList?.[0]) {
      return;
    }
    if (Math.abs(this.lastGestureTimestamp - event.timestamp) < Constant.GESTURE_UPDATE_INTERVAL) {
      return;
    }
    this.lastGestureTimestamp = event.timestamp;

    // 计算坐标
    let deltaX = event.fingerList[0].globalX - this.panStartGlobalX;
    let deltaY = event.fingerList[0].globalY - this.panStartGlobalY;
    UtilLog.info(0xFF00, 'VideoClip',
      `panStartGlobalX: ${this.panStartGlobalX},panStartGlobalY: ${this.panStartGlobalY}`);
    UtilLog.info(0xFF00, 'VideoClip', `globalX: ${event.fingerList[0].globalX},globalY: ${event.fingerList[0].globalY}`);
    UtilLog.info(0xFF00, 'VideoClip', `deltaX: ${deltaX},deltaY: ${deltaY}`);
    let newX = this.panStartX + deltaX;
    let newY = this.panStartY + deltaY;
    UtilLog.info(0xFF00, 'VideoClip', `newX: ${newX},newY: ${newY}`);
    // 限制在视频范围内
    newX = this.calcRealPosX(newX);
    newY = this.calcRealPosY(newY);

    // 应用吸附
    this.panEndX = this.panXAdsorb(newX);
    this.panEndY = this.panYAdsorb(newY);

    // 更新位置
    this.stickerX = this.panEndX;
    this.stickerY = this.panEndY;
    this.sticker.offsetX = this.panEndX;
    this.sticker.offsetY = this.panEndY;
  }

  panEnd() {
    if (this.isPanReject) {
      return;
    }
    this.curGestureState = GestureState.NONE;
    this.stickerX = this.panEndX;
    this.stickerY = this.panEndY;
    this.sticker.offsetX = this.panEndX;
    this.sticker.offsetY = this.panEndY;
    sdk.MoveImage(this.sticker.id, this.getUIContext().vp2px(this.sticker.offsetX),
      this.getUIContext().vp2px(this.sticker.offsetY));
  }

  pinchStart(event: GestureEvent) {
    this.curGestureState = GestureState.PINCH;
    this.isPanReject = true;
    this.pinchStartScale = this.curPinchValue; // 记录当前缩放值作为起始点
    UtilLog.info(0xFF00, 'VideoClip', `StickerManage', 'pinchStart current scale: ${this.curPinchValue}`);
  }

  pinchUpdate(event: GestureEvent) {
    if (event) {
      // 基于起始缩放值计算新的缩放值，避免跳变
      this.pinchValue = this.pinchStartScale * event.scale;
      // 限制缩放范围，防止过小或过大
      this.pinchValue = Math.max(0.1, Math.min(this.pinchValue, 3.0));

      sdk.ScaleImage(this.sticker.id, this.pinchValue);
      UtilLog.info(0xFF00, 'VideoClip', `StickerManage', 'StickerManage', 'pinchStart current scale: ${this.pinchValue}`);
    }
  }

  pinchEnd() {
    UtilLog.info(0xFF00, 'VideoClip', `StickerManage', 'StickerManage', 'pinchEnd: ${this.pinchValue}`);
    this.curGestureState = GestureState.NONE;
    this.curPinchValue = this.pinchValue;
    sdk.ScaleImage(this.sticker.id, this.pinchValue);
  }

  rotateStart() {
    this.curGestureState = GestureState.ROTATE;
    this.isPanReject = true;
    this.rotateStartAngle = this.rotateEndAngle;
  }

  rotateUpdate(event: GestureEvent) {
    if (event) {
      if (Math.abs(this.lastGestureTimestamp - event.timestamp) < Constant.GESTURE_UPDATE_INTERVAL) {
        return;
      }
      this.curGestureState = GestureState.ROTATE;
      this.lastGestureTimestamp = event.timestamp;

      // 计算新角度（累加基准角度）
      let endAngle = Number((((this.rotateStartAngle + event.angle) % 360 + 360) % 360).toFixed(1));
      this.rotateEndAngle = this.rotatingAdsorb(endAngle);

      // 同步角度信息
      this.angle = this.rotateEndAngle;
      this.sticker.rotation = this.rotateEndAngle;
      sdk.RotateImage(this.sticker.id, this.rotateEndAngle);
    }
  }

  rotateEnd() {
    this.curGestureState = GestureState.NONE;
    this.angle = this.rotateEndAngle;
    this.sticker.rotation = this.rotateEndAngle;
    sdk.RotateImage(this.sticker.id, this.rotateEndAngle);
  }

  // 限制x坐标在范围内
  calcRealPosX(panPosX: number): number {
    const limitedMinX = this.getUIContext().px2vp(minX); // 左边界
    const limitedMaxX = this.getUIContext().px2vp(maxX); // 右边界
    UtilLog.info(0xFF00, 'VideoClip', `minX = ${limitedMinX},MaxX = ${limitedMaxX}`);
    return Math.max(limitedMinX, Math.min(panPosX, limitedMaxX));
  }

  // 限制y坐标在范围内（
  calcRealPosY(panPosY: number): number {
    // 考虑贴纸高度，确保不超出边界
    const limitedMinY = this.getUIContext().px2vp(minY); // 上边界
    const limitedMaxY = this.getUIContext().px2vp(maxY); // 下边界
    return Math.max(limitedMinY, Math.min(panPosY, limitedMaxY));
  }

  public getRotateDegree(centerPointX: number, centerPointY: number, startX: number, startY: number, endX: number,
    endY: number) {
    let leftX: number = startX - centerPointX;
    let leftY: number = startY - centerPointY;
    let rightX: number = endX - centerPointX;
    let rightY: number = endY - centerPointY;
    // 计算点积
    const dotProduct = leftX * rightX + leftY * rightY;
    const magnitudeLeft = Math.sqrt(leftX * leftX + leftY * leftY);
    const magnitudeRight = Math.sqrt(rightX * rightX + rightY * rightY);
    if (magnitudeLeft === 0 || magnitudeRight === 0) {
      return 0;
    }
    let cosTheta = dotProduct / (magnitudeLeft * magnitudeRight);
    cosTheta = Math.max(Math.min(cosTheta, 1), -1);
    const angleRadians = Math.acos(cosTheta);
    const angleDgress = angleRadians * (180 / Math.PI);
    const crossProduct = leftX * rightY + leftY * rightX;
    return crossProduct > 0 ? angleDgress : -angleDgress;
  }

  // x轴吸附逻辑
  private panXAdsorb(panPos: number): number {
    let numIndex: number = -1;
    for (let index = 0; index < this.adsorbPosX.length; index++) {
      // 旋转状态下不吸附左右边界
      if (this.angle && (index === 0 || index === this.adsorbPosX.length - 1)) {
        continue;
      }
      // 吸附判断
      if (Math.abs(this.adsorbPosX[index] - panPos) < Constant.ADSORPTION_POS) {
        numIndex = index;
        break;
      }
    }
    this.xAdsorbType = numIndex;
    if (numIndex === -1) {
      this.isXAdsorb = false;
      return panPos;
    }
    // 吸附时震动反馈
    if (!this.isXAdsorb || this.adsorbXValue !== this.adsorbPosX[numIndex]) {
      vibrateById('haptic.camera.click');
    }
    this.isXAdsorb = true;
    this.adsorbXValue = this.adsorbPosX[numIndex];
    return this.adsorbPosX[numIndex];
  }

  // y轴吸附逻辑
  private panYAdsorb(panPos: number): number {
    let numIndex: number = -1;
    for (let index = 0; index < this.adsorbPosY.length; index++) {
      // 旋转状态下不吸附上下边界
      if (this.angle && (index === 0 || index === this.adsorbPosY.length - 1)) {
        continue;
      }
      // 吸附判断
      if (Math.abs(this.adsorbPosY[index] - panPos) < Constant.ADSORPTION_POS) {
        numIndex = index;
        break;
      }
    }
    this.yAdsorbType = numIndex;
    if (numIndex === -1) {
      this.isYAdsorb = false;
      return panPos;
    }
    // 吸附时震动反馈
    if (!this.isYAdsorb || this.adsorbYValue !== this.adsorbPosY[numIndex]) {
      vibrateById('haptic.camera.click');
    }
    this.isYAdsorb = true;
    this.adsorbYValue = this.adsorbPosY[numIndex];
    return this.adsorbPosY[numIndex];
  }

  private isAdsorption(num: number): number {
    for (let index = 0; index < Constant.ADSORB_ANGLES.length; index++) {
      if (Math.abs(Constant.ADSORB_ANGLES[index] - num) < Constant.ADSORPTION_ANGLE) {
        return Constant.ADSORB_ANGLES[index] % 360;
      }
    }
    return -1;
  }

  private rotatingAdsorb(angle: number): number {
    let num = this.isAdsorption(angle);
    if (num !== -1) {
      if (!this.isAnhleAdsorb || this.adsorbAngleValue !== num) {
        vibrateById('haptic.camera.click');
      }
      this.isAnhleAdsorb = true;
      this.adsorbAngleValue = num;
      return this.adsorbAngleValue % 360;
    }
    this.isAnhleAdsorb = false;
    return angle;
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Image(this.sticker.uri)
        .objectFit(ImageFit.Contain)
        .width(64)
        .height(64)
        .rotate({ angle: this.rotateEndAngle })
        .scale({ x: this.pinchValue, y: this.pinchValue, z: 1 })
        .stickerGestureGroup(this)
        .onClick(() => {
          this.sticker.isSelected = true;
        });

      Image($r('app.media.clear')).size({ width: 16, height: 16 }).offset({ x: 4, y: -4 }).onClick(() => {
        this.vm.deleteSticker(this.sticker.id);
      });
    }.zIndex(2)
    .visibility(this.remove ? Visibility.None : Visibility.Visible).position({
      x: this.stickerX - this.getUIContext().px2vp(this.sticker.width / 2),
      y: this.stickerY - this.getUIContext().px2vp(this.sticker.height / 2),
    });
  }
}

@Extend(Image)
function stickerGestureGroup(stickerManage: StickerManage) {
  .gesture(GestureGroup(GestureMode.Exclusive,
    TapGesture({ count: 1 })
      .onAction((event: GestureEvent) => {
        if (event.fingerList?.[0]) {
          stickerManage.currentLocalX = event.fingerList?.[0]?.localX;
          stickerManage.currentLocalY = event.fingerList?.[0]?.localY;
          stickerManage.sticker.isSelected = !stickerManage.sticker.isSelected;
        }
      }),
    GestureGroup(GestureMode.Parallel,
      PanGesture({ fingers: 1 })
        .onActionStart((event: GestureEvent) => {
          stickerManage.panStart(event);
        })
        .onActionUpdate((event: GestureEvent) => {
          stickerManage.panUpdate(event);
        })
        .onActionEnd((event: GestureEvent) => {
          stickerManage.panEnd();
        })
        .onActionCancel(() => {
          stickerManage.panEnd();
        }),

      PinchGesture({ fingers: 2 })
        .onActionStart((event: GestureEvent) => {
          stickerManage.pinchStart(event);
        })
        .onActionUpdate((event: GestureEvent) => {
          stickerManage.pinchUpdate(event);
        })
        .onActionEnd((event: GestureEvent) => {
          stickerManage.pinchEnd();
        })
        .onActionCancel(() => {
        }),
      RotationGesture({ fingers: 2 })
        .onActionStart((event: GestureEvent) => {
          stickerManage.rotateStart();
        })
        .onActionUpdate((event: GestureEvent) => {
          stickerManage.rotateUpdate(event);
        })
        .onActionEnd((event: GestureEvent) => {
          stickerManage.rotateEnd();
        })
        .onActionCancel(() => {
          stickerManage.rotateEnd();
        }),
    ),
  ));
}

function vibrateById(id: string) {
  try {
    vibrator.isSupportEffect(id, (err: BusinessError, state: boolean) => {
      if (err) {
        return;
      }
      if (state) {
        vibrate(id);
      }
    });
  } catch (err) {
    return;
  }
}

function vibrate(id: string) {
  try {
    vibrator.startVibration({
      type: 'preset',
      effectId: id,
      count: 1,
    }, {
      usage: 'unknown',
    }, (error: BusinessError) => {
      if (error) {
        UtilLog.info(0xFF00, 'VideoClip', `failed to start vibration`);
      } else {
        UtilLog.info(0xFF00, 'VideoClip', `success in starting vibration`);
      }
    });
  } catch (err) {
    UtilLog.info(0xFF00, 'VideoClip', `an unexpected error occurred, error code : ${err?.code}`);
  }
}
