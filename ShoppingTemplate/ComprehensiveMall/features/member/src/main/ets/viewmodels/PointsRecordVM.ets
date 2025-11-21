import { UserApis, UserPointsRecordItem } from 'lib_network'
import { UserPointsUsedType } from '../commons/Enums'

@ObservedV2
export class PointsRecordVM {
  @Trace
  month: string = ''
  @Trace
  totalPoints: number = 0
  @Trace
  recordList: UserPointsRecordItem[] = []
  @Trace
  selectedType: UserPointsUsedType = UserPointsUsedType.INCOME
  @Trace
  showMonthPicker: boolean = false

  public async getPointRecord(type: UserPointsUsedType = UserPointsUsedType.INCOME) {
    this.selectedType = type;
    const date = new Date()
    const month = `${date.getFullYear()}-${date.getMonth() + 1}`
    const res = await UserApis.getUserPointsRecord(month)
    if (res.code === 0) {
      this.month = month;
      this.totalPoints = res.totalPoints;
      this.recordList = res.list.filter((record) => record.type === this.selectedType);
    }
  }

  public async handleMonthChange(month:string){
    this.month = month;
    const res = await UserApis.getUserPointsRecord(month)
    if (res.code === 0) {
      this.totalPoints = res.totalPoints;
      this.recordList = res.list.filter((record) => record.type === this.selectedType);
    }
    this.showMonthPicker = false;
  }
}