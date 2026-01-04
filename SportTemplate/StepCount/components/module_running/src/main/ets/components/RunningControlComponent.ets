import { ControlType } from '../models/RealTimeMotionModel';
import { emitter } from '@kit.BasicServicesKit';
import { display, promptAction } from '@kit.ArkUI';
import { RunCommonConstants } from '../common/RunCommonConstants';
import { RunLogger } from '../utils/RunLogger';

/**
 * 运行控制组件
 */
@ComponentV2
export struct RunningControlComponent {
  @Local pause: boolean = false
  @Param @Require buttonClick?: (controlType: ControlType) => void;
  @Param showStartButton?: boolean = false // 初始化时true:中间显示开始按钮，false:默认显示暂停
  @Local needStartButton?: boolean = false
  @Local lockCount: number = 0;
  @Local count: number = 0;
  @Consumer('runningControlLock') lock: boolean = false;
  @Consumer('isSelectTime') isSelectTime: boolean = false
  longDuration: number = 2; // 长按时长
  finishSign: boolean = false;
  @Local screenWith: number = Number((this.getUIContext().px2vp(display.getDefaultDisplaySync().width) / 2).toFixed())

  aboutToAppear(): void {
    this.needStartButton = this.showStartButton
    try {
      emitter.on('continueExercising', () => {
        if (!this.lock) {
          this.count = 0
          if (this.buttonClick) {
            this.buttonClick(ControlType.Start)
          }
          this.pause = false
        }
      })
      emitter.on('resetButtonStatus', () => {
        this.lock = false
        this.pause = false
        this.count = 0
        this.finishSign = false
        this.needStartButton = this.showStartButton
      })
    } catch (error) {
      RunLogger.error('RunningControlComponent', 'aboutToAppear emitter on error')
    }
  }

  aboutToDisappear(): void {
    try {
      emitter.off('continueExercising')
      emitter.off('resetButtonStatus')
    } catch (error) {
      RunLogger.error('RunningControlComponent', 'aboutToDisappear error')
    }
  }

