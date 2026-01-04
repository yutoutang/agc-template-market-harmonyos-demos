import { executionStatus, TimerCommonConstants } from '../constants/TimerCommonConstants';
import { Callback, emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 定义一个eventId为1的事件。
let event: emitter.InnerEvent = {
  eventId: 1
};

@ComponentV2
export struct CountdownTimer {
  @Param setHour: number = 0
  @Param setMinute: number = 0
  @Param setSecond: number = 0
  @Local hours: number = 0
  @Local minutes: number = 0
  @Local seconds: number = 0
  @Event progressChange: (count: number) => void
  @Event onTimerFinished: () => void
  @Param totalSeconds: number = 0
  @Local currentCount: number = 0
  private timerId: number = 0
  @Consumer('showTimeover') showTimeover: boolean = false
  @Consumer('isRunning') isRunning: executionStatus = executionStatus.over

  @Monitor('isRunning')
  isRunningOnChange() {
    if (this.isRunning === executionStatus.Start) {
      // 如果是第一次开始（currentCount为0）或时间被重新设置（currentCount大于totalSeconds），则重置
      if (this.currentCount === 0 || this.currentCount > this.totalSeconds) {
        this.currentCount = this.totalSeconds
      }
      this.start()
    } else if (this.isRunning === executionStatus.Pause) {
      this.pause()
    } else if (this.isRunning === executionStatus.over) {
      this.over()
    }
  }

  // 开始倒计时
  start() {
    this.timerId = setInterval(() => {
      if (this.currentCount > 0) {
        this.currentCount--
        this.progressChange(this.totalSeconds - this.currentCount)
        this.updateDisplay(this.currentCount)
      } else {
        this.over()
      }
    }, TimerCommonConstants.NUMBER_1000)
  }

  // 结束倒计时
  over() {

    clearInterval(this.timerId)
    this.currentCount = 0
    this.updateDisplay(0)
    //跑步结束
    this.showTimeover = false
    this.isRunning = executionStatus.over
    // 通知父组件倒计时已完成
    this.onTimerFinished()
  }

  // 暂停倒计时
  pause() {
    clearInterval(this.timerId)
  }

  // 更新显示
  private updateDisplay(seconds: number) {
    this.hours = Math.floor(seconds / 3600)
    this.minutes = Math.floor((seconds % 3600) / 60)
    this.seconds = seconds % 60
  }

  // 格式化数字，确保两位数显示
  private formatNumber(num: number): string {
    return num < 10 ? `0${num}` : `${num}`
  }

  aboutToAppear(): void {
    this.subEvent()
  }

  //订阅时间函数
  subEvent() {
    // 定义一个事件的回调处理函数，当收到对应的事件后执行回调函数
    let callback: Callback<emitter.EventData> = (eventData: emitter.EventData) => {
      this.updateDisplay(eventData.data?.sum)
    }

    // 收到eventId为1的事件后执行回调函数
    try {
      emitter.on(event, callback);
    } catch (error) {
      hilog.error(0x0000, 'CountdownTimer', 'emitter on error');
    }
  }

  build() {
    Column({ space: 20 }) {
      // 倒计时显示
      Row({ space: 10 }) {
        // 小时
        Text(this.formatNumber(this.hours))
          .timeTextStyle()

        // 分隔符
        Text(':')
          .timeTextStyle()

        // 分钟
        Text(this.formatNumber(this.minutes))
          .timeTextStyle()

        // 分隔符
        Text(':')
          .timeTextStyle()

        // 秒
        Text(this.formatNumber(this.seconds))
          .timeTextStyle()
      }
      .justifyContent(FlexAlign.Center)
    }
    .width(TimerCommonConstants.PERCENT_100)
    .justifyContent(FlexAlign.Center)
  }
}

@Extend(Text)
function timeTextStyle() {
  .fontSize(TimerCommonConstants.FONT_SIZE_23)
  .fontColor($r('app.color.757E95'))
}