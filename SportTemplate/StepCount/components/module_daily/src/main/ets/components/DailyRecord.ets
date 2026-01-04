import { CommonConstants } from '../constants/CommonConstants'
import { DailyRouterMap } from '../constants/DailyRouterMap'
import { RouterUtils } from '../utils/DailyRouterUtils'
import { NavHeaderBar } from './NavHeaderBar'
import { SportSingleRingType } from '../components/SportSingleRing'
import { SportThirdRingRoad } from '../components/SportThirdRingRoad'
import { WeekDateModel, WeekModel } from '../model/WeekDateModel'
import { DateUtils } from '../utils/DateUtils'
import { DailyRecordVM } from '../viewmodels/DailyRecordVM'
import { SingleRingDataItem, UnfinishedRecordItem } from './DailyRecordItem'

/**
 * 运动打开记录页面
 */
@ComponentV2
export struct DailyRecord {
  @Consumer('attendanceRecordVM') attendanceRecordVM: DailyRecordVM = new DailyRecordVM()
  // 日历组件
  @BuilderParam calendarBuilder: () => void
  @Event toAllSportPage?: () => void
  @Event backPage?: () => void
  @Event toSportPage?: (date: Date, sportSingleRingType: SportSingleRingType) => void

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column()
        .linearGradient({
          direction: GradientDirection.Bottom,
          repeating: true,
          colors: [['#FFC385', 0.0], ['#FFE7CC', 0.7], ['#F1F3F5', 1.0]]
        })
        .width(CommonConstants.FULL_PERCENT)
        .height(300)
      Column() {
        NavHeaderBar({
          title: $r('app.string.attendance_record'),
          onBack: () => {
            if (this.backPage) {
              this.backPage()
            }
          }
        })
        Column() {
          // 七天数据
          Column() {
            this.calendarBuilder()
            Column() {
              Row() {
                ForEach(DateUtils.weekdays, (item: string, index: number) => {
                  // 周数据
                  Text(item)
                    .fontSize(12)
                    .fontColor(this.attendanceRecordVM.dateIndex === index ? '#FF7737' : '#666666')
                }, (item: string, index: number) => item)
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width(CommonConstants.FULL_PERCENT)

              Blank().height(4)

              Swiper() {
                ForEach(this.attendanceRecordVM.weekModel, (data: WeekModel, swiperIndex: number) => {
                  Row() {
                    ForEach(data.weekDateModel, (item: WeekDateModel, itemIndex: number) => {
                      Column() {
                        // 日期数据
                        Column() {
                          Text(item.day)
                            .fontSize(14)
                            .fontColor(item.selected ? '#FFFFFF' : '#333333')
                        }
                        .linearGradient({
                          direction: GradientDirection.Bottom,
                          repeating: true,
                          colors: item.selected ? [['#FFAF3F', 0.0], ['#FF6B36', 1.0]] : []
                        })
                        .justifyContent(FlexAlign.Center)
                        .borderRadius(14)
                        .height(28)
                        .width(28)

                        Blank().height(6)

                        SportThirdRingRoad({
                          multiple: 8,
                          stepData: item.stepData,
                          caloriesData: item.caloriesData,
                          distanceData: item.distanceData,
                          showCircle: false,
                          click: () => {
                            this.attendanceRecordVM.selectDate(item.date, swiperIndex, itemIndex,
                              this.attendanceRecordVM.weekModel)
                          }
                        })
                      }
                      .onClick(() => {
                        this.attendanceRecordVM.selectDate(item.date, swiperIndex, itemIndex,
                          this.attendanceRecordVM.weekModel)
                      })
                    }, (item: WeekDateModel) => item.date.toString())
                  }
                  .width(CommonConstants.FULL_PERCENT)
                  .justifyContent(FlexAlign.SpaceBetween)
                }, (item: WeekModel) => JSON.stringify(item.weekDateModel))
              }
              .index(this.attendanceRecordVM.swiperIndex)
              .indicator(false)
              .loop(false)
              .onChange((index) => {
                this.attendanceRecordVM.swiperIndex = index
                this.attendanceRecordVM.swiperChange()
              })
            }
            .margin({ top: 22 })
            .justifyContent(FlexAlign.SpaceBetween)
            .width(CommonConstants.FULL_PERCENT)
          }
          .linearGradient({
            direction: GradientDirection.Bottom,
            repeating: true,
            colors: [['#ebffffff', 0.0], ['#00ffffff', 1.0]]
          })
          .width(CommonConstants.FULL_PERCENT)
          .padding({
            left: CommonConstants.PADDING_M,
            right: CommonConstants.PADDING_M,
            top: CommonConstants.PADDING_M,
            bottom: CommonConstants.PADDING_S
          })
          .borderRadius(12)

          // 训练数据
          Row() {
            Column({ space: 22 }) {

              SingleRingDataItem({
                color: '#3E78F7',
                title: $r('app.string.step_count'),
                data: this.attendanceRecordVM.weekDateModelItem?.stepData,
                text: 'app.string.attendance_record_step'
              })

              SingleRingDataItem({
                color: '#F2B73F',
                title: $r('app.string.distance_count'),
                data: this.attendanceRecordVM.weekDateModelItem?.distanceData,
                text: 'app.string.attendance_record_distance'
              })

              SingleRingDataItem({
                color: '#E04537',
                title: $r('app.string.calories'),
                data: this.attendanceRecordVM.weekDateModelItem?.caloriesData,
                text: 'app.string.attendance_record_calories'
              })
            }
            .alignItems(HorizontalAlign.Start)

            SportThirdRingRoad({
              showCircle: true,
              multiple: 0.9,
              stepData: this.attendanceRecordVM.weekDateModelItem?.stepData,
              caloriesData: this.attendanceRecordVM.weekDateModelItem?.caloriesData,
              distanceData: this.attendanceRecordVM.weekDateModelItem?.distanceData,
              click: () => {
                RouterUtils.pushPathByName(DailyRouterMap.STEP_COUNT_PAGE,
                  { 'currentDate': this.attendanceRecordVM.currentDate } as ESObject)
              }
            })
          }
          .borderRadius(12)
          .backgroundColor(Color.White)
          .padding(26)
          .margin({ top: 8 })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            RouterUtils.pushPathByName(DailyRouterMap.STEP_COUNT_PAGE,
              { 'currentDate': this.attendanceRecordVM.currentDate } as ESObject)
          })

          // 未达标记录
          List() {
            ListItem() {
              UnfinishedRecordItem(
                {
                  weekDateModelItem: this.attendanceRecordVM.weekDateModelItem,
                  type: SportSingleRingType.Step,
                  unit: $r('app.string.step_unit'),
                  toSportPage: () => {
                    if (this.toSportPage) {
                      this.toSportPage(this.attendanceRecordVM.weekDateModelItem.date, SportSingleRingType.Step)
                    }
                  }
                }
              )
            }

            ListItem() {
              UnfinishedRecordItem(
                {
                  weekDateModelItem: this.attendanceRecordVM.weekDateModelItem,
                  type: SportSingleRingType.Distance,
                  unit: $r('app.string.distance_unit'),
                  toSportPage: () => {
                    if (this.toSportPage) {
                      this.toSportPage(this.attendanceRecordVM.weekDateModelItem.date, SportSingleRingType.Distance)
                    }
                  }
                }
              )
            }

            ListItem() {
              UnfinishedRecordItem(
                {
                  weekDateModelItem: this.attendanceRecordVM.weekDateModelItem,
                  type: SportSingleRingType.Calorie,
                  unit: $r('app.string.calories'),
                  toSportPage: () => {
                    if (this.toSportPage) {
                      this.toSportPage(this.attendanceRecordVM.weekDateModelItem.date, SportSingleRingType.Calorie)
                    }
                  }
                }
              )
            }
          }
          .visibility(DateUtils.isSameDay(this.attendanceRecordVM.currentDate, new Date()) ? Visibility.Visible :
          Visibility.None)
          .margin({ top: 8 })
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

          // 所有运动记录按钮
          Text($r('app.string.all_running_record_btn'))
            .width(186)
            .height(28)
            .textAlign(TextAlign.Center)
            .backgroundColor(Color.White)
            .fontSize(12)
            .fontColor('#888888')
            .borderRadius(14)
            .margin({ top: 14 })
            .onClick(() => {
              if (this.toAllSportPage) {
                this.toAllSportPage()
              }
            })

        }
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
        })
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  /**
   * 初始化周数据
   */
  initWeekData() {
    this.attendanceRecordVM.initDataList(this.attendanceRecordVM.currentDate)
  }
}