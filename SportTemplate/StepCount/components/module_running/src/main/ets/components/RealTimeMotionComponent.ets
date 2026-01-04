import { RunCommonConstants } from '../common/RunCommonConstants';
import { RunningConstants } from '../common/RunningConstants';
import { ControlType } from '../models/RealTimeMotionModel';
import { MotionType, RealTimeMotionVM, SportType } from '../viewmodels/RealTimeMotionVM';
import { RunningControlComponent } from './RunningControlComponent';

/**
 * 实时运动信息组件
 */
@ComponentV2
export struct RealTimeMotionComponent {
  @Param @Require buttonClick?: (controlType: ControlType) => void;
  @Consumer('runningControlLock') lock: boolean = false;
  @Consumer('realTimeMotionVM') realTimeMotionVM?: RealTimeMotionVM
  @Param motionType: MotionType = MotionType.target;
  @Param moveType: SportType = SportType.WALKING
  @Local showSign: boolean = false;

  aboutToAppear(): void {
    setTimeout(() => {
      this.showSign = true;
    }, 900)
  }

  /**
   * 是否遛狗
   * @returns
   */
  checkWalkDog(): boolean {
    return this.moveType === SportType.WALKING && this.motionType === MotionType.walkDog
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          // 卡片进度信息
          this.progressInfoBuilder()

          // 公里数
          this.distanceBuilder()

          // 用时和热量信息
          this.timeAndHeatBuilder()

          // 配速和步数信息
          this.paceAndStepsBuilder()
        }
        .height(this.checkWalkDog() ? RunningConstants.BIND_SHEET_MID :
          (this.motionType !== MotionType.target ? RunningConstants.BIND_SHEET_MID_L : RunningConstants.BIND_SHEET_MAX))
        .onTouchIntercept((data) => {
          return this.lock ? HitTestMode.Block : HitTestMode.Transparent;
        })
        .visibility(this.showSign ? Visibility.Visible : Visibility.Hidden)

