import { executionStatus, TimerCommonConstants, timeType } from '../constants/TimerCommonConstants';
import { emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 定义一个eventId为1的事件，事件优先级为Low。
let event: emitter.InnerEvent = {
  eventId: 1,
  priority: emitter.EventPriority.LOW
};

@ComponentV2
export struct TimePickerComponent {
  @Local hours: string[] = []
  @Local minutes: string[] = []
  @Local seconds: string[] = []
  @Local hour: number = 0;
  @Local minute: number = 0;
  @Local second: number = 0;
  @Param isRunning: executionStatus = executionStatus.Pause
  @Consumer('isSelectTime') isSelectTime: boolean = false
  @Event changeFactory: (type: timeType, count: number) => void

  @Monitor('isRunning')
  isRunningOnChange() {
    if (this.isRunning === executionStatus.over) {
      this.hour = 0
      this.minute = 0
      this.second = 0
    }
  }

  generateNumbersWithKeys(maxNumber: number): string[] {
    return Array.from(new Array(maxNumber).keys()).map(num => num.toString());
  }

  aboutToAppear(): void {
    this.hours = this.generateNumbersWithKeys(TimerCommonConstants.NUMBER_100)
    this.minutes = this.generateNumbersWithKeys(TimerCommonConstants.NUMBER_60)
    this.seconds = this.generateNumbersWithKeys(TimerCommonConstants.NUMBER_60)
  }

  sendEvent() {
    let sum = this.hour * 3600 + this.minute * 60 + this.second
    let eventData: emitter.EventData = {
      data: {
        sum,
        id: 1,
        isEmpty: false
      }
    };
    // 发送eventId为1的事件，事件内容为eventData。
    try {
      emitter.emit(event, eventData);
    } catch (error) {
      hilog.error(0x0000, 'TimePickerComponent', 'emitter emit error');
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          TextPicker({ range: this.hours, selected: this.hour })
            .selectedIndex(this.hour)
            .defaultPickerItemHeight(TimerCommonConstants.itemHeight)
            .disappearTextStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .textStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .selectedTextStyle({
              color: Color.Black,
              font: { size: TimerCommonConstants.FONT_SIZE_20, weight: FontWeight.Normal }
            })
            .divider(null)
            .onChange((value: string | string[], index: number | number[]) => {
              this.hour = typeof index === 'number' ? index : index[0]
              this.changeFactory(timeType.hours, this.hour)
              if (value) {
                this.isSelectTime = true
                this.sendEvent()
              }
            })
          Text($r('app.string.Hour'))
            .margin({ top: $r('app.float.vp_13') })
        }
        .width(50)

        Row() {
          Text($r('app.string.colon'))
            .fontWeight(FontWeight.Bolder)
            .margin({ bottom: $r('app.float.vp_40') })
        }
        .justifyContent(FlexAlign.Center)
        .width(50)

        Column() {
          TextPicker({ range: this.minutes, selected: this.minute })
            .defaultPickerItemHeight(TimerCommonConstants.itemHeight)
            .disappearTextStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .textStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .selectedTextStyle({
              color: Color.Black,
              font: { size: TimerCommonConstants.FONT_SIZE_20, weight: FontWeight.Normal }
            })
            .divider(null)
            .onChange((value: string | string[], index: number | number[]) => {
              this.minute = typeof index === 'number' ? index : index[0]
              this.changeFactory(timeType.minutes, this.minute)
              if (value) {
                this.isSelectTime = true
                this.sendEvent()
              }
            })
          Text($r('app.string.Minute'))
            .margin({ top: $r('app.float.vp_13') })
        }
        .width(50)

        Row() {
          Text($r('app.string.colon'))
            .fontWeight(FontWeight.Bolder)
            .margin({ bottom: $r('app.float.vp_40') })
        }
        .justifyContent(FlexAlign.Center)
        .width(50)

        Column() {
          TextPicker({ range: this.seconds, selected: this.second })
            .defaultPickerItemHeight(TimerCommonConstants.itemHeight)
            .disappearTextStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .textStyle({
              color: $r('app.color.757E95'),
              font: { size: TimerCommonConstants.FONT_SIZE_15, weight: FontWeight.Normal }
            })
            .selectedTextStyle({
              color: Color.Black,
              font: { size: TimerCommonConstants.FONT_SIZE_20, weight: FontWeight.Normal }
            })
            .divider(null)
            .onChange((value: string | string[], index: number | number[]) => {
              this.second = typeof value === 'string' ? Number(value) : Number(value[0])
              this.changeFactory(timeType.seconds, this.second)
              if (value) {
                this.isSelectTime = true
                this.sendEvent()
              }
            })
          Text($r('app.string.Second'))
            .margin({ top: $r('app.float.vp_13') })
        }
        .width(50)

      }.height(200)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }.width('100%')
  }
}