  build() {
    Row() {
      // 未上锁
      this.unlockButtonBuilder()

      if (this.lock) {
        // 已上锁
        this.longPressUnlockButtonBuilder()
      } else {
        this.unlockButtonBuilder2()
      }
      // 设置按钮
      this.settingButtonBuilder()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(RunCommonConstants.FULL_PERCENT)
    .height(74)
  }

  // 未上锁且暂停
  @Builder
  unlockButtonBuilder2() {
    if (this.needStartButton) {
      this.reStartButtonBuilder()
    }
    if (!this.pause) {
      this.runningPauseButtonBuilder()
    } else {
      this.longPressUnlockButtonBuilder2()
      this.unlockButtonBuilder3()
    }
  }

  // 暂停
  @Builder
  runningPauseButtonBuilder() {
    Image($r('app.media.ic_running_pause'))
      .height(74)
      .borderRadius(37)
      .pressedStyle()
      .onClick(() => {
        if (!this.lock) {
          if (this.buttonClick) {
            this.buttonClick(ControlType.Pause)
          }
          this.pause = true
        }
      })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
      .visibility(this.needStartButton ? Visibility.None : Visibility.Visible)
  }

  // 未上锁且开始
  @Builder
  unlockButtonBuilder3() {
    Stack({ alignContent: Alignment.Center }) {
      Image($r('app.media.ic_running_start'))
        .height(74)
        .borderRadius(37)
        .pressedStyle()
        .onClick(() => {
          if (!this.lock) {
            if (this.buttonClick) {
              this.buttonClick(ControlType.Start)
            }
            this.pause = false
          }
        })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      Text($r('app.string.running_pressed_continue'))
        .fontSize(12)
        .fontColor('#aaaaaa')
        .offset({
          y: 55
        })
    }
  }

  // 长按结束
  @Builder
  longPressUnlockButtonBuilder2() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.count, total: this.longDuration, type: ProgressType.Ring }).width(84).height(84)
        .color('#ea4646')
      Image($r('app.media.ic_running_end'))
        .height(74)
        .borderRadius(37)
        .pressedStyle()
        .gesture(
          LongPressGesture({ repeat: true })
            .onAction((event: GestureEvent) => {
              if (!this.lock && event && event.repeat) {
                this.finishSign = false
                if (this.count >= this.longDuration - 1) {
                  this.finishSign = true
                  if (!this.lock && this.finishSign && this.buttonClick) {
                    this.buttonClick(ControlType.End)
                  }
                  this.count = 2
                  return
                }
                this.count++
              }
            })
            .onActionEnd((event: GestureEvent) => {
              if (!this.finishSign) {
                this.count = 0
              }
            })
        )
        .onClick(() => {
          promptAction.showToast({ message: $r('app.string.running_pressed_end') })
        })
      Text($r('app.string.running_pressed_end'))
        .fontSize(12)
        .fontColor('#aaaaaa')
        .offset({
          y: 55
        })
    }
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  // 重新开始按钮
  @Builder
  reStartButtonBuilder() {
    Image($r('app.media.ic_running_start'))
      .height(74)
      .borderRadius(37)
      .pressedStyle()
      .onClick(() => {
        if (this.isSelectTime) {
          this.buttonClick && this.buttonClick(ControlType.Begin)
          this.needStartButton = false
          this.pause = false
        } else {
          promptAction.showToast({ message: '请选择时间' })
        }
      })
      .animation({
        duration: 300,
        curve: Curve.EaseInOut
      })
  }

  // 长按解锁
  @Builder
  longPressUnlockButtonBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.lockCount, total: this.longDuration, type: ProgressType.Ring })
        .width(56)
        .color('#3c3c3e')
        .style({ strokeWidth: 1.5 })
        .visibility(!this.lock ? Visibility.Hidden : Visibility.Visible)
      Image($r('app.media.ic_running_lock'))
        .height(50)
        .borderRadius(25)
        .pressedStyle()
        .draggable(false)
        .gesture(
          LongPressGesture({ repeat: true })
            .onAction((event: GestureEvent) => {
              if (this.lock && event && event.repeat) {
                if (this.lockCount >= this.longDuration) {
                  this.lock = false
                  return
                }
                this.lockCount++
              }
            })
            .onActionEnd((event: GestureEvent) => {
              this.lockCount = 0
              if (!this.lock && this.buttonClick) {
                this.buttonClick(ControlType.Unlock)
              }
            })
        )
      Text($r('app.string.running_pressed_unlock'))
        .fontSize(12)
        .fontColor('#aaaaaa')
        .offset({
          y: 40
        })
    }
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  // 未上锁按钮
  @Builder
  unlockButtonBuilder() {
    Image($r('app.media.ic_running_unlock'))
      .height(50)
      .borderRadius(25)
      .pressedStyle()
      .draggable(false)
      .onClick(() => {
        this.lock = !this.lock
        if (this.buttonClick) {
          this.buttonClick(ControlType.Lock)
        }
      })
      .transition(TransitionEffect.translate({ x: this.screenWith - RunCommonConstants.PADDING_XXL - 25 })
        .animation({ duration: 300 }))
      .visibility(this.lock ? Visibility.Hidden : Visibility.Visible)
  }

  // 设置按钮
  @Builder
  settingButtonBuilder() {
    Image($r('app.media.ic_running_setting'))
      .height(50)
      .borderRadius(25)
      .pressedStyle()
      .onClick(() => {
        if (!this.lock && this.buttonClick) {
          this.buttonClick(ControlType.Setting)
        }
      })
      .transition(TransitionEffect.translate({ x: -this.screenWith + RunCommonConstants.PADDING_XXL + 25 })
        .animation({ duration: 300 }))
      .visibility(this.lock ? Visibility.Hidden : Visibility.Visible)
  }

  @Styles
  pressedStyle(){
    .aspectRatio(1)
    .draggable(false)
    .stateStyles({
      normal: {
        .backgroundColor(Color.Transparent)
      },
      pressed: {
        .backgroundColor($r('sys.color.interactive_pressed'))
      },
    })
  }
}