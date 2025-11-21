import { display } from '@kit.ArkUI';

export interface CrossPointer {
  pointerX: number,
  pointerY: number,
}

export interface RulerProperty {
  lineWidth?:number; // 线宽
  lineColor?:string; // 线颜色
  fontSize?: string; // 字体大小
  fontColor?: string; // 字体颜色
  resultFontColor?: string; // 测量结果字体颜色
  extraScaleLength?: number; // 长刻度线比短刻度线多出的长度
  crossPointer: CrossPointer; // 横向和纵向刻度尺的交点（0刻度位置）
}

export class RulerController {
  static mmWidthPX:number = 0; // 屏幕高度一毫米有多少px
  static screenHeightPX = 0; // 屏幕高度（以像素为单位）
  static screenHeightMM = 0; // 屏幕高度的物理长度（mm）
  static screenWidthPX = 0; // 屏幕的宽度（以像素为单位）
  contextCanvas:CanvasRenderingContext2D;
  rulerPointers:number[][] = [];
  lineWidth: number = 1;  // 边宽
  lineColor: string = '#00ff00'; // 边颜色
  fontSize: string = '30px';
  fontColor: string = '#000000';
  resultFontColor: string = '#fff';
  extraScaleLength: number = 5;
  shotScaleLength:number = 15; // 短可刻度线长度

  crossPointer:CrossPointer = {  // 原点位置（0刻度开始的位置）
    pointerX: 15,
    pointerY: 15
  };

  constructor(contextCanvas:CanvasRenderingContext2D, rulerProperty: RulerProperty) {
    RulerController.mm2px();
    this.contextCanvas = contextCanvas;
    this.updateProperty(rulerProperty);
  }

  /**
   * 绘制刻度尺
   */
  drawRuler() {
    this.rulerPointers.forEach((line:number[]) => {
      this.drawLine(line[0],line[1],line[2],line[3])
    })
    this.drawOrigin();
  }

  /**
   * 设置两条尺子的边线
   * @param rulerPointers
   */
  setRulerPointers(rulerPointers:number[][]) {
    this.rulerPointers = rulerPointers;
  }

  /**
   * 更新刻度尺的属性
   * @param rulerProperty
   */
  updateProperty(rulerProperty: RulerProperty) {
    this.crossPointer = rulerProperty.crossPointer || this.crossPointer;
    this.lineWidth = rulerProperty.lineWidth || this.lineWidth;
    this.lineColor = rulerProperty.lineColor || this.lineColor;
    this.fontSize = rulerProperty.fontSize || this.fontSize;
    this.fontColor = rulerProperty.fontColor || this.fontColor;
    this.resultFontColor = rulerProperty.resultFontColor || this.resultFontColor;
    this.extraScaleLength = rulerProperty.extraScaleLength || this.extraScaleLength;
    this.shotScaleLength = rulerProperty.crossPointer?rulerProperty.crossPointer.pointerX:this.crossPointer.pointerX;
  }

  /**
   * 计算实际1mm是多少个px
   */
  static mm2px() {
    let displayClass: display.Display = display.getDefaultDisplaySync()
    // 获取屏幕高度（以像素为单位）
    RulerController.screenHeightPX = displayClass.height;
    RulerController.screenWidthPX = displayClass.width;
    // 获取屏幕的垂直方向的DPI（每英寸点数）
    let dpi = displayClass.yDPI;
    RulerController.screenHeightMM = RulerController.screenHeightPX / dpi * 25.4;
    RulerController.mmWidthPX = dpi / 25.4;
  }

  /**
   * 画线
   * @param startX 起点X坐标
   * @param startY 起点Y坐标
   * @param endX 终点X坐标
   * @param endY 终点Y坐标
   */
  drawLine(startX:number, startY:number, endX: number, endY:number) {
    this.contextCanvas.beginPath();
    this.contextCanvas.moveTo(startX,startY);
    this.contextCanvas.lineTo(endX,endY);
    this.contextCanvas.lineWidth = this.lineWidth;
    this.contextCanvas.strokeStyle = this.lineColor;
    this.contextCanvas.stroke();
    if (startY === endY) {
      this.drawHorizonScale(this.crossPointer.pointerX, this.contextCanvas.width);
    } else {
      this.drawVerticalScale(this.crossPointer.pointerY, this.contextCanvas.height);
    }

  }

  /**
   * 绘制横向尺子刻度线
   */
  drawHorizonScale(startX:number, endX: number) {
    for (let i = startX; i < endX; i += px2vp(RulerController.mmWidthPX)) {
      if (Math.ceil((i-startX)/px2vp(RulerController.mmWidthPX)) < 5) {
        continue;
      }
      const value = Math.floor(((i-startX)/px2vp(RulerController.mmWidthPX))*100)/100
      const isMultipleOfTen = Math.ceil(value)%10 === 0
      const length = isMultipleOfTen?this.shotScaleLength + this.extraScaleLength:this.shotScaleLength;
      this.contextCanvas.moveTo(i, 0);
      this.contextCanvas.lineTo(i, length);
      this.contextCanvas.stroke();
      if (isMultipleOfTen) {
        this.drawText(Math.ceil(value/10), i, length + 10, true);
      }
    }
  }

  /**
   * 绘制竖向尺子刻度线
   */
  drawVerticalScale(startY:number, endY: number) {
    for (let i = startY; i < endY; i += px2vp(RulerController.mmWidthPX)) {
      if (Math.ceil((i-startY)/px2vp(RulerController.mmWidthPX)) < 5) {
        continue;
      }
      const value = Math.floor(((i-startY)/px2vp(RulerController.mmWidthPX))*100)/100
      const isMultipleOfTen = Math.ceil(value)%10 === 0;
      const length = isMultipleOfTen? this.shotScaleLength + this.extraScaleLength:this.shotScaleLength;
      this.contextCanvas.moveTo(0, i);
      this.contextCanvas.lineTo(length, i);
      this.contextCanvas.stroke();
      if (isMultipleOfTen) {
        this.drawText(Math.ceil(value/10),length + 5, i, false);
      }
    }
  }