        // 按钮控制组件
        RunningControlComponent({
          buttonClick: (controlType: ControlType) => {
            if (controlType === ControlType.Lock) {
              this.lock = true
            } else {
              this.lock = false
            }
            this.buttonClick?.(controlType)
          }
        })
          .onTouchIntercept((data) => {
            return HitTestMode.Transparent;
          })
          .margin({
            bottom: 70 + (this.lock ? -16 : 0)
          })
      }
      .padding({
        left: RunCommonConstants.PADDING_L,
        right: RunCommonConstants.PADDING_L,
      })
      .visibility(this.realTimeMotionVM!.showAll ? Visibility.Visible : Visibility.None)
      .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))

      // 总数据展示
      this.totalDataBuilder()
    }
  }

  // 卡片进度信息
  @Builder
  progressInfoBuilder() {
    Blank().height(this.lock ? 16 : 0)

    Column() {
      Row() {
        Text($r('app.string.target', this.realTimeMotionVM?.targetType, this.realTimeMotionVM?.parameterDesc))
          .fontColor('#e6333333')
          .fontSize(16)
          .fontWeight(FontWeight.Regular)
          .margin({ right: RunCommonConstants.PADDING_L })
        Text() {
          Span($r('app.string.running_finish'))
          Span(' ' + this.realTimeMotionVM?.progressValue)
          Span($r('app.string.running_percent'))
        }
        .fontColor('#FFFE6F00')
        .fontSize(16)
        .fontWeight(FontWeight.Regular)
      }
      .width(RunCommonConstants.FULL_PERCENT)
      .margin({ left: RunCommonConstants.PADDING_L, right: RunCommonConstants.PADDING_L })

      Slider({
        value: (Number(this.realTimeMotionVM?.progressValue) >= 100 ? 100 :
          Number(this.realTimeMotionVM?.progressValue)) ?? 0,
        min: 0,
        max: 100,
        style: SliderStyle.InSet
      })
        .margin({ left: RunCommonConstants.PADDING_M, right: RunCommonConstants.PADDING_M })
        .trackThickness(20)
        .enabled(false)
        .sliderInteractionMode(SliderInteraction.SLIDE_ONLY)
        .blockColor('#FFFFFF')
        .trackColor($r('sys.color.comp_background_secondary'))
        .selectedColor($r('sys.color.comp_background_emphasize')) // api 18 支持渐变色
    }
    .margin({ top: 8 })
    .alignItems(HorizontalAlign.Start)
    .borderRadius(12)
    .backgroundColor('#F2F2F2')
    .padding({ top: RunCommonConstants.PADDING_L })
    .width(RunCommonConstants.FULL_PERCENT)
    .visibility(this.motionType === MotionType.target ? Visibility.Visible : Visibility.None)
  }

  // 公里数
  @Builder
  distanceBuilder() {
    Column() {
      Text(String(this.realTimeMotionVM?.distanceKM))
        .fontColor('#363642')
        .fontSize(64)
        .fontWeight(FontWeight.Regular)
      Text($r('app.string.mileage'))
        .fontColor('#E6484848')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
    }
    .margin({ top: 16 })
    .width(RunCommonConstants.FULL_PERCENT)
  }

  // 用时和热量信息
  @Builder
  timeAndHeatBuilder() {
    Row() {
      Column() {
        Text(this.realTimeMotionVM?.durationMS)
          .textStyle()
        Text($r('app.string.running_time'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(this.checkWalkDog() ? HorizontalAlign.Center : HorizontalAlign.Start)

      Column() {
        Text(String(this.realTimeMotionVM?.heat))
          .textStyle()
        Text($r('app.string.running_calorie'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .alignItems(this.checkWalkDog() ? HorizontalAlign.Center : HorizontalAlign.Start)

      Column() {
        Text(String(this.realTimeMotionVM?.steps))
          .textStyle()
        Text($r('app.string.running_step'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .alignItems(this.checkWalkDog() ? HorizontalAlign.Center : HorizontalAlign.Start)
      .visibility(this.checkWalkDog() ? Visibility.Visible : Visibility.None)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: this.checkWalkDog() ? 10 : 28,
      right: this.checkWalkDog() ? 10 : 28,
      top: 16
    })
    .width(RunCommonConstants.FULL_PERCENT)
  }

  // 配速和步数信息
  @Builder
  paceAndStepsBuilder() {
    Row() {
      Column() {
        Text(String(this.realTimeMotionVM?.pace))
          .textStyle()
        Text($r('app.string.running_speed'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .visibility(this.motionType !== MotionType.walkDog ? Visibility.Visible : Visibility.None)

      Column() {
        Text(String(this.realTimeMotionVM?.steps))
          .textStyle()
        Text($r('app.string.running_step'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }
      .width(120)
      .alignItems(HorizontalAlign.Start)
      .visibility(this.realTimeMotionVM?.sportType === SportType.CYCLING ? Visibility.None : Visibility.Visible)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: 28,
      right: 28,
      top: 22
    })
    .width(RunCommonConstants.FULL_PERCENT)
    .visibility(this.motionType !== MotionType.walkDog ? Visibility.Visible : Visibility.None)
  }

  // 总数据展示
  @Builder
  totalDataBuilder() {
    Row() {
      Column() {
        Text(this.realTimeMotionVM?.distanceKM)
          .fontColor('#363642')
          .fontSize(34)
          .fontWeight(FontWeight.Regular)
        Text($r('app.string.running_total_distance'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }

      Column() {
        Text(String(this.realTimeMotionVM?.duration))
          .fontColor('#363642')
          .fontSize(34)
          .fontWeight(FontWeight.Regular)
        Text($r('app.string.running_total_time'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }

      Column() {
        Text(String(this.realTimeMotionVM?.pace))
          .fontColor('#363642')
          .fontSize(34)
          .fontWeight(FontWeight.Regular)
          .margin({ bottom: 7 })
        Text($r('app.string.running_speed'))
          .fontColor('#e6484848')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
      }

    }
    .width(RunCommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: RunCommonConstants.PADDING_XXL,
      right: RunCommonConstants.PADDING_XXL,
      top: 32
    })
    .visibility(!this.realTimeMotionVM!.showAll ? Visibility.Visible : Visibility.None)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
  }
}

@Extend(Text)
function textStyle() {
  .fontColor('#FF363642')
  .fontSize(32)
  .fontWeight(FontWeight.Regular)
}

