export interface BarChartOptions {
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
   * 柱状体选中时的颜色
   */
  barHighLightColor?: number
  /**
   * 柱状体的颜色
   */
  barColor?: number
  /**
   * 柱状体的宽度0-1
   */
  barWidth?: number
  /**
   * 柱状体顶部圆角半径
   */
  barTopRadius?: number
  /**
   * 自动高亮最近一条数据
   */
  autoHighlight?: boolean
  /**
   * Y轴最大值
   */
  yAxisMaximum?: number
  /**
   * 是否显示高亮辅助线
   */
  highLightLine?: boolean
}