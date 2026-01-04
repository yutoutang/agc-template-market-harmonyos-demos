import {
  AxisBase,
  AxisDependency,
  BarChart,
  BarData,
  BarDataSet,
  BarEntry,
  EntryOhos,
  EventType,
  Highlight,
  IBarDataSet,
  JArrayList,
  OnChartValueSelectedListener,
  XAxisPosition,
  YAxis
} from '@ohos/mpchart'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DateType } from '../../constant/DateConstant'
import { CharDataModel } from '../../model/ChartDataModel'
import { BarChartOptions } from '../../model/BarChartOptions'
import { Utils } from '../../utils/Utils'
import { DateBarChartModel } from './DateBarChartModel'

/**
 * 按时、周、月展示柱状图
 */
@ComponentV2
export struct DateBarChart {
  /**
   * 柱状图显示类型按日，周，月
   */
  @Param @Require dateType: DateType
  /**
   * 类型为日时装载每小时数据，按周（周一至周日）,月时装载每天数据
   */
  @Param @Require data: CharDataModel[]
  /**
   * 柱状图表相关配置
   */
  @Param options: BarChartOptions | undefined = undefined
  /**
   * 选中柱状
   */
  @Param selectedIndex: number = 0
  /**
   * 选中的数据
   */
  @Event onSelectedData: (data: CharDataModel) => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }
  private dateBarChartModel: DateBarChartModel = new DateBarChartModel()
  // 构造数据选择监听器
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (entryOhos: EntryOhos, highlight: Highlight) => {
      const selectedData = entryOhos.getData() as CharDataModel
      this.onSelectedData(selectedData)
    },
    onNothingSelected: () => {
      hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
    }
  }

  aboutToAppear(): void {
    // 初始化图表
    this.initChart()
    // 加载图表数据
    this.loadChart()
  }

  private initChart() {
    // 设置图表数据模型
    this.setBarDataModel()
    // 设置图表右Y轴信息
    this.setRightYAxis()
    // 配置左侧Y轴信息
    this.configureLeftAxis()
    // 配置X轴信息
    this.configureXAxis()
    // 配置图表设置
    this.configureChartSettings()
  }

  /**
   * 配置左侧Y轴信息
   */
  private configureLeftAxis(): void {
    const leftAxis = this.dateBarChartModel.getAxisLeft()
    if (leftAxis) {
      leftAxis.setEnabled(false)
    }
  }

  /**
   * 配置X轴信息
   */
  private configureXAxis(): void {
    const xAxis = this.dateBarChartModel.getXAxis()
    if (!xAxis) {
      return
    }

    xAxis.setPosition(XAxisPosition.BOTTOM)
    xAxis.setAxisMinimum(0)
    xAxis.setGranularity(1)
    xAxis.setDrawGridLines(false)
    xAxis.setDrawLabels(true)

    // 设置X轴数值格式化器
    xAxis.setValueFormatter({
      getFormattedValue: (value: number, axis: AxisBase): string => {
        return this.getXAxisLabelText(value, axis)
      }
    })

    const resourceManager = Utils.getResourceManager(this)
    const axisLineColor = this.options?.xAxisLineColor ?? resourceManager.getColorSync($r('app.color.axis_line_color'))

    xAxis.setTextColor(this.options?.xAxisTextColor ?? axisLineColor)
    xAxis.setAxisLineColor(axisLineColor)
    xAxis.setTextSize(this.options?.xAxisTextSize ?? 8)
    xAxis.setAxisLineWidth(this.options?.xAxisLineWidth ?? 1)
    xAxis.setAvoidFirstLastClipping(true)
    xAxis.setEnabled(true)
  }

  /**
   * 获取X轴标签文本
   * @param value
   * @param axis
   * @returns
   */
  private configureChartSettings(): void {
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    if (this.options?.maxXRange) {
      this.dateBarChartModel.setVisibleXRangeMaximum(this.options.maxXRange)
    }

    //关闭取消选中功能
    this.dateBarChartModel.setUnSelectEnabled(false)
  }

  /**
   * 设置图表数据模型
   */
  private setBarDataModel() {
    // 为图表添加数据选择的监听器
    this.dateBarChartModel.setOnChartValueSelectedListener(this.valueSelectedListener)
    // 获取图表图例部件，设置图表图例部件不可用
    this.dateBarChartModel.getLegend()?.setEnabled(false)
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    // 是否绘制图表的背景色，绘制范围为图表柱状图的绘制范围，不包含轴线之外的部分
    this.dateBarChartModel.setDrawGridBackground(false)
    // 为图表添加手势识别监听器
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    this.dateBarChartModel.getDescription()?.setEnabled(false)
    // 设置图表的背景色，颜色的规格需要满足CanvasRenderingContext2D.fillstyle/strokestyle规格
    // 设置不绘制柱状图的柱体阴影背景
    this.dateBarChartModel.setDrawBarShadow(false)
    // 设置柱状图的数值在柱体上方
    this.dateBarChartModel.setDrawValueAboveBar(false)
    this.dateBarChartModel.setHighlightPerTapEnabled(true)
    // 设置柱状图的高亮范围是否为整个柱体，只在堆叠柱状图中有区别
    this.dateBarChartModel.setHighlightFullBarEnabled(false)
    this.dateBarChartModel.setDoubleTapToZoomEnabled(false)
    this.dateBarChartModel.setHighlightPerDragEnabled(true)
    this.dateBarChartModel.setScaleEnabled(false)
    this.dateBarChartModel.setHighLightLine(this.options?.highLightLine ?? false)
  }

  // 设置图表右Y轴信息
  private setRightYAxis() {
    const rightAxis = this.dateBarChartModel.getAxisRight()
    if (!rightAxis) {
      return
    }

    this.configureYAxisBaseStyle(rightAxis)
    this.configureYAxisLabels(rightAxis)
    this.configureYAxisLimits(rightAxis)
  }

  // 配置Y轴信息
  private configureYAxisBaseStyle(rightAxis: YAxis) {
    rightAxis.setDrawGridLines(true)

    const yAxisLineColor = this.options?.yAxisLineColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.y_axis_Line_Color'))
    rightAxis.setAxisLineColor(yAxisLineColor)
    rightAxis.setGridColor(yAxisLineColor)

    const yAxisTextColor = this.options?.yAxisTextColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.y_axis_Line_Color'))
    rightAxis.setTextColor(yAxisTextColor)

    rightAxis.setTextSize(this.options?.yAxisTextSize ?? 8)
    rightAxis.setAxisLineWidth(this.options?.yAxisLineWidth ?? 1)
    rightAxis.setAxisMinimum(0)
    rightAxis.setDrawAxisLine(true)
    rightAxis.setSpaceTop(15)
  }

  /**
   * 配置Y轴标签信息
   * @param rightAxis
   */
  private configureYAxisLabels(rightAxis: YAxis) {
    if (this.options?.yAxisLabelCount) {
      rightAxis.setLabelCount(this.options.yAxisLabelCount, false)
    }
  }

  /**
   * 配置Y轴限制信息
   * @param rightAxis
   */
  private configureYAxisLimits(rightAxis: YAxis) {
    if (this.options?.yAxisMaximum) {
      rightAxis.setAxisMaximum(this.options.yAxisMaximum)
    }
  }

  //  加载图表数据
  @Monitor('data')
  loadChart() {
    // 生成单一颜色数据
    let barData = this.generateBarData()
    // 将数据与图表配置类绑定
    this.dateBarChartModel.setData(barData)
    if (this.options?.autoHighlight) {
      for (let index = this.data.length - 1; index >= 0; index--) {
        const val = this.data[index].data
        if (val > 0) {
          this.selectBar(index)
          return
        }
      }
    } else {
      this.selectBar(this.selectedIndex)
    }
  }

  @Monitor('selectedIndex')
  selectedIndexChanged() {
    this.selectBar(this.selectedIndex)
  }

  private selectBar(index: number) {
    //移动x轴
    this.dateBarChartModel.moveViewToX(index + 1)
    //选中高亮
    this.dateBarChartModel.highlightValue(index + 1, 0, 0, true)
  }

  private generateBarData(): BarData {
    let barEntryList: JArrayList<BarEntry> = new JArrayList<BarEntry>()
    this.data.forEach((item, index) => {
      barEntryList.add(new BarEntry(index + 1, item.data, undefined, item))
    })

    const barDataSet: BarDataSet = this.getBarDataSet(barEntryList)

    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>()
    dataSetList.add(barDataSet)
    let barData: BarData = new BarData(dataSetList)
    if (this.options?.barWidth) {
      barData.setBarWidth(this.options?.barWidth)
    }
    if (this.options?.barTopRadius) {
      barData.setTopRadius(this.options?.barTopRadius)
    }
    return barData
  }

  getBarDataSet(barEntryList: JArrayList<BarEntry>): BarDataSet {
    const barDataSet = new BarDataSet(barEntryList, 'BarDataSet')
    barDataSet.setDrawIcons(false)
    barDataSet.setColorByColor(this.options?.barColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.barColor')))
    barDataSet.setHighLightAlpha(255);
    barDataSet.setHighLightColor(this.options?.barHighLightColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.bar_high_light_color')))
    barDataSet.setDrawValues(false);
    barDataSet.setAxisDependency(AxisDependency.RIGHT)
    return barDataSet
  }

  weekLabel: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

  getXAxisLabelText(value: number, axis: AxisBase): string {
    // 防御性检查
    if (value < 0) {
      return '';
    }

    switch (this.dateType) {
      case DateType.WEEK:
        return this.getWeekLabel(value);
      case DateType.MONTH:
        return this.getMonthLabel(value);
      default: // DAY类型
        return this.getDayLabel(value);
    }
  }

  private getWeekLabel(value: number): string {
    return this.weekLabel[value - 1] ?? '';
  }

  private getMonthLabel(value: number): string {
    const length = this.data.length;

    // 判断是否需要显示标签
    if (this.shouldShowMonthLabel(value, length)) {
      const index = this.getMonthDataIndex(value, length);
      const item = this.data[index];
      return item ? Utils.formatDate(item.date) : '';
    }
    return '';
  }

  private shouldShowMonthLabel(value: number, length: number): boolean {
    return (value <= 25 && value % 5 === 0) ||
      value === length ||
      value === 30 ||
      value === 1 ||
      value === 0;
  }

  private getMonthDataIndex(value: number, length: number): number {
    if (value === 0) {
      return 0;
    }
    if (value === 30) {
      return length - 1;
    }
    return value - 1;
  }

  private getDayLabel(value: number): string {
    switch (value) {
      case 0:
      case 1:
        return '00:00'
      case 4:
        return '04:00'
      case 6:
        return '06:00'
      case 8:
        return '08:00'
      case 12:
        return '12:00'
      case 16:
        return '16:00'
      case 18:
        return '18:00'
      case 20:
        return '20:00'
      case 24:
        return '23:00'
      default:
        return ''
    }
  }

  build() {
    BarChart({ model: this.dateBarChartModel, customUiTriggerEvent: EventType.SingleTap })
      .width('100%')
      .height('100%')
  }
}