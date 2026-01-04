import { CountdownTimer } from './CountdownTimer';
import { TimePickerComponent } from './TimePickerComponent';
import { TimeShow } from './TimeShow';
import { promptAction } from '@kit.ArkUI';
import { executionStatus, timeType } from '../constants/TimerCommonConstants';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface TimerExerciseData {
  timeLength: number; // 实际运动时长（秒）
  distance: number; // 距离（米）
  steps: number; // 步数
  deplete: number; // 消耗（卡）
}

@ComponentV2
export struct TimeMainPage {
  @Local allCount: number = 0
  @Local nowCount: number = 0
  @Local hour: number = 0
  @Local minute: number = 0
  @Local second: number = 0
  @Consumer('isRunning') isRunning: executionStatus = executionStatus.over
  private hasStarted: boolean = false; // 标记是否真正开始过运动
  @Local progressValue: number = 0; // 当前进度百分比
  private timerFinished: boolean = false; // 标记倒计时是否已完成，避免重复触发
  private hasProcessedOver: boolean = false; // 标记是否已经处理过结束逻辑，避免重复保存
  @Event isRunningChange: (status: executionStatus) => void
  @Event onProgressChange: (progress: number) => void
  @Event onTimerFinished: () => void

  @Monitor('isRunning')
  isRunningChangeFunction() {
    if (this.isRunning === executionStatus.Start) {
      // 检查时间是否有效
      if (this.hour === 0 && this.minute === 0 && this.second === 0) {
        promptAction.showToast({ message: '请选择时间' })
        this.isRunningChange(executionStatus.over)
        return
      }

      // 检查是否刚结束运动还未重新设置时间（倒计时已归零）
      if (this.nowCount >= this.allCount) {
        promptAction.showToast({ message: '请重新设置时间' })
        this.isRunningChange(executionStatus.over)
        return
      }

      // 标记已真正开始运动
      this.hasStarted = true;
      this.timerFinished = false; // 重置倒计时完成标记
      this.hasProcessedOver = false; // 重置已处理结束逻辑的标记

      // 通过emitter通知计时开始
      try {
        emitter.emit('timeMainPageTimerStart', {
          data: {
            allCount: this.allCount,
            nowCount: this.nowCount
          }
        });
      } catch (error) {
        hilog.error(0x0000, 'TimeMainPage', 'emitter emit timeMainPageTimerStart error');
      }

      // 计算进度百分比（用于语音播报）
      if (this.allCount > 0) {
        this.progressValue = (this.nowCount / this.allCount) * 100;
        // 通知父组件进度变化（用于语音播报）
        this.onProgressChange(this.progressValue);
      }
    }
    if (this.isRunning === executionStatus.Pause) {
      // 通过emitter通知计时暂停
      try {
        emitter.emit('timeMainPageTimerPause', {
          data: {
            allCount: this.allCount,
            nowCount: this.nowCount
          }
        });
      } catch (error) {
        hilog.error(0x0000, 'TimeMainPage', 'emitter emit timeMainPageTimerPause error');
      }
    }
    if (this.isRunning === executionStatus.over) {
      // 避免重复触发保存逻辑（如果已经处理过，直接返回）
      if (this.hasProcessedOver) {
        return;
      }
      // 标记已经处理过结束逻辑
      this.hasProcessedOver = true;

      // 保存运动记录前先计算实际运动时长
      // nowCount 是已经运动的时长（从0累加到allCount）
      // 如果倒计时自然结束，nowCount 应该等于 allCount
      // 如果用户手动结束，nowCount 是实际运动时长
      let actualTimeLength = this.nowCount;

      // 如果倒计时自然结束（timerFinished 为 true），确保使用 allCount 作为实际运动时长
      if (this.timerFinished) {
        // 倒计时自然结束，使用 allCount 作为实际运动时长
        actualTimeLength = this.allCount;
      } else if (this.nowCount < this.allCount) {
        // 用户手动结束，使用 nowCount 作为实际运动时长
        actualTimeLength = this.nowCount;
      }

      // 记录是否应该保存（只有真正开始过运动才保存）
      // 注意：hasStarted 在运动开始时设置为 true，只有在倒计时自然结束或用户手动结束时才会被重置
      // 如果倒计时自然结束（timerFinished 为 true），即使 hasStarted 可能被重置，也应该保存
      // 手动结束时，只要 hasStarted 为 true 且 actualTimeLength > 0，就应该保存
      const shouldSave = actualTimeLength > 0 && (this.hasStarted || this.timerFinished);

      // 重置运动数据（保留 allCount 以便表盘显示）
      this.nowCount = this.allCount // 重置为 allCount（表示倒计时完成）
      this.hour = 0
      this.minute = 0
      this.second = 0
      this.hasStarted = false // 重置运动开始标志
      this.progressValue = 0 // 重置进度
      this.timerFinished = false // 重置倒计时完成标记

      // 通过emitter通知计时结束，请求保存数据
      try {
        emitter.emit('timeMainPageTimerOver', {
          data: {
            actualTimeLength: actualTimeLength,
            shouldSave: shouldSave
          }
        });
      } catch (error) {
        hilog.error(0x0000, 'TimeMainPage', 'emitter emit timeMainPageTimerOver error');
      }
    }
  }

