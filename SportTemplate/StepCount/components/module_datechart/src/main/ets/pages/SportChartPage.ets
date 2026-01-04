import { DayChartCard } from '../components/DayChartCard'
import { WeekMonthChartCard } from '../components/WeekMonthChartCard'
import { DateType } from '../constant/DateConstant'
import { DayChartCardModel } from '../model/DayChartCardModel'
import { WeekMonthChartCardModel } from '../model/WeekMonthChartCardModel'

@ComponentV2
export struct SportChartPage {
  @Param @Require dateType: DateType = DateType.DAY
  // day model
  @Param dayStepModel: DayChartCardModel = new DayChartCardModel()
  @Param dayTimeModel: DayChartCardModel = new DayChartCardModel()
  @Param dayDepleteModel: DayChartCardModel = new DayChartCardModel()
  @Param dayDistanceModel: DayChartCardModel = new DayChartCardModel()
  @Event chartCardClick: () => void
  // week month model
  @Param wmStepModel: WeekMonthChartCardModel = new WeekMonthChartCardModel()
  @Param wmTimeModel: WeekMonthChartCardModel = new WeekMonthChartCardModel()
  @Param wmDepleteModel: WeekMonthChartCardModel = new WeekMonthChartCardModel()

  build() {
    if (this.dateType === DateType.DAY) {
      this.DayChartsBuilder()
    } else {
      this.WeekMonthChartsBuilder()
    }
  }

  @Builder
  DayChartsBuilder() {
    Column({ space: 14 }) {
      // 步数图表卡片
      DayChartCard({
        type: 0,
        label: $r('app.string.step_count'),
        target: this.dayStepModel.target,
        process: this.dayStepModel.process,
        unit: $r('app.string.step_unit'),
        charData: this.dayStepModel.charData,
        isShowArrow: this.dayStepModel.isShowArrow,
      }).onClick(() => {
        this.chartCardClick()
      })

      // 时长图表卡片
      DayChartCard({
        type: 1,
        label: $r('app.string.time_length'),
        target: this.dayTimeModel.target,
        process: this.dayTimeModel.process,
        unit: $r('app.string.time_length_unit'),
        charData: this.dayTimeModel.charData,
        isShowArrow: this.dayTimeModel.isShowArrow,
      })

      // 消耗图表卡片
      DayChartCard({
        type: 2,
        label: $r('app.string.deplete'),
        target: this.dayDepleteModel.target,
        process: this.dayDepleteModel.process,
        unit: $r('app.string.deplete_unit'),
        charData: this.dayDepleteModel.charData,
        isShowArrow: this.dayDepleteModel.isShowArrow,
      })

      // 距离图表卡片
      DayChartCard({
        type: 3,
        label: $r('app.string.distance_count'),
        target: this.dayDistanceModel.target,
        process: this.dayDistanceModel.process,
        unit: $r('app.string.distance_unit'),
        charData: this.dayDistanceModel.charData,
        isShowArrow: this.dayDistanceModel.isShowArrow,
      })

    }
  }

  @Builder
  WeekMonthChartsBuilder() {
    //周，月比较数据
    WeekMonthChartCard({
      type: 0,
      dateType: this.wmStepModel.dateType,
      title: $r('app.string.step_count'),
      desc: this.wmStepModel.desc,
      descInfo: this.wmStepModel.descInfo,
      curData: this.wmStepModel.curData,
      lastData: this.wmStepModel.lastData,
      curDateStr: this.wmStepModel.curDateStr,
      lastDateStr: this.wmStepModel.lastDateStr
    })
    WeekMonthChartCard({
      type: 1,
      dateType: this.wmTimeModel.dateType,
      title: $r('app.string.time_length'),
      desc: this.wmTimeModel.desc,
      descInfo: this.wmTimeModel.desc,
      curData: this.wmTimeModel.curData,
      lastData: this.wmTimeModel.lastData,
      curDateStr: this.wmTimeModel.curDateStr,
      lastDateStr: this.wmTimeModel.lastDateStr
    })
    WeekMonthChartCard({
      type: 2,
      dateType: this.wmDepleteModel.dateType,
      title: $r('app.string.deplete'),
      desc: this.wmDepleteModel.desc,
      descInfo: this.wmDepleteModel.descInfo,
      curData: this.wmDepleteModel.curData,
      lastData: this.wmDepleteModel.lastData,
      curDateStr: this.wmDepleteModel.curDateStr,
      lastDateStr: this.wmDepleteModel.lastDateStr
    })
  }
}


