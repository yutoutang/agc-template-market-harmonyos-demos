@ObservedV2
export class WeekModel {
  @Trace weekDateModel: WeekDateModel[] = []

  constructor(weekDateModel: WeekDateModel[]) {
    this.weekDateModel = weekDateModel;
  }
}

@ObservedV2
export class WeekDateModel {
  @Trace selected: boolean = false; // 是否选中
  date: Date = new Date();
  week: string = ''; // 周几
  day: string = ''; // 日
  @Trace stepData: number[] = [0, 1000];
  @Trace distanceData: number[] = [0, 1000];
  @Trace caloriesData: number[] = [0, 1000];
}