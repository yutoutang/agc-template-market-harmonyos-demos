import { DateLineChart } from '../components/linechart/DateLineChart'
import { DateType } from '../constant/DateConstant'
import { YAxisValueFormatter } from '../model/LineChartOptions'
import { common } from '@kit.AbilityKit'
import { LineChartDataModel } from '../model/LineChartDataModel'

@ComponentV2
export struct WeekMonthChartCard {
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Param @Require title: ResourceStr
  @Param @Require desc: ResourceStr
  @Param @Require descInfo: ResourceStr
  @Param @Require lastData: LineChartDataModel
  @Param @Require curData: LineChartDataModel
  @Param @Require curDateStr: ResourceStr
  @Param @Require lastDateStr: ResourceStr
  @Param yAxisMaximum: number | undefined = undefined
  @Param @Require dateType: DateType
  @Param @Require type: number = 0

  private getXAxisLineColor(): number {
    return this.context.resourceManager.getColorSync($r('app.color.color_D9E1E7'));
  }

  private getXAxisTextColor(): number {
    return this.context.resourceManager.getColorSync($r('app.color.color_809FB8'));
  }

  private getYAxisLineColor(): number {
    return this.context.resourceManager.getColorSync($r('app.color.color_D9E1E7'));
  }

  private getYAxisTextColor(): number {
    return this.context.resourceManager.getColorSync($r('app.color.color_809FB8'));
  }

  private getYAxisValueFormatter(): YAxisValueFormatter | undefined {
    if (this.type === 1) {
      return {
        getFormattedValue: (value: number): string => {
          // 将秒转换为分钟，取整数
          const minutes = Math.round(value / 60);
          return minutes.toString();
        }
      } as YAxisValueFormatter;
    }
    return undefined;
  }

  getYAxisMaxValue(labelCount: number, models: LineChartDataModel[]) {
    const max = this.getYAxisMaxValueByModels(labelCount, models) ?? 0
    if (this.type === 0 && max <= 10) {
      return 30
    } else if (this.type === 1 && (max <= 10 || max === 0)) {
      // 时长：如果为0或小于等于10，返回1800（显示0、10、20、30分钟）
      // 注意：max是秒数，需要返回1800秒（30分钟），这样格式化后显示为0、10、20、30分钟
      return 1800
    } else if (this.type === 2 && max <= 10) {
      return 30
    }
    return max
  }

  getYAxisMaxValueByModels(labelCount: number, models: LineChartDataModel[]): number | undefined {
    const labels = this.getCustomLabels(labelCount, models)
    return labels[labels.length - 1]
  }

  getCustomLabels(labelCount: number, models: LineChartDataModel[]): number[] {
    let max = 0
    for (let model of models) {
      for (let data of model.dataModel) {
        if (data.data > max) {
          max = data.data
        }
      }
    }
    return [max]
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize($r('app.float.fp_16'))
        .fontColor($r('app.color.color_black'))
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Start)

      Column() {
        Text(this.desc)
          .fontSize($r('app.float.fp_22'))
          .fontColor($r('app.color.color_black'))
          .fontWeight(500)
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(this.descInfo)
          .fontSize($r('app.float.fp_14'))
          .fontColor($r('app.color.color_80000000'))
          .margin({ top: $r('app.float.vp_5') })

        Row() {
          Text(this.curDateStr)
            .fontSize($r('app.float.fp_14'))
            .fontColor($r('app.color.color_80000000'))

          Stack() {
            Line()
              .width($r('app.float.vp_22'))
              .height($r('app.float.vp_2'))
              .backgroundColor(this.curData.dataOptions?.lineColor ?? $r('app.color.color_FFA700'))

            Circle()
              .fill(this.curData.dataOptions?.lineColor ?? $r('app.color.color_FFA700'))
              .width($r('app.float.vp_6'))
              .height($r('app.float.vp_6'))
          }.margin({ left: $r('app.float.vp_6') })

          Text(this.lastDateStr)
            .fontSize($r('app.float.fp_14'))
            .fontColor($r('app.color.color_80000000'))
            .margin({ left: $r('app.float.vp_50') })

          Stack() {
            Line()
              .width($r('app.float.vp_22'))
              .height($r('app.float.vp_2'))
              .backgroundColor(this.lastData.dataOptions?.lineColor ?? $r('app.color.color_C2D0DC'))

            Circle()
              .fill(this.lastData.dataOptions?.lineColor ?? $r('app.color.color_C2D0DC'))
              .width($r('app.float.vp_6'))
              .height($r('app.float.vp_6'))
          }.margin({ left: $r('app.float.vp_6') })
        }.margin({ top: $r('app.float.vp_20') })

        DateLineChart({
          dateType: this.dateType,
          data: [this.lastData, this.curData],
          options: {
            xAxisLineColor: this.getXAxisLineColor(),
            xAxisTextColor: this.getXAxisTextColor(),
            xAxisTextSize: 10,
            xAxisLineWidth: 0.6,
            yAxisLineColor: this.getYAxisLineColor(),
            yAxisTextColor: this.getYAxisTextColor(),
            yAxisTextSize: 10,
            yAxisLineWidth: 0.6,
            yAxisLabelCount: 3,
            yAxisMaximum: this.getYAxisMaxValue(3, [this.lastData, this.curData]),
            // 如果是时长类型（type === 1），将秒转换为分钟显示
            yAxisValueFormatter: this.getYAxisValueFormatter()
          }
        }).width('100%')
          .height(120)
          .margin({ top: $r('app.float.vp_50') })
      }
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: $r('app.float.vp_14'),
        right: $r('app.float.vp_14'),
        top: $r('app.float.vp_18'),
        bottom: $r('app.float.vp_18')
      })
      .borderRadius($r('app.float.fp_12'))
      .margin({ top: $r('app.float.vp_10') })
    }
  }
}


