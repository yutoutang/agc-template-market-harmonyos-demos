
/**
 * 填充弧形数据
 */
export default class FillArcData {
  /**
   * 弧形中心的 x 轴坐标
   */
  x: number
  /**
   * 弧形中心的 y 轴坐标
   */
  y: number
  /**
   * 弧形的半径
   */
  radius: number
  /**
   * 弧形的起始点，以弧度表示
   */
  startAngle: number
  /**
   * 弧形的终点，以弧度表示
   */
  endAngle: number

  constructor(x: number, y: number, radius: number, startAngle: number, endAngle: number) {
    this.x = x
    this.y = y
    this.radius = radius
    this.startAngle = startAngle
    this.endAngle = endAngle
  }
}