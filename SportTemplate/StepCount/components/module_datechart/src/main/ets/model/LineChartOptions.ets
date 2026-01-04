import { AxisBase } from '@ohos/mpchart'

/**
 * Y轴数值格式化器接口
 */
export interface YAxisValueFormatter {
  getFormattedValue: (value: number, axis: AxisBase) => string
}

export interface LineChartOptions {
  /**
   * x轴线颜色
   */
  xAxisLineColor?: number
  /**
   * x轴标签文本颜色
   */
  xAxisTextColor?: number
  /**
   * x轴标签字体大小
   */
  xAxisTextSize?: number
  /**
   * x轴线粗细
   */
  xAxisLineWidth?: number
  /**
   * y轴线颜色
   */
  yAxisLineColor?: number
  /**
   * y轴标签文本颜色
   */
  yAxisTextColor?: number
  /**
   * y轴标签字体大小
   */
  yAxisTextSize?: number
  /**
   * y轴线粗细
   */
  yAxisLineWidth?: number
  /**
   * 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
   */
  maxXRange?: number
  /**
   * y轴的标签数量
   */
  yAxisLabelCount?: number
  /**
   * Y轴最大值
   */
  yAxisMaximum?: number
  /**
   * 自定义y轴标签
   */
  customYAxisLabels?: number[]
  /**
   * 是否完全自定义y轴
   */
  enableCustomYAxisLabels?: boolean
  /**
   * Y轴数值格式化器
   */
  yAxisValueFormatter?: YAxisValueFormatter
}