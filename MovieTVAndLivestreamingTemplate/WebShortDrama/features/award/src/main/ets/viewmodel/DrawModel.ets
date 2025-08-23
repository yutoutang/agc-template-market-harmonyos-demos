import CommonConstants from '../constants/CommonConstants'
import { EnumeratedValue } from '../constants/CommonConstants'
import ColorConstants from '../constants/ColorConstants'
import StyleConstants from '../constants/StyleConstants'
import PrizeData from '../model/PrizeData'
import FillArcData from '../model/FillArcData'
import Logger from '../utils/Logger'
import CheckEmptyUtils from '../utils/CheckEmptyUtils'
import StrConstants from '../constants/StrConstants'

/**
 * Canvas 绘图方法类
 */
export default class DrawModel {
  private startAngle: number = 0
  private avgAngle: number = CommonConstants.CIRCLE / CommonConstants.COUNT
  private screenWidth: number = 0
  private canvasContext?: CanvasRenderingContext2D

  /**
   * 绘制抽奖转盘
   *
   * @param canvasContext
   * @param screenWidth 绘制宽度
   * @param screenHeight 绘制高度
   */
  draw(canvasContext: CanvasRenderingContext2D, screenWidth: number, screenHeight: number) {
    if (CheckEmptyUtils.isEmptyObj(canvasContext) || screenWidth <= 0 || screenHeight <= 0) {
      Logger.error('[DrawModel][draw] canvasContext 为空')
      return
    }
    this.canvasContext = canvasContext
    this.screenWidth = screenWidth
    this.canvasContext.clearRect(0, 0, this.screenWidth, screenHeight)
    this.canvasContext.translate(this.screenWidth / CommonConstants.TWO,
      screenHeight / CommonConstants.TWO)
    this.drawFlower()
    this.drawOutCircle()
    this.drawInnerCircle()
    this.drawInnerArc()
    this.drawArcText()
    this.drawImage()
    this.canvasContext.translate(-this.screenWidth / CommonConstants.TWO,
      -screenHeight / CommonConstants.TWO)
  }

  /**
   * 绘制弧形
   *
   * @param fillArcData 弧形区域参数
   * @param fillColor 弧形区域颜色
   */
  fillArc(fillArcData: FillArcData, fillColor: string) {
    if (CheckEmptyUtils.isEmptyObj(fillArcData) || CheckEmptyUtils.isEmptyStr(fillColor)) {
      Logger.error('[DrawModel][fillArc] fillArcData 或 fillColor 为空')
      return
    }
    if (this.canvasContext !== undefined) {
      this.canvasContext.beginPath()
      this.canvasContext.fillStyle = fillColor
      this.canvasContext.arc(fillArcData.x, fillArcData.y, fillArcData.radius,
        fillArcData.startAngle, fillArcData.endAngle)
      this.canvasContext.fill()
    }
  }

  /**
   * 绘制外盘花瓣
   */
  drawFlower() {
    let beginAngle = this.startAngle + this.avgAngle
    const pointY = this.screenWidth * CommonConstants.FLOWER_POINT_Y_RATIOS
    const radius = this.screenWidth * CommonConstants.FLOWER_RADIUS_RATIOS
    const innerRadius = this.screenWidth * CommonConstants.FLOWER_INNER_RATIOS
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.canvasContext?.save()
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE)
      this.fillArc(new FillArcData(0, -pointY, radius, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.FLOWER_OUT_COLOR)

      this.fillArc(new FillArcData(0, -pointY, innerRadius, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.FLOWER_INNER_COLOR)
      beginAngle += this.avgAngle
      this.canvasContext?.restore()
    }
  }

  /**
   * 绘制外盘和小圆
   */
  drawOutCircle() {
    // 绘制外盘
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.OUT_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.OUT_CIRCLE_COLOR)

