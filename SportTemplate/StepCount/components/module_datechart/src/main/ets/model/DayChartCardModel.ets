import { DateType } from '../constant/DateConstant'
import { LineChartDataModel } from './LineChartDataModel'

@ObservedV2
export class DayChartCardModel {
  // day
  @Trace target: number = 0
  @Trace process: number = 0
  @Trace charData: LineChartDataModel[] = []
  @Trace isShowArrow: boolean = true

}