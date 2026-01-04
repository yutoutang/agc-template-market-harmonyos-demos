import { AppStorageV2 } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'
import { CommonConstants, ResUtil, RouterMap, RouterUtils, WindowModel } from 'lib_common'
import { NavHeaderBar } from 'lib_widget'
import { CatType, StepDetail } from '../model/StepDetailType'
import { ColorSlider } from '../components/Slider'
import { DayWeekMonthSwitcher } from '../components/DayWeekMonthSwitcher'
import { StepCountVM } from '../viewmodels/StepCountVM'
import { Logger } from 'ui_base'

@Builder
export function stepDetailPageBuilder() {
  StepDetailPage()
}

/**
 * 步数详情页面
 */
@ComponentV2
struct StepDetailPage {
  @Local vm: StepCountVM = new StepCountVM(RouterMap.STEP_DETAIL_PAGE)
  @Local catType: CatType = CatType.STEP_COUNT

  aboutToAppear(): void {
    const params = RouterUtils.getParamByName<StepDetail>(RouterMap.STEP_DETAIL_PAGE)
    if (params) {
      this.catType = params.catType
      this.vm.querySportRecord(params.date)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Stack({ alignContent: Alignment.Top }) {
            //进度展示
            this.processBuilder()

            Column() {
              DayWeekMonthSwitcher({ dateType: this.vm.dateType!!, curDate: this.vm.curDate!! })

              Text((this.vm.selectData?.obj ?? '') as string)
                .fontColor($r('app.color.color_black'))
                .fontSize(15)
                .margin(6)
            }.margin({
              left: CommonConstants.PADDING_L,
              right: CommonConstants.PADDING_L,
              top: ResUtil.getNumber($r('app.float.nav_header_height')) +
              AppStorageV2.connect(WindowModel, () => new WindowModel())!.windowTopPadding +
              CommonConstants.PADDING_PAGE
            })
          }

          Column({ space: 9 }) {
            //步数目标
            Text($r('app.string.step_target'))
              .fontColor($r('app.color.color_000000'))
              .fontColor($r('app.float.fp_16'))
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Start)

            Column() {
              Text($r('app.string.step_target_process', this.getStepTargetProcess()))
                .fontColor($r('app.float.fp_16'))
                .fontColor($r('app.color.color_999999'))

              ColorSlider({
                value: this.vm.curRecords[0]?.totalStepCount,
                maxValue: this.vm.curRecords[0]?.totalTarget?.stepCount,
                colors: [[$r('sys.color.ohos_id_color_emphasize'), 0],
                  [$r('sys.color.ohos_id_color_emphasize'), 1]]
              }).margin({ top: $r('app.float.vp_20') })

              Row() {
                Text((this.vm.curRecords[0]?.totalStepCount ?? 0).toString())
                  .fontColor($r('app.color.color_E6333333'))
                  .fontSize($r('app.float.fp_16'))

                Text((this.vm.curRecords[0]?.totalTarget?.stepCount ?? 0).toString())
                  .fontColor($r('app.color.color_E6333333'))
                  .fontSize($r('app.float.fp_16'))
              }.justifyContent(FlexAlign.SpaceBetween)
              .width(CommonConstants.FULL_PERCENT)
              .margin({ top: $r('app.float.vp_12') })
            }
            .padding({
              left: $r('app.float.vp_14'),
              right: $r('app.float.vp_14'),
              top: $r('app.float.vp_18'),
              bottom: $r('app.float.vp_18')
            })
            .backgroundColor(Color.White)
            .borderRadius($r('app.float.vp_12'))

            Blank()

            Button({ type: ButtonType.Normal }) {
              Text($r('app.string.continue_sport'))
                .fontColor(Color.White)
                .fontSize($r('app.float.fp_16'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .height($r('app.float.vp_40'))
            .borderRadius($r('sys.float.corner_radius_level10'))
            .backgroundColor($r('app.color.color_FF6017'))
            .onClick(() => {
              RouterUtils.popToName(RouterMap.INDEX_PAGE)
              try {
                emitter.emit('switchTabIndex', { data: 1 })
              } catch (error) {
                Logger.error('StepDetailPage', 'emitter emit switchTabIndex error')
              }
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .padding(CommonConstants.PADDING_PAGE)
          .backgroundColor($r('app.color.color_F1F3F5'))
          .layoutWeight(1)
        }.width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)

        //TitleBar
        NavHeaderBar({
          title: this.getTitleStr()
        })
      }
    }
    .hideTitleBar(true)
    .padding({
      bottom: AppStorageV2.connect(WindowModel, () => new WindowModel())!.windowBottomPadding
    })
    .backgroundColor(Color.White)
  }

  @Builder
  processBuilder() {
    Column() {
      Column() {
        Text(this.getProgressLabel())
          .fontSize($r('app.float.fp_15'))
          .fontColor($r('app.color.color_B3000000'))

        Stack() {
          Progress({
            value: this.getProgressValue(),
            total: this.getTargetValue(),
            type: ProgressType.Ring
          })
            .margin({ top: $r('app.float.vp_5') })
            .width($r('app.float.vp_150'))
            .color(this.getLinearGradient())
            .style({ strokeWidth: 10 })

          Column({ space: 8 }) {
            Image(this.getProgressIcon())
              .width($r('app.float.vp_24'))

            Text(this.getProgressStr())
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_32'))

            Text(this.getTargetStr())
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_14'))
          }
        }.margin({ top: $r('app.float.vp_12') })
      }.linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [['#00FFFFFF', 0], ['#FFFFFF', 1]]
      }).padding({
        top: $r('app.float.vp_90'),
        left: $r('app.float.vp_16'),
        right: $r('app.float.vp_16'),
        bottom: $r('app.float.vp_16')
      }).borderRadius(12)
      .width(CommonConstants.FULL_PERCENT)
    }.width(CommonConstants.FULL_PERCENT)
    .padding({
      top: ResUtil.getNumber($r('app.float.nav_header_height')) +
      AppStorageV2.connect(WindowModel, () => new WindowModel())!.windowTopPadding +
      CommonConstants.PADDING_PAGE,
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
    .linearGradient({
      direction: GradientDirection.Bottom,
      repeating: false,
      colors: [['#FFC385', 0], ['#FFE7CC', 0.3], ['#F1F3F5', 1]]
    })
  }

  getTitleStr() {
    if (this.catType === CatType.STEP_COUNT) {
      return $r('app.string.step_count')
    } else if (this.catType === CatType.DISTANCE) {
      return $r('app.string.distance')
    } else if (this.catType === CatType.DEPLETE) {
      return $r('app.string.deplete')
    } else {
      return ''
    }
  }

  getProgressLabel() {
    if (this.catType === CatType.STEP_COUNT) {
      return $r('app.string.total_step_count')
    } else if (this.catType === CatType.DISTANCE) {
      return $r('app.string.total_distance')
    } else if (this.catType === CatType.DEPLETE) {
      return $r('app.string.total_deplete')
    } else {
      return ''
    }
  }

  getProgressValue() {
    if (this.catType === CatType.STEP_COUNT) {
      return this.vm.curRecords[0]?.totalStepCount
    } else if (this.catType === CatType.DISTANCE) {
      return this.vm.curRecords[0]?.totalDistance
    } else if (this.catType === CatType.DEPLETE) {
      return this.vm.curRecords[0]?.totalDeplete
    } else {
      return 0
    }
  }

  getTargetValue() {
    if (this.catType === CatType.STEP_COUNT) {
      return this.vm.curRecords[0]?.totalTarget?.stepCount
    } else if (this.catType === CatType.DISTANCE) {
      return this.vm.curRecords[0]?.totalTarget?.distance
    } else if (this.catType === CatType.DEPLETE) {
      return this.vm.curRecords[0]?.totalTarget?.deplete
    } else {
      return 0
    }
  }

  getLinearGradient() {
    if (this.catType === CatType.STEP_COUNT) {
      return new LinearGradient([{ color: '#86C1FF', offset: 0 },
        { color: '#254FF7', offset: 1.0 }])
    } else if (this.catType === CatType.DISTANCE) {
      return new LinearGradient([{ color: '#10DCDD', offset: 0 },
        { color: '#0DC599', offset: 1.0 }])
    } else if (this.catType === CatType.DEPLETE) {
      return new LinearGradient([{ color: '#FFA63F', offset: 0 },
        { color: '#FF6B36', offset: 1.0 }])
    } else {
      return new LinearGradient([{ color: '#FFA63F', offset: 0 },
        { color: '#FF6B36', offset: 1.0 }])
    }
  }

  getProgressIcon() {
    if (this.catType === CatType.STEP_COUNT) {
      return $r('app.media.ic_chart_step')
    } else if (this.catType === CatType.DISTANCE) {
      return $r('app.media.ic_chart_distance')
    } else if (this.catType === CatType.DEPLETE) {
      return $r('app.media.ic_chart_deplete')
    } else {
      return ''
    }
  }

  getProgressStr() {
    if (this.catType === CatType.STEP_COUNT) {
      return this.vm.curRecords[0]?.totalStepCount?.toString()
    } else if (this.catType === CatType.DISTANCE) {
      return ((this.vm.curRecords[0]?.totalDistance ?? 0) / 1000).toString()
    } else if (this.catType === CatType.DEPLETE) {
      return this.vm.curRecords[0]?.totalDeplete.toString()
    } else {
      return ''
    }
  }

  getTargetStr() {
    if (this.catType === CatType.STEP_COUNT) {
      return (this.vm.curRecords[0]?.totalTarget?.stepCount ?? 0).toString() +
      ResUtil.getStringSync($r('app.string.step_unit'))
    } else if (this.catType === CatType.DISTANCE) {
      return ((this.vm.curRecords[0]?.totalTarget?.distance ?? 0) / 1000).toString() +
      ResUtil.getStringSync($r('app.string.distance_unit'))
    } else if (this.catType === CatType.DEPLETE) {
      return (this.vm.curRecords[0]?.totalTarget?.deplete ?? 0).toString() +
      ResUtil.getStringSync($r('app.string.deplete_unit'))
    } else {
      return ''
    }
  }

  getStepTargetProcess() {
    if (this.vm.curRecords[0]?.totalTarget?.stepCount) {
      return Number(((this.vm.curRecords[0]?.totalStepCount ?? 0) /
        (this.vm.curRecords[0]?.totalTarget?.stepCount ?? 0) * 100).toFixed())
    }
    return 0
  }
}
