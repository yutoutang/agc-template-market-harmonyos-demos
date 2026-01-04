export class HomeCommonConstants {
  // eslint-disable-next-line @typescript-eslint/naming-convention
  static readonly PADDING_S: number = 8;
  static readonly NUMBER_10: number = 10
  static readonly NUMBER_5: number = 5
  static readonly NUMBER_0: number = 0
  static readonly NUMBER_50000: number = 50000
  static readonly NUMBER_5000: number = 5000
  static readonly NUMBER_1000: number = 1000
  static readonly NUMBER_16: number = 16
  static readonly NUMBER_14: number = 14
  static readonly NUMBER_12: number = 12
  static readonly NUMBER_600: number = 600
  static readonly NUMBER_65: number = 65
  static readonly NUMBER_40: number = 40
  static readonly NUMBER_20: number = 20
  static readonly NUMBER_100: number = 100
  static readonly NUMBER_0x1: number = 0.1
  static readonly PERCENT_75: string = '75%';
  static readonly PERCENT_40: string = '40%';
  static readonly PERCENT_5: string = '5%';
  static readonly PERCENT_100: string = '100%'
  static readonly PERCENT_90: string = '90%';
  static readonly PERCENT_80: string = '80%';
  static readonly defaultHeat: string = '50千卡';
  static readonly defaultDuration: string = '10分钟';
  static readonly defaultPace: string = '3′00′′/公里';
  static readonly defaultDistance: string = '1公里';
  static readonly defaultSteps: string = '1000步';
  static readonly custom: string = '自定义';
  static readonly paceHint: string = '时分使用空格隔开,5′30″例:5 30';
  static readonly FULL_PERCENT: string = '100%';
}

export enum TargetType {
  Distance = '距离',
  Heat = '热量',
  Steps = '步数',
  Duration = '时长',
  Pace = '配速'
}
