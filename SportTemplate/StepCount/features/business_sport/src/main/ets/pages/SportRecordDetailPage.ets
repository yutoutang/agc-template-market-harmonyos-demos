import { AppStorageV2 } from '@kit.ArkUI'
import { CommonConstants, ResUtil, RouterMap, RouterUtils, WindowModel } from 'lib_common'
import { SportType } from 'lib_sport_api'
import { NavHeaderBar } from 'lib_widget'
import { MonthItemModel } from '../model/SportOverviewModel'
import { DateUtils } from '../util/DateUtils'
import { LocusMap } from '../components/LocusMap'

@Builder
export function sportRecordDetailPageBuilder() {
  SportRecordDetailPage()
}

/**
 * 运动详情页面
 */
@ComponentV2
struct SportRecordDetailPage {
  @Local sportItem?: MonthItemModel
  @Local isShowLineLocus: boolean = false

  aboutToAppear(): void {
    const params = RouterUtils.getParamByName<MonthItemModel>(RouterMap.SPORT_RECORD_DETAIL_PAGE)
    if (params) {
      this.sportItem = params
      this.isShowLineLocus = (this.sportItem?.locusPoints?.length ?? 0) > 0
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        if (this.isShowLineLocus) {
          //地图轨迹组件
          LocusMap({ points: this.sportItem?.locusPoints ?? [] })
        } else {
          Column() {
            this.sportDataBuilder()
          }.width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .padding({
            top: ResUtil.getNumber($r('app.float.nav_header_height')) +
            AppStorageV2.connect(WindowModel, () => new WindowModel())!.windowTopPadding,
            bottom: AppStorageV2.connect(WindowModel, () => new WindowModel())!.windowBottomPadding
          })
          .linearGradient({
            direction: GradientDirection.Bottom,
            repeating: false,
            colors: [['#FFC385', 0], ['#FFE7CC', 0.3], ['#F1F3F5', 1]]
          })
        }
        //TitleBar
        NavHeaderBar({
          title: this.sportItem ? MonthItemModel.getChildSportTypeStr(this.sportItem.childType) : ''
        })
      }.width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }.hideTitleBar(true)
    .bindSheet(this.isShowLineLocus, this.sportDataBuilder(), {
      detents: [250, SheetSize.FIT_CONTENT],
      mode: SheetMode.EMBEDDED,
      enableOutsideInteractive: true,
      showClose: false,
      preferType: SheetType.CENTER,
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      backgroundColor: Color.Transparent,
      onWillDismiss: (action) => {
        if (action.reason === DismissReason.PRESS_BACK) {
          RouterUtils.pop()
        }
      }
    })
  }

  @Builder
  sportDataBuilder() {
    Column() {
      // 运动公里数
      this.runDistance()

      // 运动详细数据
      this.runDetailData()
    }
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_PAGE
    })
  }

  // 运动公里数
  @Builder
  runDistance() {
    Column() {
      Text($r('app.string.date_formater', this.sportItem?.month, this.sportItem?.day, this.sportItem?.hour.toString().padStart(2,'0'),
        this.sportItem?.minute.toString().padStart(2,'0')))
        .fontSize($r('app.float.vp_12'))
        .fontColor($r('app.color.color_8F333333'))
      Text() {
        Span((Math.floor((this.sportItem?.distance ?? 0) / 100) / 10).toFixed(1))
          .fontSize($r('app.float.fp_55'))
          .fontColor($r('app.color.color_5A3B2A'))
          .fontWeight(FontWeight.Regular)
        Span($r('app.string.distance_unit'))
          .fontSize($r('app.float.fp_16'))
          .fontColor($r('app.color.color_59542001'))
          .fontWeight(FontWeight.Regular)
      }
      .fontSize($r('app.float.vp_12'))
      .fontColor($r('app.color.color_8F333333'))
      .margin({ top: $r('app.float.vp_10') })

      if (this.sportItem && MonthItemModel.isTargetComplete(this.sportItem) !== undefined) {
        Text(MonthItemModel.getTargetProcessDesc(this.sportItem))
          .fontSize($r('app.float.fp_14'))
          .fontColor($r('app.color.color_542001'))
          .fontWeight(FontWeight.Regular)
          .margin({ top: $r('app.float.vp_4') })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius(this.isShowLineLocus ? $r('app.float.vp_12') : 0)
    .borderWidth(this.isShowLineLocus ? $r('app.float.vp_2') : 0)
    .borderColor(this.isShowLineLocus ? $r('app.color.color_white') : Color.Transparent)
    .backgroundColor(this.isShowLineLocus ? $r('app.color.color_7DFFFFFF') : Color.Transparent)
    .backgroundBlurStyle(this.isShowLineLocus ? BlurStyle.Thick : BlurStyle.NONE, {
      colorMode: ThemeColorMode.LIGHT,
      adaptiveColor: AdaptiveColor.DEFAULT,
      scale: 0.1
    })
    .padding($r('app.float.vp_18'))
  }

  // 运动详细数据
  @Builder
  runDetailData() {
    Column() {
      Column({ space: 40 }) {
        this.runItemDataTime()
        this.runItemData2()
        this.runItemData3()
        this.runItemData4()
      }
      .padding({
        top: $r('app.float.vp_30'),
        bottom: $r('app.float.vp_30'),
        left: $r('app.float.vp_38'),
        right: $r('app.float.vp_38')
      })
      .borderRadius($r('app.float.vp_12'))
      .borderWidth($r('app.float.vp_2'))
      .borderColor($r('app.color.color_white'))
      .backgroundColor($r('app.color.color_7DFFFFFF'))
      .backgroundBlurStyle(BlurStyle.Thick, {
        colorMode: ThemeColorMode.LIGHT,
        adaptiveColor: AdaptiveColor.DEFAULT,
        scale: 0.1
      })
      .margin({ top: this.isShowLineLocus ? $r('app.float.vp_10') : 0 })
    }
  }

  @Builder
  runItemDataTime(){
    Row({ space: 20 }) {
      DataItem({
        dataName: $r('app.string.sport_use_time_length'),
        dataContent: DateUtils.formaterTimeLength(this.sportItem?.timeLength ?? 0)
      })
        .layoutWeight(1.3)

      DataItem({
        dataName: $r('app.string.total_heat_deplete'),
        dataContent: this.sportItem?.deplete?.toString(),
        unit: $r('app.string.deplete_unit')
      })
        .layoutWeight(1)
    }.width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  runItemData2(){
    Row({ space: 20 }) {
      DataItem({
        dataName: $r('app.string.activity_deplete'),
        dataContent: ((Math.floor((this.sportItem?.deplete ?? 0) * 0.8) * 10) / 10).toString(),
        unit: $r('app.string.deplete_unit')
      }).layoutWeight(1.3)

      DataItem({
        dataName: $r('app.string.average_pace'),
        dataContent: MonthItemModel.getPaceStr(this.sportItem),
        unit: $r('app.string.distance_unit')
      })
        .layoutWeight(1)
    }.width(CommonConstants.FULL_PERCENT)
  }

  @Builder
  runItemData3(){
    Row({ space: 20 }) {
      DataItem({
        dataName: $r('app.string.average_speed'),
        dataContent: (((this.sportItem?.distance ?? 0) / 1000) /
          ((this.sportItem?.timeLength ?? 0) / 3600)).toFixed(2),
        unit: $r('app.string.speed_form_hour')
      })
        .layoutWeight(1.3)

      DataItem({
        dataName: $r('app.string.average_step_frequency'),
        dataContent: this.sportItem?.distance ?
          ((this.sportItem?.stepCount ?? 0) / ((this.sportItem?.timeLength ?? 0) / 60)).toFixed() : '0',
        unit: $r('app.string.average_step_frequency_unit')
      })
        .layoutWeight(1)
        .visibility(this.sportItem?.type === SportType.CYCLING ? Visibility.Hidden : Visibility.Visible)
    }.width(CommonConstants.FULL_PERCENT)
  }
  @Builder
  runItemData4(){
    if (this.sportItem?.type !== SportType.CYCLING) {
      Row({ space: 20 }) {
        DataItem({
          dataName: $r('app.string.average_step_size'),
          dataContent: (this.sportItem?.distance && this.sportItem?.stepCount) ?
            (this.sportItem!.distance * 100 / this.sportItem!.stepCount).toFixed() : '0',
          unit: $r('app.string.average_step_size_unit')
        })
          .layoutWeight(1.3)

        DataItem({
          dataName: $r('app.string.step_count'),
          dataContent: this.sportItem?.stepCount?.toString(),
          unit: $r('app.string.step_unit')
        })
          .layoutWeight(1)
      }.width(CommonConstants.FULL_PERCENT)
    }
  }
}

@ComponentV2
struct DataItem {
  @Param @Require dataName: ResourceStr
  @Param @Require dataContent: ResourceStr
  @Param unit: ResourceStr | undefined = undefined

  build() {
    Column() {
      Text() {
        Span(this.dataContent)
          .fontColor($r('app.color.color_333333'))
          .fontSize($r('app.float.fp_28'))
        Span(' ')
        Span(this.unit)
      }
      .fontColor($r('app.color.color_999999'))
      .fontSize($r('app.float.fp_12'))

      Text(this.dataName)
        .fontColor($r('app.color.color_999999'))
        .fontSize($r('app.float.fp_15'))
        .margin({ top: $r('app.float.vp_5') })
    }.alignItems(HorizontalAlign.Start)
  }
}