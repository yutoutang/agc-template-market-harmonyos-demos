import image from '@ohos.multimedia.image';
import { TimerCommonConstants } from '../constants/TimerCommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ComponentV2
export struct TimeShow {
  @Param allCount: number = TimerCommonConstants.NUMBER_360
  @Param nowCount: number = TimerCommonConstants.NUMBER_0
  pathStack: NavPathStack = new NavPathStack();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private renderContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  // 画布大小
  private canvasSize: number = TimerCommonConstants.CANVAS_SIZE;
  private clockRadius: number = this.canvasSize / 2;
  // 资源文件路径
  private resourceDir: string = getContext(this).resourceDir;
  // 时钟图片对应的PixelMap
  private clockPixelMap: image.PixelMap | null = null;
  private secondPixelMap: image.PixelMap | null = null;

  @Monitor('nowCount')
  onChangeTabIndex() {
    if (this.allCount >= this.nowCount) {
      this.renderContext.clearRect(-this.clockRadius, -this.clockRadius, this.canvasSize, this.canvasSize);
      this.paintDial();
      this.paintPin((TimerCommonConstants.NUMBER_360 / this.allCount) * this.nowCount, this.secondPixelMap);
    }
  }

  aboutToAppear(): void {
    this.init();
  }

  build() {

    Column() {
      Canvas(this.renderContext)
        .width(this.canvasSize)
        .aspectRatio(TimerCommonConstants.CANVAS_ASPECT_RATIO)
        .onReady(() => {
          this.renderContext.translate(this.clockRadius, this.clockRadius);
        })
    }
    .width(TimerCommonConstants.PERCENT_100)
  }

  /**
   * 初始化表盘和表针对应的变量，并首次绘制。
   */
  private async init() {
    try {
      const clockBgSource = image.createImageSource(this.resourceDir + '/plate.png');
      const secondSource = image.createImageSource(this.resourceDir + '/pointer.png');

      // 创建表盘对应的PixelMap并绘制。
      let paintDial = clockBgSource.createPixelMap().then((pixelMap: image.PixelMap) => {
        this.clockPixelMap = pixelMap;
        this.paintDial();
      })

      // 创建秒针对应的PixelMap并绘制。
      secondSource.createPixelMap().then(async (pixelMap: image.PixelMap) => {
        await paintDial;
        this.paintPin(0, pixelMap);
        this.secondPixelMap = pixelMap;
      })
    } catch (error) {
      hilog.error(0x0000, 'TimeShow', 'init error');
    }
  }

  /**
   * 绘制表盘
   */
  private paintDial() {
    this.renderContext.beginPath();
    if (this.clockPixelMap) {
      this.renderContext.drawImage(
        this.clockPixelMap,
        -this.clockRadius,
        -this.clockRadius,
        this.canvasSize,
        this.canvasSize)
    }
  }

  /**
   * 绘制表针
   */
  private paintPin(degree: number, pinImgRes: image.PixelMap | null) {
    // TODO：知识点：先将当前绘制上下文保存再旋转画布，先保存旋转前的状态，避免状态混乱。
    this.renderContext.save();
    const angleToRadian = Math.PI / 180;
    let theta = degree * angleToRadian;
    this.renderContext.rotate(theta);

    this.renderContext.beginPath();
    if (pinImgRes) {
      this.renderContext.drawImage(
        pinImgRes,
        -TimerCommonConstants.IMAGE_WIDTH,
        -this.clockRadius,
        20,
        this.canvasSize);
    }
    this.renderContext.restore();
  }
}
