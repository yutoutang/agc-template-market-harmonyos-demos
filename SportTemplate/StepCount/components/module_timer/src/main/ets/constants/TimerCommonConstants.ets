export class TimerCommonConstants {
  static readonly NUMBER_1000: number = 1000
  static readonly NUMBER_360: number = 360
  static readonly CANVAS_SIZE: number = 250
  static readonly NUMBER_100: number = 100
  static readonly NUMBER_60: number = 60
  static readonly itemHeight: number = 28;
  static readonly IMAGE_WIDTH: number = 10
  static readonly NUMBER_0: number = 0
  static readonly FONT_SIZE_23: number = 23;
  static readonly FONT_SIZE_20: number = 20;
  static readonly FONT_SIZE_15: number = 15;
  static readonly CANVAS_ASPECT_RATIO: number = 1
  static readonly PERCENT_100: string = '100%'
}

export enum timeType {
  hours,
  minutes,
  seconds
}

export enum executionStatus {
  Start,
  Pause,
  over
}
