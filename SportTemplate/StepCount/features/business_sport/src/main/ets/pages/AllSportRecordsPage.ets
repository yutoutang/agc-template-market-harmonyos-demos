import { AppStorageV2, curves, LengthMetrics } from '@kit.ArkUI'
import { CommonConstants, RouterMap, RouterUtils, WindowModel } from 'lib_common'
import { SportType } from 'lib_sport_api'
import { NavHeaderBar } from 'lib_widget'
import { MonthItemModel, MonthOverviewModel } from '../model/SportOverviewModel'
import { DateUtils } from '../util/DateUtils'
import { AllSportRecordsVM } from '../viewmodels/AllSportRecordsVM'
import { FormaterUtils } from '../util/FormaterUtils'

@Builder
export function allSportRecordsPageBuilder() {
  AllSportRecordsPage()
}

/**
 * 所有运动
 */
@ComponentV2
struct AllSportRecordsPage {
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local allSportRecordsVM: AllSportRecordsVM = new AllSportRecordsVM()
  private scroller = new ListScroller()

  aboutToAppear(): void {
    this.allSportRecordsVM.queryYearOverview()
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        this.titleBuilder()
        //  内容
        this.contentBuilder()
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [['#FFC385', 0], ['#FFE7CC', 0.5], ['#F1F3F5', 1]]
      })
      .padding({
        bottom: this.windowModel.windowBottomPadding,
      })

    }.hideTitleBar(true)
  }

  // 标题
  @Builder
  titleBuilder() {
    NavHeaderBar({
      title: this.getPageTitle(),
      rightPartBuilder: () => {
        this.titleRightBuilder()
      },
      titleBindMenu: () => {
        this.switchSportTypeMenu()
      }
    })
  }

  // 内容
  @Builder
  contentBuilder() {
    Scroll() {
      List({ space: 16, scroller: this.scroller }) {
        //运动总数据
        this.sportTotalDataBuilder()

        //月数据
        this.allSportDataListBuiler()
      }
      .height(CommonConstants.FULL_PERCENT)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        right: CommonConstants.PADDING_PAGE,
        left: CommonConstants.PADDING_PAGE
      })
      .scrollBar(BarState.Off)
      .backgroundColor(Color.Transparent)
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .backgroundColor(Color.Transparent)
  }

  /**
   * 月数据
   */
  @Builder
  allSportDataListBuiler() {
    ForEach(this.allSportRecordsVM.overviewModel.monthOverview, (monthOverview: MonthOverviewModel) => {
      ListItemGroup({ header: this.monthOverviewBuilder(monthOverview), style: ListItemGroupStyle.NONE }) {
        if (monthOverview.expanded && monthOverview.itemList.length > 0) {
          ForEach(monthOverview.itemList, (item: MonthItemModel) => {
            //天数据
            ListItem() {
              this.monthItemListBuilder(item)
            }.animation({ curve: curves.interpolatingSpring(0, 1, 528, 39) })
            .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
            .margin({ bottom: $r('app.float.vp_6') })
          }, (item: MonthItemModel, index: number) => JSON.stringify(item))
        }
      }.backgroundColor(Color.White)
      .borderRadius($r('app.float.vp_12'))
    }, (item: MonthOverviewModel, index: number) => JSON.stringify(item))
  }

  @Builder
  sportTotalDataBuilder() {
    ListItem() {
      Column() {
        Row() {
          Image($r('app.media.ic_date_left_arrow'))
            .width(18)
            .onClick(() => {
              this.allSportRecordsVM.year--
            })

          Text($r('app.string.sport_overview', this.allSportRecordsVM.year))
            .fontColor($r('app.color.color_333333'))
            .fontSize($r('app.float.fp_18'))
            .margin({ left: $r('app.float.vp_20'), right: $r('app.float.vp_20') })

          Image($r('app.media.ic_date_right_arrow'))
            .width(18)
            .onClick(() => {
              this.allSportRecordsVM.year++
            }).visibility(this.isShowDateAdd() ? Visibility.Visible : Visibility.Hidden)
        }.justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: 26 })

        Row() {
          Column({ space: 4 }) {
            Text((this.allSportRecordsVM.overviewModel.timeLength / 3600).toFixed(1))
              .fontColor($r('app.color.color_333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_32'))

            Text($r('app.string.overview_time_length'))
              .fontColor($r('app.color.color_8F333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_12'))
          }

          Column({ space: 4 }) {
            Text(FormaterUtils.formatCount(this.allSportRecordsVM.overviewModel.count))
              .fontColor($r('app.color.color_333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_32'))

            Text($r('app.string.overview_count'))
              .fontColor($r('app.color.color_8F333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_12'))
          }

          Column({ space: 4 }) {
            Text(this.allSportRecordsVM.overviewModel.deplete.toString())
              .fontColor($r('app.color.color_333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_32'))

            Text($r('app.string.overview_deplete'))
              .fontColor($r('app.color.color_8F333333'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('app.float.fp_12'))
          }
        }.width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .margin({ top: $r('app.float.vp_26') })
      }.width(CommonConstants.FULL_PERCENT)
    }
  }

  @Builder
  monthOverviewBuilder(monthOverview: MonthOverviewModel) {
    MonthOverview({
      year: this.allSportRecordsVM.year,
      monthOverview: monthOverview,
      showExtendArrow: monthOverview.itemList.length > 0,
      expanded: monthOverview.expanded
    })
      .animation({ curve: curves.interpolatingSpring(0, 1, 528, 39) })
      .onClick(() => {
        if (monthOverview.itemList.length > 0) {
          this.getUIContext()?.animateTo({ curve: curves.interpolatingSpring(0, 1, 528, 39) }, () => {
            monthOverview.expanded = !monthOverview.expanded
          })
        }
      })
  }

  @Builder
  monthItemListBuilder(item: MonthItemModel) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Row({ space: 10 }) {
        Image(this.getItemIcon(item.type))
          .width($r('app.float.vp_40'))
        Column() {
          Row() {
            Text(MonthItemModel.getChildSportTypeStr(item.childType))
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_12'))
              .constraintSize({ minWidth: $r('app.float.vp_18') })

            Text($r('app.string.date_formater', item.month, item.day, item.hour.toString().padStart(2, '0'), item.minute.toString().padStart(2, '0')))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_10'))
              .margin({ left: $r('app.float.vp_12') })
          }.justifyContent(FlexAlign.Start)
          .width(CommonConstants.FULL_PERCENT)

          Row() {
            Text() {
              Span((Math.floor(item.distance / 100) / 10).toFixed(1))
                .fontColor($r('app.color.color_333333'))
                .fontSize($r('app.float.fp_18'))
              Span($r('app.string.distance_unit'))
            }
            .fontColor($r('app.color.color_888888'))
            .fontSize($r('app.float.fp_10'))
            .layoutWeight(1)
            .textAlign(TextAlign.Start)

            Line()
              .backgroundColor($r('app.color.color_DCDEE9'))
              .height($r('app.float.vp_8'))
              .width($r('app.float.vp_1'))

            Text(DateUtils.formaterTimeLength(item.timeLength))
              .fontColor($r('app.color.color_888888'))
              .fontSize($r('app.float.fp_10'))
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Line()
              .backgroundColor($r('app.color.color_DCDEE9'))
              .height($r('app.float.vp_8'))
              .width($r('app.float.vp_1'))

            Text($r('app.string.speed_distance',
              DateUtils.formaterTimeLength2(item.timeLength / (item.distance / 1000))))
              .fontColor($r('app.color.color_888888'))
              .fontSize($r('app.float.fp_10'))
              .layoutWeight(1)
              .textAlign(TextAlign.Center)

            Blank().layoutWeight(0.5)
          }.width(CommonConstants.FULL_PERCENT)
          .margin({ top: $r('app.float.vp_7') })
        }.layoutWeight(1)

        Image($r('app.media.ic_arrow_right'))
          .width($r('app.float.vp_12'))
      }
      .width('100%')
      .height($r('app.float.vp_62'))
      .alignItems(VerticalAlign.Center)
      .padding($r('app.float.vp_10'))
      .borderWidth($r('app.float.vp_1'))
      .borderColor($r('app.color.color_E0E3EE'))
      .borderRadius($r('app.float.vp_8'))

      if (MonthItemModel.isTargetComplete(item) !== undefined) {
        Text(MonthItemModel.isTargetComplete(item) ? $r('app.string.target_complete') :
          $r('app.string.target_not_complete'))
          .fontColor(MonthItemModel.isTargetComplete(item) ? $r('app.color.color_599F1A') :
            $r('app.color.color_DA0D0D'))
          .backgroundColor(MonthItemModel.isTargetComplete(item) ? $r('app.color.color_CFEFB2') :
            $r('app.color.color_FFB9B9'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_16'))
          .fontSize($r('app.float.fp_10'))
          .textAlign(TextAlign.Center)
          .borderRadius({ bottomLeft: $r('app.float.vp_8'), topRight: $r('app.float.vp_8') })
      }
    }.onClick(() => {
      RouterUtils.pushPathByName(RouterMap.SPORT_RECORD_DETAIL_PAGE, item)
    })
  }

  getItemIcon(sportType: SportType): Resource | undefined {
    if (sportType === SportType.WALKING) {
      return $r('app.media.ic_walking')
    } else if (sportType === SportType.JOGGING) {
      return $r('app.media.ic_jogging')
    } else if (sportType === SportType.CYCLING) {
      return $r('app.media.ic_cycling')
    } else if (sportType === SportType.CLOCK_BASE_EXCERCISE) {
      return $r('app.media.ic_clock_base_exercise')
    } else {
      return undefined
    }
  }

  isShowDateAdd(): boolean {
    return this.allSportRecordsVM.year < new Date().getFullYear()
  }

  getPageTitle(): ResourceStr {
    if (this.allSportRecordsVM.curSportType === SportType.WALKING) {
      return $r('app.string.walking')
    } else if (this.allSportRecordsVM.curSportType === SportType.JOGGING) {
      return $r('app.string.jogging')
    } else if (this.allSportRecordsVM.curSportType === SportType.CYCLING) {
      return $r('app.string.cycling')
    } else {
      return $r('app.string.all_sport')
    }
  }

  @Builder
  titleRightBuilder() {
    Column() {
      Image($r('app.media.ic_date_selector_arrow'))
        .width($r('app.float.vp_12'))
    }
    .width($r('app.float.vp_30'))
    .height($r('app.float.vp_30'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  switchSportTypeMenu() {
    Menu() {
      MenuItem({ startIcon: $r('app.media.ic_all_sport_type'), content: $r('app.string.all_sport') })
        .onClick(() => {
          if (this.allSportRecordsVM.curSportType !== SportType.ALL) {
            this.switchSportType(SportType.ALL)
          }
        })
      MenuItem({ startIcon: $r('app.media.ic_jogging'), content: $r('app.string.jogging') })
        .onClick(() => {
          if (this.allSportRecordsVM.curSportType !== SportType.JOGGING) {
            this.switchSportType(SportType.JOGGING)
          }
        })
      MenuItem({ startIcon: $r('app.media.ic_walking'), content: $r('app.string.walking') })
        .onClick(() => {
          if (this.allSportRecordsVM.curSportType !== SportType.WALKING) {
            this.switchSportType(SportType.WALKING)
          }
        })
      MenuItem({ startIcon: $r('app.media.ic_cycling'), content: $r('app.string.cycling') })
        .onClick(() => {
          if (this.allSportRecordsVM.curSportType !== SportType.CYCLING) {
            this.switchSportType(SportType.CYCLING)
          }
        })
    }
    .menuItemDivider({
      color: $r('sys.color.ohos_id_color_list_separator'),
      strokeWidth: LengthMetrics.vp(1)
    })
    .width('224vp')
  }

  switchSportType(type: SportType) {
    this.allSportRecordsVM.curSportType = type
    this.allSportRecordsVM.queryYearOverview()
    this.scroller.scrollEdge(Edge.Top)
  }
}

@ComponentV2
struct MonthOverview {
  @Param @Require year: number
  @Param @Require monthOverview: MonthOverviewModel
  @Param showExtendArrow: boolean = true
  @Param expanded: boolean = false
  @BuilderParam extendsContentBuilder?: CustomBuilder

  build() {
    Column({ space: 9 }) {
      Row() {
        Text($r('app.string.year_month', this.year, this.monthOverview.month))
          .fontColor($r('app.color.color_333333'))
          .fontSize($r('app.float.fp_14'))
        if (this.showExtendArrow) {
          Image(this.expanded ? $r('app.media.ic_arrow_up') : $r('app.media.ic_arrow_bottom'))
            .width($r('app.float.vp_24'))
        }
      }.width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Text($r('app.string.distance_num',
          ((this.monthOverview.walkingDistance + this.monthOverview.joggingDistance +
          this.monthOverview.cyclingDistance) / 1000).toFixed(1)))
          .fontColor($r('app.color.color_888888'))
          .fontSize($r('app.float.fp_10'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Line()
          .backgroundColor($r('app.color.color_DCDEE9'))
          .height($r('app.float.vp_8'))
          .width($r('app.float.vp_1'))

        Text(DateUtils.formaterTimeLength(this.monthOverview.timeLength, false))
          .fontColor($r('app.color.color_888888'))
          .fontSize($r('app.float.fp_10'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Line()
          .backgroundColor($r('app.color.color_DCDEE9'))
          .height($r('app.float.vp_8'))
          .width($r('app.float.vp_1'))

        Text($r('app.string.count_num', FormaterUtils.formatCount(this.monthOverview.count)))
          .fontColor($r('app.color.color_888888'))
          .fontSize($r('app.float.fp_10'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Line()
          .backgroundColor($r('app.color.color_DCDEE9'))
          .height($r('app.float.vp_8'))
          .width($r('app.float.vp_1'))

        Text($r('app.string.deplete_num', FormaterUtils.formatDeplete(this.monthOverview.deplete)))
          .fontColor($r('app.color.color_888888'))
          .fontSize($r('app.float.fp_10'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }.width(CommonConstants.FULL_PERCENT)
      .height($r('app.float.vp_22'))
      .backgroundColor($r('app.color.color_F2F4FF'))
      .borderRadius($r('app.float.vp_4'))

      Row() {
        Column({ space: 4 }) {
          Text((this.monthOverview.joggingDistance / 1000).toFixed(1))
            .fontColor($r('app.color.color_333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_32'))

          Text($r('app.string.jogging_num'))
            .fontColor($r('app.color.color_8F333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_12'))
        }

        Column({ space: 4 }) {
          Text((this.monthOverview.walkingDistance / 1000).toFixed(1))
            .fontColor($r('app.color.color_333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_32'))

          Text($r('app.string.walking_num'))
            .fontColor($r('app.color.color_8F333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_12'))
        }

        Column({ space: 4 }) {
          Text((this.monthOverview.cyclingDistance / 1000).toFixed(1))
            .fontColor($r('app.color.color_333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_32'))

          Text($r('app.string.cycling_num'))
            .fontColor($r('app.color.color_8F333333'))
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.fp_12'))
        }
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.extendsContentBuilder) {
        this.extendsContentBuilder()
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_12'),
      bottom: $r('app.float.vp_22')
    })
  }
}
