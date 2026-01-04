import {
  BarChartRenderer,
  BarData,
  BarEntry,
  Highlight,
  IBarDataSet,
  MPPointD,
  Range,
  Style,
  Transformer,
  Utils
} from '@ohos/mpchart';

export class DateBarChartRenderer extends BarChartRenderer {
  private onSelectedXAxisX?: (x: number) => void
  private showHighLightLine: boolean = false

  setOnSelectedXAxisXListener(onSelectedXAxisX: (x: number) => void) {
    this.onSelectedXAxisX = onSelectedXAxisX
  }

  setHighlightLine(show: boolean) {
    this.showHighLightLine = show
  }

  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {

    if (!this.mChart) {
      return;
    }
    let barData: BarData | null = this.mChart.getBarData();
    if (!barData) {
      return;
    }

    for (let i = 0; i < indices.length; i++) {
      this.drawHighlightedItem(c, indices[i], barData);
    }
  }

  private drawHighlightedItem(c: CanvasRenderingContext2D, high: Highlight, barData: BarData): void {
    let set: IBarDataSet | null = barData.getDataSetByIndex(high.getDataSetIndex());
    if (!this.mChart) {
      return;
    }
    if (set === null || !set.isHighlightEnabled()) {
      return;
    }

    let e: BarEntry | null = set.getEntryForXValue(high.getX(), high.getY());
    if (!e) {
      return;
    }
    if (!this.isInBoundsX(e, set)) {
      return;
    }

    let trans: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
    if (!trans) {
      return;
    }
    // 绘制高亮
    this.setupHighlightPaint(set);

    let isStack: boolean = (high.getStackIndex() >= 0 && e.isStacked()) ? true : false;

    let y1: number = 0;
    let y2: number = 0;

    let drawRadius: boolean = false;
    let radius = barData.getTopRadius();

    if (isStack) {

      if (this.mChart.isHighlightFullBarEnabled()) {

        y1 = e.getPositiveSum();
        y2 = -e.getNegativeSum();

      } else {
        let dataRanges: Range[] | null = e.getRanges();
        if (dataRanges) {
          let range: Range = dataRanges[high.getStackIndex()];
          //堆叠柱状图顶部的柱形绘制圆角
          if (radius !== 0 && high.getStackIndex() === dataRanges.length - 1) {
            drawRadius = true;
          }
          y1 = range.myfrom;
          y2 = range.to;
        }
      }
    } else {
      if (radius !== 0) {
        drawRadius = true;
      }
      y1 = e.getY();
      y2 = 0.0;
    }

    // 计算高亮矩形
    this.prepareBarHighlight(e.getX(), y1, y2, barData.getBarWidth() / 2, trans);
    // 处理圆角
    const cornerType = this.determineCornerType(e, set);
    // 绘制高亮矩形
    this.drawHighlightRect(c, drawRadius, radius, cornerType);

    this.setHighlightDrawPos(high, this.mBarRect);
    //  绘制高亮线
    this.drawHighlightIndicator(c, high, e, set, trans)
    // 处理回到函数
    this.notifyXAxisSelection()
  }

  // 绘制高亮矩形
  private drawHighlightRect(c: CanvasRenderingContext2D, drawRadius: boolean, radius: number,
    cornerType: 'up' | 'down' | 'both'): void {
    if (this.mBarRect) {
      Utils.drawFillRect(drawRadius, c, this.mHighlightPaint, this.mBarRect.left, this.mBarRect.top,
        this.mBarRect.right, this.mBarRect.bottom, radius, cornerType);
    }
  }

  // 确定圆角类型
  private determineCornerType(e: BarEntry, set: IBarDataSet): 'up' | 'down' | 'both' {
    if (!this.mChart) {
      return 'up';
    }
    const isInverted: boolean = this.mChart?.isInverted(set.getAxisDependency());

    if (isInverted) {
      return e.getY() > 0 ? 'down' : 'up';
    } else {
      return e.getY() > 0 ? 'up' : 'down';
    }
  }

  // 处理回到函数
  private notifyXAxisSelection(): void {
    if (this.onSelectedXAxisX) {
      this.onSelectedXAxisX(this.mBarRect.left);
    }
  }

  // 绘制高亮
  private setupHighlightPaint(set: IBarDataSet): void {
    let highLightColor: number = set.getHighLightColor();
    if (highLightColor === 0) {
      highLightColor = Color.Black
    }
    this.mHighlightPaint.setColor(highLightColor);
    this.mHighlightPaint.setGlobalAlpha(set.getHighLightAlpha() / 255);
  }

  //  绘制高亮线
  private drawHighlightIndicator(c: CanvasRenderingContext2D, high: Highlight, e: BarEntry, set: IBarDataSet,
    trans: Transformer): void {
    if (!this.showHighLightLine) {
      return;
    }

    const phaseY = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    const pix: MPPointD = trans.getPixelForValues(e.getX(), e.getY() * phaseY);

    try {
      high.setDraw(pix.x, pix.y);
      // draw the lines
      this.drawHighlightLines(set, c, pix.x, pix.y);
    } finally {
      MPPointD.recycleInstance(pix);
    }
  }

  //============


  protected drawHighlightLines(set: IBarDataSet, c: CanvasRenderingContext2D, x: number, y: number): void {
    let highLightColor = set.getHighLightColor();
    if (typeof highLightColor === 'number') {
      let stringColor = String(highLightColor.toString(16))
      this.mHighlightPaint.setColor('#' + stringColor);
    } else {
      this.mHighlightPaint.setColor(highLightColor);
    }
    this.mHighlightPaint.styleType = Style.FILL_AND_STROKE;
    this.mHighlightPaint.globalAlpha = 0.5
    Utils.resetContext2DWithoutFont(c, this.mHighlightPaint)

    c.beginPath();
    c.moveTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0));
    c.lineTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0));
    c.stroke();
    c.closePath();
    c.beginPath();
    c.moveTo((this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0), y);
    c.lineTo((this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0), y);

    c.stroke();
    c.closePath();
  }
}