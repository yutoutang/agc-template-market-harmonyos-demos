import { emitter } from '@kit.BasicServicesKit'
import { CommonConstants, ResUtil, RouterMap, RouterUtils, WindowModel } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import {
  CharDataModel,
  DateBarChart,
  DateType,
  LineChartDataModel,
  LineChartMode,
  SportChartPage
} from 'module_datechart'
import { DayWeekMonthSwitcher } from '../components/DayWeekMonthSwitcher'
import { CatType, StepDetail } from '../model/StepDetailType'
import { StepCountVM } from '../viewmodels/StepCountVM'
import { AppStorageV2 } from '@kit.ArkUI'
import { Logger } from 'ui_base'

@Builder
export function stepCountPageBuilder() {
  StepCountPage()
}

/**
 * 步数统计页面
 */
@ComponentV2
struct StepCountPage {
  @Local vm: StepCountVM = new StepCountVM(RouterMap.STEP_COUNT_PAGE)
  // 图表模式
  @Provider() lineChartMode: LineChartMode = LineChartMode.CUBIC_BEZIER
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    try {
      this.vm.querySportRecord()
      emitter.on('switchDateType', (data) => {
        if (data.data) {
          this.vm.dateType = data.data.dateType as DateType
          this.scroller.scrollEdge(Edge.Top)
        }
      })
    } catch (error) {
      Logger.error('stepCountPage', 'aboutToAppear error')
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        this.titleBuilder()

        //日，周，月步数图表展示
        DayWeekMonthSwitcher({ dateType: this.vm.dateType!!, curDate: this.vm.curDate!! })

        // 内容数据
        this.contentBuilder()
      }
      .width(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#FFC385', 0], ['#FFE7CC', 0.5], ['#F1F3F5', 1]],
        repeating: false
      })
      .height(CommonConstants.FULL_PERCENT)
      .padding({ bottom: this.windowModel.windowBottomPadding })
    }.hideTitleBar(true)
  }

  @Builder
  titleBuilder() {
    NavHeaderBar({
      title: $r('app.string.step_count')
    })
  }

  @Builder
  contentBuilder() {
    Scroll(this.scroller) {
      Column() {
        //日，周，月步数图表展示
        this.chartBuilder()

        Column() {
          if (this.vm.dateType === DateType.DAY) {
            //每天数据展示
            this.dayProgressBuilder()
          } else {
            //周，月数据展示
            this.weekOrMonthStatisticsBuilder()
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .padding({
          top: CommonConstants.PADDING_PAGE,
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          bottom: this.vm.windowModel.windowBottomPadding
        })
        .backgroundColor(Color.Transparent)
      }.width(CommonConstants.FULL_PERCENT)
    }
    .layoutWeight(1)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
    .backgroundColor(Color.Transparent)
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  /**
   * 显示日期
   * @param day
   */
  dayShow(day: Object | undefined) {
    if (day && day.toString() && day.toString().indexOf(':') > -1) {
      let data = String(Number(day.toString().split(':')[0]) + 1).padStart(2, '0') + ':00'
      return day.toString() + ' - ' + data;
    }
    return ''
  }

  /**
   * 日，周，月步数图表展示
   */
  @Builder
  chartBuilder() {
    Column() {
      Text(this.dayShow(this.vm.selectData?.obj))
        .fontColor($r('app.color.color_black'))
        .fontSize(15)
        .margin(6)

      Stack({ alignContent: Alignment.Top }) {
        Column() {
          DateBarChart({
            dateType: this.vm.dateType,
            data: this.vm.curStepCharModel,
            options: {
              xAxisLineColor: ResUtil.getColorSync($r('app.color.color_D9E1E7')),
              xAxisTextColor: ResUtil.getColorSync($r('app.color.color_809FB8')),
              xAxisTextSize: 10,
              xAxisLineWidth: 0.6,
              yAxisLineColor: ResUtil.getColorSync($r('app.color.color_D9E1E7')),
              yAxisTextColor: ResUtil.getColorSync($r('app.color.color_809FB8')),
              yAxisTextSize: 10,
              yAxisLineWidth: 0.6,
              barHighLightColor: ResUtil.getColorSync($r('app.color.color_EE7731')),
              barColor: ResUtil.getColorSync($r('app.color.color_5AEE7731')),
              barWidth: 0.3,
              barTopRadius: 40,
              autoHighlight: false,
              yAxisLabelCount: 5,
              highLightLine: true
            },
            selectedIndex: this.vm.selectedIndex,
            onSelectedData: (data) => {
              this.vm.selectData = data
            }
          })
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.vp_180'))
        }.linearGradient({
          direction: GradientDirection.Bottom,
          repeating: false,
          colors: [['#00FFFFFF', 0], ['#FFFFFF', 1]]
        }).padding({
          top: $r('app.float.vp_36'),
          left: $r('app.float.vp_16'),
          right: $r('app.float.vp_16'),
          bottom: $r('app.float.vp_16')
        }).borderRadius(12)

        Text() {
          Span(`${this.vm.selectData?.data ?? 0}`)
            .fontColor($r('app.color.color_5A3B2A'))
            .fontSize(55)

          Span($r('app.string.step'))
            .fontColor($r('app.color.color_542001'))
            .fontSize(16)
        }
        .fontColor($r('app.color.color_black'))
        .fontSize(15)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
  }

  getChartMaxValue(model: CharDataModel[]): number {
    let max = 0
    for (let data of model) {
      if (data.data > max) {
        max = data.data
      }
    }
    return max
  }

  /**
   * 每天数据展示
   */
  @Builder
  dayProgressBuilder() {
    Column({ space: 14 }) {
      Text($r('app.string.target_process'))
        .fontSize($r('app.float.fp_16'))
        .fontColor($r('app.color.color_black'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)

      SportChartPage({
        dateType: DateType.DAY,
        dayStepModel: {
          target: this.vm.curRecords[0].totalTarget?.stepCount ?? 0,
          process: this.vm.curRecords[0].totalStepCount,
          charData: [new LineChartDataModel(this.vm.curStepCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          })],
          isShowArrow: true
        },
        dayTimeModel: {
          target: 30,
          process: this.vm.curRecords[0].totalSportTimeLength / 60,
          charData: [new LineChartDataModel(this.vm.curTimeLengthCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          })],
          isShowArrow: false
        },
        dayDepleteModel: {
          target: this.vm.curRecords[0].totalTarget?.deplete ?? 0,
          process: this.vm.curRecords[0].totalDeplete,
          charData: [new LineChartDataModel(this.vm.curTimeLengthCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          })],
          isShowArrow: false
        },
        dayDistanceModel: {
          target: (this.vm.curRecords[0].totalTarget?.distance ?? 0) / 1000,
          process: this.vm.curRecords[0].totalDistance / 1000,
          charData: [new LineChartDataModel(this.vm.curTimeLengthCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          })],
          isShowArrow: false
        },
        chartCardClick: () => {
          RouterUtils.pushPathByName(RouterMap.STEP_DETAIL_PAGE,
            { catType: CatType.STEP_COUNT, date: this.vm.curDate } as StepDetail)
        }
      })
    }
  }

  /**
   * 周，月相关数据展示
   */
  @Builder
  weekOrMonthStatisticsBuilder() {
    Column({ space: 10 }) {
      //周，月总数据
      this.totalDataBuilder()

      Text($r('app.string.total_data_tips'))
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_10'))

      SportChartPage({
        dateType: DateType.WEEK,
        wmStepModel: {
          dateType: this.vm.sportCompareModel.compareType,
          desc: this.vm.sportCompareModel.stepDesc,
          descInfo: this.vm.sportCompareModel.stepDescInfo,
          curData: new LineChartDataModel(
            this.vm.curStepCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          lastData: new LineChartDataModel(
            this.vm.sportCompareModel.lastStepCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          curDateStr: this.vm.sportCompareModel.curDateStr,
          lastDateStr: this.vm.sportCompareModel.lastDateStr
        },
        wmTimeModel: {
          dateType: this.vm.sportCompareModel.compareType,
          desc: this.vm.sportCompareModel.timeLengthDesc,
          descInfo: this.vm.sportCompareModel.timeLengthDescInfo,
          curData: new LineChartDataModel(
            this.vm.curTimeLengthCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          lastData: new LineChartDataModel(
            this.vm.sportCompareModel.lastTimeLengthCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          curDateStr: this.vm.sportCompareModel.curDateStr,
          lastDateStr: this.vm.sportCompareModel.lastDateStr
        },
        wmDepleteModel: {
          dateType: this.vm.sportCompareModel.compareType,
          desc: this.vm.sportCompareModel.depleteDesc,
          descInfo: this.vm.sportCompareModel.depleteDescInfo,
          curData: new LineChartDataModel(
            this.vm.curDepleteCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineColor: ResUtil.getColorSync($r('app.color.color_FFA700')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          lastData: new LineChartDataModel(
            this.vm.sportCompareModel.lastDepleteCharModel, {
            lineHighLightColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineColor: ResUtil.getColorSync($r('app.color.color_C2D0DC')),
            lineWidth: 1,
            circleRadius: 2.5
          }),
          curDateStr: this.vm.sportCompareModel.curDateStr,
          lastDateStr: this.vm.sportCompareModel.lastDateStr
        },
        chartCardClick: () => {
          RouterUtils.pushPathByName(RouterMap.STEP_DETAIL_PAGE,
            { catType: CatType.STEP_COUNT, date: this.vm.curDate } as StepDetail)
        }
      })

    }
  }

  @Builder
  totalDataBuilder() {
    Column() {
      Row() {
        //总步数
        Column() {
          Text($r('app.string.total_step'))
            .fontSize($r('app.float.fp_14'))
            .fontColor($r('app.color.color_80000000'))

          Text() {
            Span(this.vm.sportCompareModel.curSportStatistics.totalStepCount.toString())
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_28'))
              .fontWeight(500)

            Span(' ' + ResUtil.getStringSync($r('app.string.step_unit')))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_16'))
          }.margin({ top: $r('app.float.vp_6') })
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Start)

        Line().width(1).height($r('app.float.vp_30'))
          .backgroundColor($r('app.color.color_33979797'))

        //平均步数
        Column() {
          Text($r('app.string.average_step'))
            .fontSize($r('app.float.fp_14'))
            .fontColor($r('app.color.color_80000000'))
          Text() {
            Span(this.vm.sportCompareModel.curSportStatistics.averageStepCount.toString())
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_28'))
              .fontWeight(500)

            Span(' ' + ResUtil.getStringSync($r('app.string.step_unit')))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_16'))
          }.margin({ top: $r('app.float.vp_6') })
        }.layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }.width(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Center)

      //消耗
      Column() {
        Row() {
          Image($r('app.media.ic_chart_deplete'))
            .width($r('app.float.vp_24'))
          Text($r('app.string.deplete'))
            .fontColor(Color.Black)
            .fontSize($r('app.float.fp_16'))
            .margin({ left: $r('app.float.vp_4') })
        }

        Row() {
          Text() {
            Span(this.vm.sportCompareModel.curSportStatistics.totalDeplete.toString())
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_28'))
              .fontWeight(500)

            Span(' ' + ResUtil.getStringSync($r('app.string.deplete_unit')))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_16'))
          }

          Blank()

          Text($r('app.string.deplete_desc',
            (this.vm.sportCompareModel.curSportStatistics.totalDeplete / 300).toFixed(1)))
            .linearGradient({ direction: GradientDirection.Right, colors: [['#FFFFFF', 0], ['#FFE1D3', 1]] })
            .fontSize($r('app.float.fp_12'))
            .fontColor($r('app.color.color_F07244'))
            .borderRadius($r('app.float.vp_13'))
            .height($r('app.float.vp_26'))
            .padding({ right: $r('app.float.vp_10') })

        }.width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .borderRadius($r('app.float.vp_10'))
      .borderColor($r('app.color.color_33979797'))
      .borderWidth($r('app.float.vp_1'))
      .padding({
        top: $r('app.float.vp_7'),
        bottom: $r('app.float.vp_7'),
        left: $r('app.float.vp_14'),
        right: $r('app.float.vp_14')
      })
      .justifyContent(FlexAlign.Start)
      .margin({ top: $r('app.float.vp_14') })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      //距离
      Column() {
        Row() {
          Image($r('app.media.ic_chart_distance'))
            .width($r('app.float.vp_24'))
          Text($r('app.string.distance_count'))
            .fontColor(Color.Black)
            .fontSize($r('app.float.fp_16'))
            .margin({ left: $r('app.float.vp_4') })
        }

        Row() {
          Text() {
            Span((this.vm.sportCompareModel.curSportStatistics.totalDistance / 1000).toFixed(2))
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_28'))
              .fontWeight(500)

            Span(' ' + ResUtil.getStringSync($r('app.string.distance_unit')))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_16'))
          }

          Blank()

          Text($r('app.string.distance_desc',
            (this.vm.sportCompareModel.curSportStatistics.totalDistance / 346).toFixed(1)))
            .height($r('app.float.vp_26'))
            .linearGradient({ direction: GradientDirection.Right, colors: [['#FFFFFF', 0], ['#AEE0CD', 1]] })
            .fontSize($r('app.float.fp_12'))
            .borderRadius($r('app.float.vp_13'))
            .fontColor($r('app.color.color_03AD84'))
            .padding({ right: $r('app.float.vp_10') })

        }.width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .borderRadius($r('app.float.vp_10'))
      .borderColor($r('app.color.color_33979797'))
      .borderWidth($r('app.float.vp_1'))
      .padding({
        top: $r('app.float.vp_7'),
        bottom: $r('app.float.vp_7'),
        left: $r('app.float.vp_14'),
        right: $r('app.float.vp_14')
      })
      .margin({ top: $r('app.float.vp_10') })
      .width('100%')
      .alignItems(HorizontalAlign.Start)

    }.backgroundColor(Color.White)
    .padding($r('app.float.vp_16'))
    .borderRadius($r('app.float.vp_12'))
  }
}

export function getYAxisMaxValue(labelCount: number, models: LineChartDataModel[]): number | undefined {
  const labels = getCustomLabels(labelCount, models)
  return labels[labels.length - 1]
}

export function getCustomLabels(labelCount: number, models: LineChartDataModel[]): number[] {
  let max = 0
  for (let model of models) {
    for (let data of model.dataModel) {
      if (data.data > max) {
        max = data.data
      }
    }
  }
  return [max]
}

/**
 * rounds the given number to the next significant number
 *
 * @param number
 * @return
 */
function roundToNextSignificant(number: number): number {
  if (number === Number.MAX_VALUE ||
  Number.isNaN(number) ||
    number === 0.0) {
    return 0;
  }

  const d: number = Math.ceil(Math.log10(number < 0 ? -number : number));
  const pw: number = 1 - Math.floor(d);
  const magnitude: number = Math.pow(10, pw);
  const shifted: number = Math.round(number * magnitude);
  return shifted / magnitude;
}

function nextUp(d: number): number {
  if (d === Number.MAX_VALUE) {
    return d;
  } else {
    d += 0.0;
    return d += 0.000000001;
  }
}