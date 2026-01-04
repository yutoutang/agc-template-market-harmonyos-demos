import { CharDataModel } from './ChartDataModel'
import { LineChartDataOptions } from './LineChartDataOptions'

export class LineChartDataModel {
  dataModel: CharDataModel[]
  dataOptions?: LineChartDataOptions

  constructor(dataModel: CharDataModel[], dataOptions?: LineChartDataOptions) {
    this.dataModel = dataModel
    this.dataOptions = dataOptions
  }
}