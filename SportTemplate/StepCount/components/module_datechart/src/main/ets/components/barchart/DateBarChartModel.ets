import { BarChartModel, EntryOhos, Highlight } from '@ohos/mpchart';
import { DateBarChartRenderer } from './DateBarChartRenderer';

export class DateBarChartModel extends BarChartModel {
  private onSelectedXAxisX?: (x: number) => void
  private unSelectEnabled: boolean = true
  private onCanHighlightListener?: (high: Highlight) => boolean

  public constructor() {
    super()

    //自定义柱状体渲染器
    const dateBarChartRenderer = new DateBarChartRenderer(this, this.mAnimator!, this.mViewPortHandler)
    dateBarChartRenderer.setOnSelectedXAxisXListener((x) => {
      if (this.onSelectedXAxisX) {
        this.onSelectedXAxisX(x)
      }
    })
    this.setRenderer(dateBarChartRenderer)
  }

  setDateChartListener(onSelectedXAxisX: (x: number) => void) {
    this.onSelectedXAxisX = onSelectedXAxisX
  }

  /**
   * 是否开启取消选中功能
   * @param enabled
   */
  setUnSelectEnabled(enabled: boolean) {
    this.unSelectEnabled = enabled
  }

  setOnCanHighlightListener(isCanHighlight: (high: Highlight) => boolean) {
    this.onCanHighlightListener = isCanHighlight
  }

  setHighLightLine(show: boolean) {
    (this.getRenderer() as DateBarChartRenderer)?.setHighlightLine(show)
  }

  public highlightValue(x: number, dataSetIndex: number, stackIndex: number, callListener?: boolean): void {
    this.highlightValueForObject(new Highlight(x, 0, dataSetIndex, 0, stackIndex, 0, 0, null), callListener)
  }

  public highlightValueForObject(high: Highlight | null, callListener?: boolean) {
    //未开启取消选中功能直接return
    if (high === null && !this.unSelectEnabled) {
      return
    }

    //判断是否能选中
    if (high !== null && this.onCanHighlightListener) {
      if (!this.onCanHighlightListener(high)) {
        return
      }
    }

    this.processHighlightLogic(high, callListener);
    // redraw the chart
    this.invalidateHighlight();
  }

  private processHighlightLogic(high: Highlight | null, callListener?: boolean) {
    if (callListener === null || callListener === undefined) {
      callListener = false;
    }
    let e: EntryOhos | null = null;

    if (high === null) {
      this.mIndicesToHighlight = null;
    } else {

      // 缺失方法
      if (this.mData) {
        e = this.mData.getEntryForHighlight(high);
        if (e === null) {
          this.mIndicesToHighlight = null;
          high = null;
        } else {
          this.mIndicesToHighlight = [high];
        }
      }
    }
    if (this.mIndicesToHighlight) {
      this.setLastHighlighted(this.mIndicesToHighlight);
    }

    if (callListener && this.mSelectionListener !== null) {
      let isHighLight = this.valuesToHighlight();
      if (!isHighLight) {
        this.mSelectionListener.onNothingSelected();
      } else {
        if (this.mSelectionListener && e && high) {
          this.mSelectionListener.onValueSelected(e, high);
        }
      }
    }

  }
}