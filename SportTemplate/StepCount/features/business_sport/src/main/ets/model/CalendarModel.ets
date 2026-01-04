import { SportRecord } from 'lib_sport_api';
import { DailyRecordVM, WeekDateModel } from 'module_daily';
import { DialogType, SwiperDirection, TypePicker } from '../constant/CalendarConstant';
import { DateUtils } from '../util/DateUtils';

/**
 * 单日模型
 */
@ObservedV2
export class DayModel {
  @Trace year: number;
  @Trace month: number;
  @Trace day: number;
  @Trace lunarMonth: string = '';
  @Trace lunarDay: string = '';
  @Trace isFirstOfLunar: boolean = false;
  @Trace holiday: string = '';
  @Trace dayMark: string = '';
  @Trace isCurrMonth: boolean = true;
  @Trace isToday: boolean = false;
  @Trace selected: boolean = false;
  @Trace sportRecord?: SportRecord;
  attendanceRecordVM: DailyRecordVM = new DailyRecordVM()

  constructor(year: number, month: number, day: number, isCurrMonth: boolean, isToday: boolean = false) {
    this.year = year;
    this.month = month;
    this.day = day;
    this.isCurrMonth = isCurrMonth;
    this.isToday = isToday;
    this.selected = false;
  }

  setSportRecord(sportRecord: SportRecord) {
    this.sportRecord = sportRecord
  }

  /**
   * 设置是否选中
   * @param selected
   */
  setSelected(selected: boolean) {
    this.selected = selected;
  }

  /**
   * 返回年月，格式：1994-01
   * @returns
   */
  getYearMonth(): string {
    return `${this.year}-${DateUtils.padZero(this.month)}`;
  }

  /**
   * 返回具体日期，年月日，格式：1994-01-01
   * @returns
   */
  getDateString(): string {
    return `${this.year}-${DateUtils.padZero(this.month)}-${DateUtils.padZero(this.day)}`;
  }

  /**
   * 获取日期时间戳格式
   * @returns
   */
  getTimestamp(): number {
    const date = new Date(this.getDateString());
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  }

  // 通过日期获取三环运动数据
  getSportData(): WeekDateModel {
    return this.attendanceRecordVM.queryDateRunningData(new Date(this.getTimestamp()));
  }
}

/**
 * 单月模型
 */
@ObservedV2
export class MonthModel {
  // xxxx格式
  @Trace year: number;
  // 范围1-12
  @Trace month: number;
  @Trace data: DayModel[];

  constructor(year: number, month: number, data: DayModel[]) {
    this.year = year;
    this.month = month;
    this.data = data;
  }

  getYearMonthString() {
    return this.year + '_' + this.month;
  }
}

interface FontSizeConfig {
  year: Length;
  week: Length;
  day: Length;
  btn: Length;
  tip: Length;
}

interface MarginConfig {
  outerLeft: Length;
  outerTop: Length;
  yearToArrow: Length;
  arrowToArrow: Length;
  yearToWeek: Length;
  weekToDay: Length;
  dayToDay: number;
  dayLeft: number;
  dayTop: number;
}

export interface CalendarUIConfig {
  fontSize: FontSizeConfig;
  margin: MarginConfig;
}

class BaseMonthDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: MonthModel[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): MonthModel {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}

export class MonthDataSource extends BaseMonthDataSource {
  private dataArray: MonthModel[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getAllData(): MonthModel[] {
    return this.dataArray
  }

  public getData(index: number): MonthModel {
    return this.dataArray[index];
  }

  public getDataIndex(month: MonthModel): number {
    return this.dataArray.findIndex((v) => {
      return v.year === month.year && v.month === month.month;
    });
  }

  // 获取数组中第一个数据
  public getFirstData(): MonthModel {
    return this.dataArray[0];
  }

  // 获取数组中最后一个数据
  public getFinalData(): MonthModel {
    return this.dataArray[this.dataArray.length - 1];
  }

  // 在数组末尾，批量插入数据
  public batchPushData(data: MonthModel[]): void {
    const index = this.dataArray.length;
    this.dataArray.splice(index, 0, ...data);
    this.notifyDataAdd(index, data.length);
  }

  // 在数据头部，批量插入数据
  public batchPushDataHead(data: MonthModel[]): void {
    this.dataArray.splice(0, 0, ...data);
    this.notifyDataAdd(0, data.length);
  }

  // 在数组末尾，插入数据
  public pushData(data: MonthModel): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1, 1);
  }

  // 在数据头部，插入数据
  public pushDataHead(data: MonthModel): void {
    this.dataArray.splice(0, 0, data);
    this.notifyDataAdd(0, 1);
  }
}

/**
 * 开发者传参模型
 */
export interface UICalendarOptions {
  type: TypePicker;
  dialogType: DialogType;
  swiperDirection: SwiperDirection;
  customColor: ResourceColor;
  customFontColor: ResourceColor;
  startDayOfWeek: number;
  startYear: number;
  endYear: number;
  selected: Date | null;
  selectDates: Date[];
  yOffset: number;
  rangeLimit: Date[];
  disabledDates: Date[];
  disableDayLabel: ResourceStr;
  maxGap: number;
  enableSelectTime: boolean;
  isMilitaryTime: boolean;
  sheetTitle: ResourceStr;
  onSelected: (date: Date | Date[]) => void;
  onClickDate: (date: Date) => void;
  cancel: () => void;
  close: () => void;
}
