/**
 * 所有功能的通用常量
 */
export default class CommonConstants {
  /**
   * COIN_120 图像 URL
   */
  static readonly COIN_120_IMAGE_URL: string = 'resources/base/media/coin_120.svg'
  /**
   * 变换角度
   */
  static readonly TRANSFORM_ANGLE: number = -120
  /**
   * 360°
   */
  static readonly CIRCLE: number = 360
  /**
   * 180°
   */
  static readonly HALF_CIRCLE: number = 180
  /**
   * 分块数量
   */
  static readonly COUNT: number = 6
  /**
   * 小圆数量
   */
  static readonly SMALL_CIRCLE_COUNT: number = 8
  /**
   * 图像大小
   */
  static readonly IMAGE_SIZE: number = 28
  /**
   * 奖品角度
   */
  static readonly ANGLE: number = 270
  /**
   * 持续时间
   */
  static readonly DURATION: number = 4000
  /**
   * 1
   */
  static readonly ONE: number = 1
  /**
   * 2
   */
  static readonly TWO: number = 2
  /**
   * 3
   */
  static readonly THREE: number = 3
  /**
   * 4
   */
  static readonly FOUR: number = 4
  /**
   * 5
   */
  static readonly FIVE: number = 5
  /**
   * 6
   */
  static readonly SIX: number = 6
  /**
   * 花瓣点 Y 轴比例
   */
  static readonly FLOWER_POINT_Y_RATIOS: number = 0.255
  /**
   * 花瓣半径比例
   */
  static readonly FLOWER_RADIUS_RATIOS: number = 0.217
  /**
   * 花瓣内半径比例
   */
  static readonly FLOWER_INNER_RATIOS: number = 0.193
  /**
   * 外圆比例
   */
  static readonly OUT_CIRCLE_RATIOS: number = 0.4
  /**
   * 小圆比例
   */
  static readonly SMALL_CIRCLE_RATIOS: number = 0.378
  /**
   * 小圆半径
   */
  static readonly SMALL_CIRCLE_RADIUS: number = 4.1
  /**
   * 内圆比例
   */
  static readonly INNER_CIRCLE_RATIOS: number = 0.356
  /**
   * 内白圆比例
   */
  static readonly INNER_WHITE_CIRCLE_RATIOS: number = 0.339
  /**
   * 内弧形比例
   */
  static readonly INNER_ARC_RATIOS: number = 0.336
  /**
   * 图像 dx 比例
   */
  static readonly IMAGE_DX_RATIOS: number = 0.114
  /**
   * 图像 dy 比例
   */
  static readonly IMAGE_DY_RATIOS: number = 0.052
  /**
   * 文本起始角度
   */
  static readonly ARC_START_ANGLE: number = 30
  /**
   * 文本对齐方式
   */
  static readonly TEXT_ALIGN: CanvasTextAlign = 'center'
  /**
   * 文本基线
   */
  static readonly TEXT_BASE_LINE: CanvasTextBaseline = 'middle'
  /**
   * Canvas 字体
   */
  static readonly CANVAS_FONT: string = 'px sans-serif'
}

/**
 * 枚举值
 */
export enum EnumeratedValue {
  ONE = 1,
  TWO = 2,
  THREE = 3,
  FOUR = 4,
  FIVE = 5,
  SIX = 6
}