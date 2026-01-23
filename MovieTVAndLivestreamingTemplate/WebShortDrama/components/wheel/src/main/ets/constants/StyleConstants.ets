import { window } from '@kit.ArkUI'
/**
 * 所有组件的样式常量
 */

const windowStage: window.WindowStage = AppStorage.get('windowStage')!

export default class StyleConstants {
  /**
   * 字体粗细
   */
  static readonly FONT_WEIGHT: number = 500
  /**
   * 100%
   */
  static readonly FULL_PERCENT: string = '100%'
  /**
   * 背景图像尺寸
   */
  static readonly BACKGROUND_IMAGE_SIZE: string = '38.7%'
  /**
   * 中心圆图像宽度
   */
  static readonly CENTER_IMAGE_WIDTH: string = '19.3%'
  /**
   * 中心圆图像高度
   */
  static readonly CENTER_IMAGE_HEIGHT: string = '19.3%'
  /**
   * 弧形文本大小
   */
  static readonly ARC_TEXT_SIZE: number = windowStage.getMainWindowSync().getUIContext().fp2px(10)
}