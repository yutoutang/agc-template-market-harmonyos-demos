import {
  AxisBase,
  AxisDependency,
  EntryOhos,
  EventType,
  Highlight,
  ILineDataSet,
  JArrayList,
  LineChart,
  LineChartModel,
  LineData,
  LineDataSet,
  Mode,
  OnChartValueSelectedListener,
  XAxisPosition
} from '@ohos/mpchart'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DateType } from '../../constant/DateConstant'
import { CharDataModel } from '../../model/ChartDataModel'
import { LineChartDataModel } from '../../model/LineChartDataModel'
import { LineChartOptions } from '../../model/LineChartOptions'
import { Utils } from '../../utils/Utils'
import { LineChartMode } from '../../constant/LineChartMode'

/**
 * 按时、周、月展示线形图
 */
@ComponentV2
export struct DateLineChart {
  /**
   * 线形图显示类型按日，周，月
   */
  @Param @Require dateType: DateType
  /**
   * 类型为日时装载每小时数据，按周（周一至周日）,月时装载每天数据
   */
  @Param @Require data: LineChartDataModel[]
  /**
   * 线形图表相关配置
   */
  @Param options: LineChartOptions | undefined = undefined
  /**
   * 线形图表模式
   */
  @Consumer() lineChartMode: LineChartMode = LineChartMode.CUBIC_BEZIER
  /**
   * 选中的数据
   */
  @Event onSelectedData: (data: CharDataModel) => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  }
  /**
   * x轴标签
   */
  @Local xAxisLabels: string[] = []
  /**
   * y轴宽度
   */
  @Local yAxisWidth: number = 0
  /**
   * 表格宽度
   */
  @Local chartWidth: number = 0
  private dateLineChartModel: LineChartModel = new LineChartModel()
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
    this.initChart()
    this.loadChart()
  }

  /**
   * 初始化图表配置
   * 设置图表的基本属性、坐标轴和显示范围
   */
  private initChart() {
    // 初始化图表
    this.setDateLineChartModel()

    // 设置图表右Y轴信息
    this.setRightAxis()

    // 配置坐标轴
    this.configureAxis()

    // 配置图表其他设置
    this.configureChartSettings()
    // this.dateLineChartModel.getAxisLeft()?.setEnabled(false)
    //
    // // 设置X轴信息
    // const xAxis = this.dateLineChartModel.getXAxis()
    // xAxis?.setPosition(XAxisPosition.BOTTOM)
    // xAxis?.setAxisMinimum(0)
    // xAxis?.setGranularity(1)
    // xAxis?.setDrawGridLines(false)
    // //关闭X轴标签显示
    // xAxis?.setDrawLabels(true)
    // // 设置X轴数值格式化器
    // xAxis?.setValueFormatter({
    //   getFormattedValue: (value: number, axis: AxisBase): string => {
    //     return this.getXAxisLabelText(value, axis)
    //   }
    // })
    // xAxis?.setTextColor(this.options?.xAxisTextColor ??
    // Utils.getResourceManager(this).getColorSync($r('app.color.axis_line_color')))
    // xAxis?.setAxisLineColor(this.options?.xAxisLineColor ??
    // Utils.getResourceManager(this).getColorSync($r('app.color.axis_line_color')))
    // xAxis?.setTextSize(this.options?.xAxisTextSize ?? 8)
    // xAxis?.setAxisLineWidth(this.options?.xAxisLineWidth ?? 1)
    // xAxis?.setAvoidFirstLastClipping(true)
    // xAxis?.setEnabled(true)
    //
    // // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    // if (this.options?.maxXRange) {
    //   this.dateLineChartModel.setVisibleXRangeMaximum(this.options?.maxXRange)
    // }
  }

  /**
   * 配置坐标轴相关设置
   * 包括左轴禁用和X轴的各项属性设置
   */
  private configureAxis(): void {
    // 禁用左Y轴
    this.dateLineChartModel.getAxisLeft()?.setEnabled(false)

    // 设置X轴信息
    const xAxis = this.dateLineChartModel.getXAxis()
    if (!xAxis) {
      return
    }

    // 设置X轴位置和基本属性
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

    // 设置X轴颜色和样式
    const resourceManager = Utils.getResourceManager(this)
    const axisLineColor = this.options?.xAxisLineColor ??
    resourceManager.getColorSync($r('app.color.axis_line_color'))

    xAxis.setTextColor(this.options?.xAxisTextColor ?? axisLineColor)
    xAxis.setAxisLineColor(axisLineColor)
    xAxis.setTextSize(this.options?.xAxisTextSize ?? 8)
    xAxis.setAxisLineWidth(this.options?.xAxisLineWidth ?? 1)
    xAxis.setAvoidFirstLastClipping(true)
    xAxis.setEnabled(true)
  }

  /**
   * 配置图表其他相关设置
   * 主要设置X轴的最大显示范围
   */
  private configureChartSettings(): void {
    // 设置图表最大的X轴显示范围，如不设置，则默认显示全部数据
    if (this.options?.maxXRange) {
      this.dateLineChartModel.setVisibleXRangeMaximum(this.options.maxXRange)
    }
  }

  /**
   * 初始化图表模型
   * 设置图表的基本行为和事件监听器
   */
  private setDateLineChartModel(): void {
    // 为图表添加数据选择的监听器
    this.dateLineChartModel.setOnChartValueSelectedListener(this.valueSelectedListener)
    // 为图表添加手势识别监听器
    // 获取图表描述部件，设置图表描述部件不可用，即图表不进行绘制描述部件
    this.dateLineChartModel.getDescription()?.setEnabled(false)
    // 获取图表图例部件，设置图表图例部件不可用
    this.dateLineChartModel.getLegend()?.setEnabled(false)
    // 设置图表数据最大的绘制数，如果超过该数值，则不进行绘制图表的数值标签
    // 是否绘制图表的背景色，绘制范围为图表线形图的绘制范围，不包含轴线之外的部分
    this.dateLineChartModel.setDrawGridBackground(false)
    // 设置图表的背景色，颜色的规格需要满足CanvasRenderingContext2D.fillstyle/strokestyle规格
    this.dateLineChartModel.setHighlightPerTapEnabled(true)
    this.dateLineChartModel.setHighlightPerDragEnabled(true)
    this.dateLineChartModel.setDoubleTapToZoomEnabled(false)
    this.dateLineChartModel.setScaleEnabled(false)
    this.dateLineChartModel.setHardwareAccelerationEnabled(true)
    this.dateLineChartModel.setTouchEnabled(false)
  }

  /**
   * 设置图表右Y轴信息
   * 包括网格线、颜色、标签等属性配置
   */
  private setRightAxis(): void {
    const rightAxis = this.dateLineChartModel.getAxisRight()
    if (!rightAxis) {
      return
    }

    rightAxis.setDrawGridLines(true)
    rightAxis.setAxisLineColor(
      this.options?.yAxisLineColor ??
      Utils.getResourceManager(this).getColorSync($r('app.color.y_axis_Line_Color'))
    )
    rightAxis.setGridColor(
      this.options?.yAxisLineColor ??
      Utils.getResourceManager(this).getColorSync($r('app.color.y_axis_Line_Color'))
    )
    rightAxis.setTextColor(
      this.options?.yAxisTextColor ??
      Utils.getResourceManager(this).getColorSync($r('app.color.y_axis_Line_Color'))
    )
    rightAxis.setTextSize(this.options?.yAxisTextSize ?? 8)
    rightAxis.setAxisLineWidth(this.options?.yAxisLineWidth ?? 1)
    rightAxis.setAxisMinimum(0)
    rightAxis.setDrawAxisLine(true)
    rightAxis.setSpaceTop(15)

    // 设置Y轴标签数量
    this.setYAxisLabelCount(rightAxis)
    // 设置Y轴最大值
    this.setYAxisMaximum(rightAxis)
    // 设置自定义Y轴标签
    if (this.options?.customYAxisLabels) {
      rightAxis?.setCustomYAxisLabels(this.options.customYAxisLabels)
    }
    rightAxis?.setEnableCustomYAxisLabels(this.options?.enableCustomYAxisLabels ?? false)
    // 设置Y轴数值格式化器
    this.setYAxisValueFormatter(rightAxis)
  }

  /**
   * 设置Y轴标签数量
   * @param rightAxis 右Y轴对象
   */
  private setYAxisLabelCount(rightAxis: AxisBase): void {
    if (this.options?.yAxisLabelCount) {
      rightAxis.setLabelCount(this.options.yAxisLabelCount, false)
    }
  }

  /**
   * 设置Y轴最大值
   * @param rightAxis 右Y轴对象
   */
  private setYAxisMaximum(rightAxis: AxisBase): void {
    if (this.options?.yAxisMaximum) {
      rightAxis.setAxisMaximum(this.options.yAxisMaximum)
    }
  }

  /**
   * 设置Y轴数值格式化器
   * @param rightAxis 右Y轴对象
   */
  private setYAxisValueFormatter(rightAxis: AxisBase): void {
    if (this.options?.yAxisValueFormatter) {
      rightAxis.setValueFormatter(this.options.yAxisValueFormatter)
    }
  }

  @Monitor('data')
  loadChart() {
    this.initChart()

    // 生成单一颜色数据
    let lineData = this.generateLineData()
    // 将数据与图表配置类绑定
    this.dateLineChartModel.setData(lineData)

    const paint = this.dateLineChartModel.getRendererRightYAxis()?.getPaintAxisLabels()
    if (paint) {
      this.yAxisWidth = this.dateLineChartModel.getAxisRight()?.getRequiredWidthSpace(paint) ?? 0
    }

    if (this.dateType === DateType.DAY) {
      this.xAxisLabels = ['1', '6', '12', '18', '24']
    } else if (this.dateType === DateType.WEEK) {
      this.xAxisLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    } else if (this.dateType === DateType.MONTH) {
      this.xAxisLabels = ['1', ' 6', '11', '16', '21', '26']
      const index = 0
      const maxLength = this.data[index].dataModel.length
      this.data.forEach((item, index) => {
        if (item.dataModel.length > maxLength) {
          index = index
        }
      })
      const aAxisMaxData = this.data[index].dataModel
      this.xAxisLabels.push(aAxisMaxData[aAxisMaxData.length - 1].date.getDate().toString())
    }
  }

  private generateLineData(): LineData {
    let dataSetList: JArrayList<ILineDataSet> = new JArrayList<ILineDataSet>()
    this.data.forEach((item, index) => {
      let lineEntryList: JArrayList<EntryOhos> = new JArrayList<EntryOhos>()
      item.dataModel.forEach((data, index) => {
        lineEntryList.add(new EntryOhos(index + 1, data.data, undefined, item))
      })
      const lineDataSet = this.getLineDataSet(lineEntryList, item, index)

      dataSetList.add(lineDataSet)
    })
    let lineData: LineData = new LineData(dataSetList)
    return lineData
  }

  getLineDataSet(lineEntryList: JArrayList<EntryOhos>, item: LineChartDataModel, index: number): LineDataSet {
    const lineDataSet = new LineDataSet(lineEntryList, 'LineDataSet' + index)
    lineDataSet.setDrawIcons(false)
    lineDataSet.setColorByColor(item.dataOptions?.lineColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.lineColor')))
    lineDataSet.setHighLightColor(item.dataOptions?.lineHighLightColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.line_high_light_color')))
    lineDataSet.setDrawValues(false);
    lineDataSet.setAxisDependency(AxisDependency.RIGHT)
    lineDataSet.setMode(this.lineChartMode.valueOf())
    lineDataSet.setDrawCircles(true)
    lineDataSet.setLineWidth(item.dataOptions?.lineWidth ?? 2)
    lineDataSet.setDrawCircleHole(false)
    lineDataSet.setCircleColor(item.dataOptions?.lineColor ??
    Utils.getResourceManager(this).getColorSync($r('app.color.lineColor')));
    // 设置半径大小
    lineDataSet.setCircleRadius(item.dataOptions?.circleRadius ?? 2);
    return lineDataSet
  }

  weekLabel: string[] = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

  getXAxisLabelText(value: number, axis: AxisBase): string {
    if (this.dateType === DateType.WEEK) {
      return this.weekLabel[value - 1] ?? ''
    } else if (this.dateType === DateType.MONTH) {

      const index = 0
      const maxLength = this.data[index].dataModel.length
      this.data.forEach((item, index) => {
        if (item.dataModel.length > maxLength) {
          index = index
        }
      })
      const aAxisData = this.data[index].dataModel
      if ((value <= 25 && value % 5 === 0) || value === aAxisData.length || value === 30 || value === 1 ||
        value === 0) {
        const item = aAxisData[value === 0 ? 0 : value - 1]
        if (item) {
          return item.date.getDate().toString()
        } else {
          return ''
        }
      } else {
        return ''
      }
    } else {
      return this.getXAxisCode(value)
    }
  }

  getXAxisCode(value: number): string {
    switch (value) {
      case 0:
      case 1:
        return '01'
      case 4:
        return '04'
      case 6:
        return '06'
      case 8:
        return '08'
      case 12:
        return '12'
      case 16:
        return '16'
      case 18:
        return '18'
      case 20:
        return '20'
      case 24:
        return '24'
      default:
        return ''
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      LineChart({ model: this.dateLineChartModel, customUiTriggerEvent: EventType.SingleTap })
        .width('100%')
        .height('100%')
        .margin({ bottom: 6 })
        .onAreaChange((oldValue, newValue) => {
          this.chartWidth = newValue.width as number
        })
    }
  }
}