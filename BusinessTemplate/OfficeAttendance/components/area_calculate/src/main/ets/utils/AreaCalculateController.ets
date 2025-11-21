
export interface Pointer {
  pointerX: number,
  pointerY: number,
}

export class AreaCalculateController {
  contextCanvas:CanvasRenderingContext2D;
  fontSize: string = '12vp';  // 标注字体大小
  fontColor: string = '#000000'; // 标注字体颜色
  areaBgColor: string = 'rgba(0,111,111,0.4)'; // 面积区域背景色
  lineWidth: number = 1;  // 边宽
  lineColor: string = '#00ff00'; // 边颜色
  pointRadius: number = 5; // 定点半径
  pointColor: string = '#00ff00'; // 顶点颜色
  currentPointX: number | null = null; // 点击X坐标
  currentPointY: number | null = null; // 点击Y坐标
  originPointX: number | null = null;  // 第一个点X坐标
  originPointY: number | null = null;  // 第一个点Y坐标
  pointers: Pointer[] = []; // 所有坐标点的集合
  drawEnd: boolean = false; // 多边形闭合绘制完毕
  referenceLength: number = 0; // 根据两点坐标算的基准边的长度
  markLength: number = 0; // 实际标注基准边的长度
  referencePoint:Pointer[] = []; // 基准边两端点坐标
  unit: string = 'mm'; // 标注单位
  borderClickCallBack:Function; // 选择基准边后的回调函数


  constructor(contextCanvas:CanvasRenderingContext2D, borderClickCallBack:Function) {
    this.contextCanvas = contextCanvas;
    this.borderClickCallBack = borderClickCallBack;
  }

  /**
   * 根据点击位置绘制点线
   * @param centerX 点击X坐标
   * @param centerY 点击Y坐标
   */
  draw(centerX:number, centerY: number) {
    if (this.drawEnd) {
      this.checkClickBorder(centerX, centerY);
      return;
    }
    const isOriginPointer = this.isOriginPointer(centerX, centerY);
    const x = isOriginPointer?this.originPointX as number:centerX;
    const y = isOriginPointer?this.originPointY as number:centerY;
    this.currentPointX !== null && this.drawLine(this.currentPointX as number, this.currentPointY as number, x, y)
    !isOriginPointer?  this.drawPointer(centerX, centerY):this.drawBackground();
    this.currentPointX = centerX;
    this.currentPointY = centerY;
  }

  /**
   * 画点
   * @param centerX
   * @param centerY
   */
  drawPointer(centerX:number, centerY: number, reDraw:boolean = false) {
    this.contextCanvas.fillStyle = this.pointColor
    this.contextCanvas.beginPath();
    this.contextCanvas.arc(centerX, centerY, this.pointRadius, 0, Math.PI * 2)
    this.contextCanvas.fill();
    this.contextCanvas.stroke();
    if (!reDraw) {
      this.savePointer(centerX, centerY)
    }
  }

  /**
   * 画线
   * @param startX
   * @param startY
   * @param endX
   * @param endY
   */
  drawLine(startX:number, startY:number, endX: number, endY:number) {
    this.contextCanvas.beginPath();
    this.contextCanvas.moveTo(startX,startY);
    this.contextCanvas.lineTo(endX,endY);
    this.contextCanvas.lineWidth = this.lineWidth;
    this.contextCanvas.strokeStyle = this.lineColor;
    this.contextCanvas.stroke();
  }

  /**
   * 判断是否是起始点，如果是绘制结束
   * @param pointerX
   * @param pointerY
   * @returns
   */
  isOriginPointer(pointerX:number,pointerY: number) {
    if (this.originPointX === null || this.originPointY === null) {
      this.originPointX = pointerX;
      this.originPointY = pointerY;
      return false;
    }
    const dx = pointerX - (this.originPointX as number);
    const dy = pointerY - (this.originPointY as number);
    this.drawEnd = Math.sqrt(dx * dx + dy * dy) <= 8*this.pointRadius;
    return this.drawEnd;
  }

  /**
   * 给多边形添加背景色
   */
  drawBackground() {
    this.contextCanvas.beginPath();
    this.pointers.forEach((item:Pointer,index: number) => {
      if (index === 0) {
        this.contextCanvas.moveTo(item.pointerX, item.pointerY)
      } else {
        this.contextCanvas.lineTo(item.pointerX, item.pointerY)
      }
    })
    this.contextCanvas.closePath();
    this.contextCanvas.fillStyle = this.areaBgColor;
    this.contextCanvas.fill();
  }

  /**
   * 存储绘制的点
   * @param pointerX
   * @param pointerY
   */
  savePointer(pointerX:number, pointerY: number) {
    this.pointers.push({pointerX: pointerX, pointerY: pointerY})
  }

