import { CommonConstants } from '../constants/CommonConstants'
import { WeekDateModel } from '../model/WeekDateModel'
import { DateUtils } from '../utils/DateUtils'
import { DailyRecordVM } from '../viewmodels/DailyRecordVM'
import { SportSingleRing, SportSingleRingType } from './SportSingleRing'

@ComponentV2
export struct SingleRingDataItem {
  @Param color: ResourceStr = ''
  @Param title: ResourceStr = ''
  @Param data: number[] = []
  @Param text: string = ''

  build() {
    Row() {
      Divider()
        .vertical(true)
        .color(this.color)
        .strokeWidth(3)
        .height(36)
      Blank().width(6)
      Column() {
        Text(this.title)
          .fontSize(12)
          .fontColor('#999999')
        Blank().height(4)
        Text() {
          Span(this.color === '#F2B73F' ? Math.floor(this.data[0] / 1000 * 10) / 10 + '' : this.data[0] + '')
            .fontSize(20)
            .fontColor('#333333')
          Span($r(this.text, this.data[1]))
            .fontSize(11)
            .fontColor('#999999')
        }
      }
      .alignItems(HorizontalAlign.Start)
    }
  }
}

@ComponentV2
export struct UnfinishedRecordItem {
  @Param weekDateModelItem: WeekDateModel = new WeekDateModel()
  @Param type: SportSingleRingType = SportSingleRingType.Step
  @Param unit: ResourceStr = ''
  @Consumer('attendanceRecordVM') attendanceRecordVM: DailyRecordVM = new DailyRecordVM()
  @Event toSportPage?: (date: Date, sportSingleRingType: SportSingleRingType) => void

  build() {
    Row() {
      Row() {
        SportSingleRing({
          type: this.type,
          currentData: this.getData(this.weekDateModelItem, this.type)[0],
          max: this.getData(this.weekDateModelItem, this.type)[1]
        })

        Column({ space: 4 }) {
          Text($r('app.string.unfinished_item'))
            .fontSize(12)
            .fontColor('#888888')
          Text() {
            Span(this.getData(this.weekDateModelItem, this.type)[0] + '')
            Span(this.unit)
          }
          .fontSize(20)
          .fontColor('#333333')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 14 })
      }

      Button($r('app.string.continueRun'))
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.font_on_primary'))
        .linearGradient({
          direction: GradientDirection.Bottom,
          repeating: true,
          colors: [['#FFA700', 0.0], ['#FE5600', 1.0]]
        })
        .width(80)
        .height(28)
        .onClick(() => {
          if (this.toSportPage) {
            this.toSportPage(this.attendanceRecordVM.currentDate, this.type)
          }
        })
        .visibility((!this.weekDateModelItem.date || DateUtils.isSameDay(this.weekDateModelItem.date, new Date())) ?
        Visibility.Visible :
        Visibility.None)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(12)
    .padding(12)
    .backgroundColor(Color.White)
    .margin({ bottom: 8 })
    .visibility(this.getData(this.weekDateModelItem, this.type)[0] <
    this.getData(this.weekDateModelItem, this.type)[1] ?
    Visibility.Visible : Visibility.None)

  }

  getData(weekDateModelItem: WeekDateModel, type: SportSingleRingType) {
    switch (type) {
      case SportSingleRingType.Step:
        return weekDateModelItem?.stepData
      case SportSingleRingType.Distance:
        return weekDateModelItem?.distanceData
      case SportSingleRingType.Calorie:
        return weekDateModelItem?.caloriesData
      default:
        return weekDateModelItem?.stepData
    }
  }
}