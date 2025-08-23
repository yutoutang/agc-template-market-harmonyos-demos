import { dateLabelMap } from './Constants'

@ObservedV2
export class HotelDateModel {
  @Trace roomCount: number = 1
  @Trace checkInDate: Date
  @Trace checkOutDate: Date
  @Trace today: Date = new Date()
  @Trace maxRoomCount: number = 99
  @Trace minRoomCount: number = 1
  private static _instance: HotelDateModel | undefined = undefined

  @Computed
  public get totalDays() {
    let timeDiff: number = this.checkOutDate.getTime() - this.checkInDate.getTime();
    return Math.floor(timeDiff / (24 * 60 * 60 * 1000));
  }

  @Computed
  public get startDate() {
    return this.today;
  }

  constructor() {
    this.checkInDate = new Date();
    this.checkOutDate = new Date();
    this.checkOutDate.setDate(this.checkInDate.getDate() + 1);
  }

  static get instance() {
    if (!HotelDateModel._instance) {
      HotelDateModel._instance = new HotelDateModel()
    }
    return HotelDateModel._instance
  }

  public resetRoomCount() {
    this.roomCount = 1
  }

  public getDateLabel(date: Date) {
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  public getDateDescription(date: Date) {
    const today = new Date(this.today);
    today.setHours(0, 0, 0, 0);
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() + 1);
    const compareDate = new Date(date);
    compareDate.setHours(0, 0, 0, 0);

    if (compareDate.getTime() === today.getTime()) {
      return '今天';
    } else if (compareDate.getTime() === yesterday.getTime()) {
      return '明天';
    }
    const label = dateLabelMap.get(date.getDay());
    return label ?? '';
  }
}