  /**
   * 设置标注
   * @param startPoint
   * @param endPointer
   */
  setLabel(startPoint:Pointer, endPointer:Pointer) {
    const dx = startPoint.pointerX - endPointer.pointerX;
    const dy = startPoint.pointerY - endPointer.pointerY;
    const d = Math.sqrt(dx*dx + dy*dy);
    const label = (this.markLength*(d/this.referenceLength)).toFixed(2);
    const x = (startPoint.pointerX + endPointer.pointerX)/2;
    const y = (startPoint.pointerY + endPointer.pointerY)/2;
    const angle = Math.atan2(startPoint.pointerX - endPointer.pointerX, startPoint.pointerY - endPointer.pointerY)
    const rotationAngle = angle + Math.PI / 2; // 加90度，使得文字水平显示
    this.contextCanvas.save(); // 保存当前环境的状态
    this.contextCanvas.font = this.fontSize;
    this.contextCanvas.fillStyle = this.fontColor;
    this.contextCanvas.translate(x, y); // 移动画布到当前字符的位置
    const text = label+this.unit;
    const textWidth = this.contextCanvas.measureText(text).width;
    this.contextCanvas.rotate(-rotationAngle); // 旋转画布使得文字水平显示
    this.contextCanvas.fillText(text, -textWidth/2, -10); // 在原点绘制文字，此时画布已旋转，文字会沿圆弧方向显示
    this.contextCanvas.restore(); // 恢复之前保存的画布状态
  }

  /**
   * 给所有点添加标注
   */
  setLabels() {
    if (this.referencePoint.length === 0) {
      return;
    }
    this.reDraw();
    const pointA = this.referencePoint[0];
    const pointB = this.referencePoint[1]
    const x = pointA.pointerX - pointB.pointerX;
    const y = pointA.pointerY - pointB.pointerY;
    this.referenceLength = Math.sqrt(x * x + y * y);
    this.pointers.forEach((item:Pointer, index:number) => {
      if (index === this.pointers.length - 1) {
        this.setLabel(item, this.pointers[0])
      } else {
        this.setLabel(item, this.pointers[index+1])
      }
    })
  }

  /**
   * 检测是否点击多边形的某一条边
   * @param centerX
   * @param centerY
   * @returns
   */
  checkClickBorder(centerX: number, centerY: number) {
    const epsilon = 0.002;
    let pointA:Pointer | undefined = undefined;
    let pointB:Pointer | undefined = undefined;
    this.pointers.forEach((item:Pointer,index: number) => {
      const isLast = index === this.pointers.length - 1;
      const A:ESObject = {x: item.pointerX, y: item.pointerY};
      const B:ESObject = {x: this.pointers[isLast?0:index+1].pointerX, y: this.pointers[isLast?0:index+1].pointerY};
      const C:ESObject = {x: centerX, y: centerY};

      // 验证坐标范围：检查点C是否在线段AB的包围盒内
      const minX = Math.min(A.x, B.x) - epsilon;
      const maxX = Math.max(A.x, B.x) + epsilon;
      const minY = Math.min(A.y, B.y) - epsilon;
      const maxY = Math.max(A.y, B.y) + epsilon;
      if ((C.x >= minX && C.x <= maxX && C.y >= minY && C.y <= maxY)) {
        if (index === this.pointers.length - 1) {
          pointA = item;
          pointB = this.pointers[0];
        } else {
          pointA = item;
          pointB = this.pointers[index+1];
        }
      }
    })
    if (pointA && pointB) {
      this.referencePoint.length = 0;
      this.referencePoint.push(pointA);
      this.referencePoint.push(pointB);
      this.borderClickCallBack()
    }
  }

  /**
   * 计算多边形面积
   * @returns
   */
  calculatePolygonArea(): number {
    let area = 0;
    const n = this.pointers.length;
    for (let i = 0; i < n; i++) {
      const x1 = ((this.pointers[i].pointerX)/this.referenceLength)*this.markLength;
      const y1 = ((this.pointers[i].pointerY)/this.referenceLength)*this.markLength;
      const x2 = ((this.pointers[(i + 1) % n].pointerX)/this.referenceLength)*this.markLength;
      const y2 = ((this.pointers[(i + 1) % n].pointerY)/this.referenceLength)*this.markLength;
      area += (x1 * y2 - x2 * y1);
    }
    return Math.abs(area) / 2;
  }

  /**
   * 清楚画布
   */
  clear() {
    this.contextCanvas.clearRect(0,0,this.contextCanvas.width,this.contextCanvas.height)
  }

  /**
   * 重置
   */
  reset() {
    this.clear();
    this.currentPointX = null;
    this.currentPointY = null;
    this.originPointX = null;
    this.originPointY = null;
    this.pointers = [];
    this.drawEnd = false;
    this.referenceLength = 0;
    this.markLength = 0;
    this.referencePoint = [];
  }

  /**
   * 重新绘制图形
   */
  reDraw() {
    this.clear();
    this.pointers.forEach((item:Pointer, index: number) => {
      const nextPointX =  index === this.pointers.length - 1?this.originPointX:this.pointers[index+1].pointerX;
      const nextPointY = index === this.pointers.length - 1?this.originPointY:this.pointers[index+1].pointerY;
      this.drawLine(item.pointerX, item.pointerY, nextPointX as number, nextPointY as number)

      this.drawPointer(item.pointerX, item.pointerY, true);

    })
    this.drawBackground();
  }
}