  @Monitor('nowCount')
  onNowCountChange() {
    // 如果运动已经结束，不触发进度更新和播报
    if (this.isRunning === executionStatus.over) {
      return;
    }

    // 计算进度百分比（用于语音播报）
    if (this.allCount > 0) {
      this.progressValue = (this.nowCount / this.allCount) * 100;
      // 通知父组件进度变化（用于语音播报）
      this.onProgressChange(this.progressValue);

      // 通过emitter通知计时进度变化
      try {
        emitter.emit('timeMainPageTimerProgress', {
          data: {
            allCount: this.allCount,
            nowCount: this.nowCount,
            progressValue: this.progressValue
          }
        });
      } catch (error) {
        hilog.error(0x0000, 'TimeMainPage', 'emitter emit timeMainPageTimerProgress error');
      }
    }
  }

  build() {

    Column() {
      TimeShow({ allCount: this.allCount, nowCount: this.nowCount })
      CountdownTimer({
        totalSeconds: this.allCount,
        progressChange: (count: number) => {
          this.nowCount = count
        },
        onTimerFinished: () => {
          // 倒计时结束时，更新状态为 over
          // 注意：此时 isRunning 可能还是 Start 状态（因为 CountdownTimer 中的 isRunning 是本地变量）
          // 所以我们需要无条件更新状态，确保保存逻辑能够触发
          if (!this.timerFinished) {
            this.timerFinished = true;
            // 确保 nowCount 等于 allCount（倒计时完成）
            // 因为 CountdownTimer 在调用 over() 之前，最后一次 progressChange 可能还没触发
            if (this.nowCount < this.allCount) {
              this.nowCount = this.allCount;
            }
            // 标记倒计时已完成，然后触发状态变更（这会触发保存逻辑）
            this.isRunningChange(executionStatus.over);
          }
        }
      })
      TimePickerComponent({
        isRunning: this.isRunning,
        changeFactory: (type: timeType, count: number) => {
          if (type === timeType.hours) {
            this.hour = count
          } else if (type === timeType.minutes) {
            this.minute = count
          } else {
            this.second = count
          }
          this.allCount = this.hour * 3600 + this.minute * 60 + this.second
          // 重新设置时间时，重置 nowCount 和 hasStarted，允许重新开始运动
          this.nowCount = 0
          this.hasStarted = false
          this.progressValue = 0

          // 通过emitter通知时间变化
          try {
            emitter.emit('timeMainPageTimeChange', {
              data: {
                allCount: this.allCount,
                nowCount: this.nowCount
              }
            });
          } catch (error) {
            hilog.error(0x0000, 'TimeMainPage', 'emitter emit timeMainPageTimeChange error');
          }
        }
      })
        .visibility(this.isRunning === executionStatus.over ? Visibility.Visible : Visibility.None)
        .margin({
          top: 30
        })
    }
    .width('100%')
  }
}
