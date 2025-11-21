export interface ProtractorParam {
  radius?: number,  // 半径
  startAngle?: number, // 起始角度
  endAngle?: number,  // 终止角度（大于起始角度）
  startValue?: number,  // 起始刻度值
  endValue?: number, // 终止刻度值
  step?: number, // 刻度步长
  centerX?: number,  // 圆心X坐标
  centerY?: number,  // 圆心Y坐标
  textColor?: string, // 字体颜色
  lineColor?: string, // 量角器颜色
  textFontSize?: string, // 字体大小
}

export class ProtractorController {
  private contextCanvas:CanvasRenderingContext2D = new CanvasRenderingContext2D();
  centerX: number;
  centerY: number;
  private radius: number;
  private startAngle: number;
  private endAngle: number;
  private startValue: number;
  private endValue: number;
  private step: number;
  private pointerAngle: number;  // 指针旋转的角度
  private measureAngleValue: number;  // 角度测量值
  private textColor: string;
  private textFontSize: string;
  private lineColor: string ;

  constructor(protractorParam:ProtractorParam) {
    this.centerX = protractorParam?.centerX || 0;
    this.centerY = protractorParam?.centerY || 0;
    this.radius = protractorParam.radius || 0;
    this.startAngle = protractorParam.startAngle|| 0;
    this.endAngle = protractorParam.endAngle|| 0;
    this.startValue = protractorParam.startValue || 0;
    this.endValue = protractorParam.endValue || 0;
    this.step = protractorParam.step || 0;
    this.textColor = protractorParam.textColor || '#00ff00';
    this.lineColor = protractorParam.lineColor || '#00ff00';
    this.textFontSize = protractorParam.textFontSize || '30px';
    this.pointerAngle = this.startAngle;
    this.measureAngleValue = this.startAngle;
  }

  updateParam(protractorParam:ProtractorParam) {
    this.centerX = protractorParam?.centerX !== undefined?protractorParam?.centerX:this.centerX;
    this.centerY = protractorParam?.centerY !== undefined?protractorParam?.centerY:this.centerY;
    this.radius = protractorParam.radius !== undefined?protractorParam.radius:this.radius;
    this.startAngle = protractorParam.startAngle !== undefined?protractorParam.startAngle:this.startAngle;
    this.endAngle = protractorParam.endAngle !== undefined?protractorParam.endAngle:this.endAngle;
    this.startValue = protractorParam.startValue !== undefined?protractorParam.startValue:this.startValue;
    this.endValue = protractorParam.endValue !== undefined?protractorParam.endValue:this.endValue;
    this.step = protractorParam.step !== undefined?protractorParam.step:this.step;
    this.pointerAngle = this.startAngle;
    this.measureAngleValue = this.startAngle;
  }

  getCanvasContext() {
    return this.contextCanvas;
  }

  /**
   * 绘制量角器
   */
  drawProtractor() {
    this.clearCanvas();
    this.drawArc();
    this.drawScale();
    this.drawText();
    this.drawPointer();
  }

  /**
   * 画圆弧
   */
  drawArc() {
    this.contextCanvas.strokeStyle = this.lineColor;
    this.contextCanvas.beginPath();
    this.contextCanvas.arc(
      this.centerX,
      this.centerY,
      this.radius,
      this.startAngle*Math.PI/180,
      this.endAngle*Math.PI/180
    );
    this.contextCanvas.stroke();
  }

  /**
   * 绘制刻度值
   */
  drawText() {
    let distance = Math.abs(this.endAngle - this.startAngle)
    distance = distance < 360?distance + this.step: distance;
    for (let index = 0; index < distance; index += this.step) {

      const x = this.centerX + Math.cos((this.startAngle + index) * Math.PI / 180) * (this.radius - 20);
      const y = this.centerY + Math.sin((this.startAngle + index) * Math.PI / 180) * (this.radius - 20);
      // 计算旋转角度，使得文字沿圆弧方向正确显示
      const rotationAngle = (this.startAngle + index) * Math.PI / 180 + Math.PI / 2; // 加90度，使得文字水平显示
      this.contextCanvas.save(); // 保存当前环境的状态
      this.contextCanvas.font = this.textFontSize
      this.contextCanvas.fillStyle = this.textColor;
      this.contextCanvas.translate(x, y); // 移动画布到当前字符的位置
      const text = this.startValue > this.endValue? this.startValue - index: this.startValue + index;
      const textWidth = this.contextCanvas.measureText(String(text)).width;

      this.contextCanvas.rotate(rotationAngle); // 旋转画布使得文字水平显示
      this.contextCanvas.fillText(String(text), -textWidth / 2, 0); // 在原点绘制文字，此时画布已旋转，文字会沿圆弧方向显示
      this.contextCanvas.restore(); // 恢复之前保存的画布状态
    }
  }

  /**
   * 绘制刻度线
   */
  drawScale() {
    for (let degree = this.startAngle; degree <= this.endAngle; degree += 1) {
      const length = degree%10 === 0?6:3;
      const radian = degree * Math.PI / 180;
      const startX = this.centerX + (this.radius - length) * Math.cos(radian);
      const startY = this.centerY + (this.radius - length) * Math.sin(radian);
      const endX = this.centerX + this.radius * Math.cos(radian);
      const endY = this.centerY + this.radius * Math.sin(radian);
      this.contextCanvas.moveTo(startX, startY);
      this.contextCanvas.lineTo(endX, endY);
      this.contextCanvas.stroke();
    }
  }

  /**
   * 绘制指针
   */
  drawPointer() {
    const pointerRadian =  this.pointerAngle * Math.PI / 180
    this.contextCanvas.beginPath();
    this.contextCanvas.moveTo(this.centerX, this.centerY);
    this.contextCanvas.lineTo(
      this.centerX + this.radius * Math.cos(pointerRadian),
      this.centerY + this.radius * Math.sin(pointerRadian)
    );
    this.contextCanvas.stroke();
  }

  /**
   * 计算手指滑动与圆心的夹角
   */
  calculateAngle(touchX:number, touchY:number) {
    const dx = touchX - this.centerX;
    const dy = touchY - this.centerY;
    let radian = Math.atan2(dy, dx);
    this.pointerAngle = (radian * 180 / Math.PI+360)%360;
  }

  /**
   * 判断指针是否可以移动
   * @returns
   */
  canPointerMove():boolean {
    if (this.pointerAngle <= this.startAngle && this.pointerAngle + 360 <= this.endAngle) {
      return true;
    }
    if (this.pointerAngle >= this.startAngle && this.pointerAngle <= this.endAngle) {
      return true;
    }
    return false;


  }

  /**
   * 清空画布
   */
  clearCanvas() {
    this.contextCanvas.clearRect(0,0,this.contextCanvas.width, this.contextCanvas.height);
  }

  /**
   * 计算旋转的角度
   */
  calculateAngleValue() {
    let angle = Math.abs(this.pointerAngle - this.startAngle - this.startValue);
    if (this.pointerAngle < this.startAngle) {
      angle = Math.abs(this.pointerAngle + 360 - this.startValue - this.startAngle);
    }

    this.measureAngleValue = angle;
  }

  /**
   * 获取测量角度值
   * @returns
   */
  getMeasureValue():number {
    return this.measureAngleValue;
  }
}