    let beginAngle = this.startAngle
    // 绘制小圆
    for (let i = 0; i < CommonConstants.SMALL_CIRCLE_COUNT; i++) {
      this.canvasContext?.save()
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE)
      this.fillArc(new FillArcData(this.screenWidth * CommonConstants.SMALL_CIRCLE_RATIOS, 0,
        CommonConstants.SMALL_CIRCLE_RADIUS, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.WHITE_COLOR)
      beginAngle = beginAngle + CommonConstants.CIRCLE / CommonConstants.SMALL_CIRCLE_COUNT
      this.canvasContext?.restore()
    }
  }

  /**
   * 绘制内盘
   */
  drawInnerCircle() {
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.INNER_CIRCLE_COLOR)
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_WHITE_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.WHITE_COLOR)
  }

  /**
   * 绘制内部扇形抽奖区域
   */
  drawInnerArc() {
    let colors = [
      ColorConstants.ARC_PINK_COLOR, ColorConstants.ARC_YELLOW_COLOR,
      ColorConstants.ARC_GREEN_COLOR, ColorConstants.ARC_PINK_COLOR,
      ColorConstants.ARC_YELLOW_COLOR, ColorConstants.ARC_GREEN_COLOR
    ]
    let radius = this.screenWidth * CommonConstants.INNER_ARC_RATIOS
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.fillArc(new FillArcData(0, 0, radius, this.startAngle * Math.PI / CommonConstants.HALF_CIRCLE,
        (this.startAngle + this.avgAngle) * Math.PI / CommonConstants.HALF_CIRCLE), colors[i])
      this.canvasContext?.lineTo(0, 0)
      this.canvasContext?.fill()
      this.startAngle += this.avgAngle
    }
  }

  /**
   * 在内部扇形区域内绘制文本
   */
  drawArcText() {
    if (this.canvasContext !== undefined) {
      this.canvasContext.textAlign = CommonConstants.TEXT_ALIGN
      this.canvasContext.textBaseline = CommonConstants.TEXT_BASE_LINE
      this.canvasContext.fillStyle = ColorConstants.TEXT_COLOR
      this.canvasContext.font = StyleConstants.ARC_TEXT_SIZE + CommonConstants.CANVAS_FONT
    }
    let textArrays = [
      StrConstants.TEXT_COIN18,
      StrConstants.TEXT_COIN38,
      StrConstants.TEXT_COIN68,
      StrConstants.TEXT_COIN18,
      StrConstants.TEXT_COIN188,
      StrConstants.TEXT_COIN888
    ]
    let arcTextStartAngle = CommonConstants.ARC_START_ANGLE
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.drawCircularText((textArrays[i]),
        (this.startAngle + arcTextStartAngle) * Math.PI / CommonConstants.HALF_CIRCLE)
      this.startAngle += this.avgAngle
    }
  }



  /**
   * 绘制圆周文本
   *
   * @param textString 文本内容
   * @param startAngle 开始位置
   * @param endAngle 结束位置
   */
  drawCircularText(textString: string, startAngle: number) {
    if (CheckEmptyUtils.isEmptyStr(textString)) {
      Logger.error('[DrawModel][drawCircularText] textString 为空')
      return
    }

    class CircleText {
      x: number = 0
      y: number = 0
      radius: number = 0
    }

    let circleText: CircleText = {
      x: 0,
      y: 0,
      radius: this.screenWidth * CommonConstants.INNER_ARC_RATIOS
    }
    // 圆的半径
    let radius = circleText.radius - circleText.radius / CommonConstants.COUNT
    let angle = startAngle
    this.canvasContext?.save()
    this.canvasContext?.beginPath()
    this.canvasContext?.translate(circleText.x + Math.cos(angle) * radius,
      circleText.y - Math.sin(angle) * radius)
    this.canvasContext?.rotate(Math.PI / CommonConstants.TWO - angle)
    this.canvasContext?.fillText(textString, 0, 0)
    this.canvasContext?.restore()
  }

  /**
   * 在内部扇形区域内绘制与奖品对应的图片
   */
  drawImage() {
    let beginAngle = this.startAngle
    let imageSrc = [
      CommonConstants.COIN_120_IMAGE_URL, CommonConstants.COIN_120_IMAGE_URL,
      CommonConstants.COIN_120_IMAGE_URL, CommonConstants.COIN_120_IMAGE_URL,
      CommonConstants.COIN_120_IMAGE_URL, CommonConstants.COIN_120_IMAGE_URL
    ]
    let images = imageSrc.map(src => new ImageBitmap(src))
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      let image = new ImageBitmap(imageSrc[i])
      this.canvasContext?.save()
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE)
      this.canvasContext?.drawImage(image, this.screenWidth * CommonConstants.IMAGE_DX_RATIOS,
        this.screenWidth * CommonConstants.IMAGE_DY_RATIOS, CommonConstants.IMAGE_SIZE,
        CommonConstants.IMAGE_SIZE)
      beginAngle += this.avgAngle
      this.canvasContext?.restore()
    }
    images.forEach(image => image.close())
  }

  /**
   * 显示奖品信息
   *
   * @param randomAngle 旋转角度
   */
  showPrizeData(randomAngle: number): PrizeData {
    for (let i = 1; i <= CommonConstants.COUNT; i++) {
      if (randomAngle <= i * this.avgAngle) {
        return this.getPrizeData(i)
      }
    }
    return new PrizeData()
  }

  /**
   * 获取奖品信息
   *
   * @param scopeNum 奖品号码
   */
  getPrizeData(scopeNum: number): PrizeData {
    let prizeData: PrizeData = new PrizeData()
    switch (scopeNum) {
      case EnumeratedValue.ONE:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN888
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      case EnumeratedValue.TWO:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN188
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      case EnumeratedValue.THREE:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN18
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      case EnumeratedValue.FOUR:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN68
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      case EnumeratedValue.FIVE:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN38
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      case EnumeratedValue.SIX:
        prizeData.message = StrConstants.PRIZE_TEXT_COIN18
        prizeData.imageSrc = CommonConstants.COIN_120_IMAGE_URL
        break
      default:
        break
    }
    return prizeData
  }
}