   /**
    * 绘制刻度值
    * @param text
    * @param x
    * @param y
    * @param isHorizon
    */
  drawText(text:number, x:number, y:number, isHorizon:boolean) {
    this.contextCanvas.save(); // 保存当前环境的状态
    this.contextCanvas.font = this.fontSize;
    this.contextCanvas.fillStyle = this.fontColor;
    this.contextCanvas.translate(x, y); // 移动画布到当前字符的位置
    if (isHorizon) {
      const textWidth = this.contextCanvas.measureText(String(text)).width;
      this.contextCanvas.fillText(String(text), -textWidth / 2, 0);
    } else {
      const textHeight = this.contextCanvas.measureText(String(text)).height;
      this.contextCanvas.fillText(String(text), 0, textHeight / 2); // 在原点绘制文字，此时画布已旋转，文字会
    }
    this.contextCanvas.restore(); // 恢复之前保存的画布状态
  }

  /**
   * 移动测量距离
   * @param x
   * @param y
   */
  moveLine(x:number, y:number) {
    this.contextCanvas.clearRect(0,0, this.contextCanvas.width, this.contextCanvas.height);
    this.drawOrigin();
    this.rulerPointers.forEach((item:number[]) => {
      let isHorizon = false;
      if (item[0] === item[2]) {
        // 竖线
        if (Math.abs(x - item[0]) < 10 && x >= this.crossPointer.pointerX) {
          item[0] = x;
          item[2] = x;
        }
        isHorizon = false;
      } else if (item[1] === item[3]) {
        // 横线
        if (Math.abs(y - item[1]) < 10 && y >= this.crossPointer.pointerY) {
          item[1] = y;
          item[3] = y;
        }
        isHorizon = true;
      }
      this.drawLine(item[0], item[1], item[2], item[3]);
      const startAngle = item[1] === item[3]?90:180;
      const endAngle = item[1] === item[3]?270:360;
      this.drawArc(item[2], item[3], 25, startAngle, endAngle);
      const text = this.calculateDistance(item[0], item[1], item[2], item[3]);
      this.draArcText(Number(text), item[2], item[3], isHorizon)

    })
  }

  /**
   * 绘制显示结果的位置
   * @param x
   * @param y
   * @param radius
   * @param startAngle
   * @param endAngle
   */
  drawArc(x:number, y:number, radius:number, startAngle:number,endAngle:number) {
    this.contextCanvas.strokeStyle = this.lineColor
    this.contextCanvas.fillStyle = this.lineColor
    this.contextCanvas.beginPath();
    this.contextCanvas.arc(
      x,
      y,
      radius,
      startAngle*Math.PI/180,
      endAngle*Math.PI/180
    );
    this.contextCanvas.lineTo(x,y)
    this.contextCanvas.closePath();
    this.contextCanvas.fill()
  }

  /**
   * 绘制测量的实际刻度值
   * @param text
   * @param x
   * @param y
   * @param isHorizon
   */
  draArcText(text:number, x:number, y:number, isHorizon:boolean) {
    this.contextCanvas.save(); // 保存当前环境的状态
    this.contextCanvas.font = this.fontSize;
    this.contextCanvas.fillStyle = this.resultFontColor;
    this.contextCanvas.translate(x, y); // 移动画布到当前字符的位置
    const textWidth = this.contextCanvas.measureText(String(text)+'cm').width;
    const textHeight = this.contextCanvas.measureText(String(text)+'cm').height;
    if (isHorizon) {
      this.contextCanvas.rotate(-90 * Math.PI / 180);
    }
    this.contextCanvas.fillText(String(text)+'cm', -textWidth/2, -textHeight/2);
    this.contextCanvas.restore(); // 恢复之前保存的画布状态
  }

  /**
   * 计算长度
   * @param startX
   * @param startY
   * @param endX
   * @param endY
   * @returns
   */
  calculateDistance(startX:number, startY:number, endX: number, endY:number):number {
    if (startX === endX) {
      // 竖线
      return Math.round((Math.abs(startX-this.crossPointer.pointerX)/px2vp(RulerController.mmWidthPX))*10)/100;
    } else if (startY === endY) {
      // 横线
      return Math.round((Math.abs(startY-this.crossPointer.pointerY)/px2vp(RulerController.mmWidthPX))*10)/100;
    }
    return 0;
  }

  /**
   * 绘制起始刻度交点坐标
   */
  drawOrigin() {
    this.contextCanvas.beginPath();
    this.contextCanvas.moveTo(0, this.crossPointer.pointerY);
    this.contextCanvas.lineTo(this.crossPointer.pointerX + 10,this.crossPointer.pointerY);
    this.contextCanvas.lineWidth = this.lineWidth;
    this.contextCanvas.strokeStyle = this.lineColor;
    this.contextCanvas.stroke();
    this.contextCanvas.closePath();

    this.contextCanvas.beginPath();
    this.contextCanvas.moveTo(this.crossPointer.pointerX,0);
    this.contextCanvas.lineTo(this.crossPointer.pointerX,this.crossPointer.pointerY +10);
    this.contextCanvas.lineWidth = this.lineWidth;
    this.contextCanvas.strokeStyle = this.lineColor;
    this.contextCanvas.stroke();
    this.contextCanvas.closePath();

    this.drawText(0, this.crossPointer.pointerX + 15, this.crossPointer.pointerY +15, true)
  }
}