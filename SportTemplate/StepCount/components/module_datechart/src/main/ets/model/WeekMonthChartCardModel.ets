import { DateType } from '../constant/DateConstant'
import { LineChartDataModel } from './LineChartDataModel'

@ObservedV2
export class WeekMonthChartCardModel {
  // week month
  @Trace dateType: DateType = DateType.WEEK
  @Trace desc: ResourceStr = ''
  @Trace descInfo: ResourceStr = ''
  @Trace curData?: LineChartDataModel
  @Trace lastData?: LineChartDataModel
  @Trace curDateStr: ResourceStr = ''
  @Trace lastDateStr: ResourceStr = ''

}