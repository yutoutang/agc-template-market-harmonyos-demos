import { DateLineChart } from '../components/linechart/DateLineChart'
import { DateType } from '../constant/DateConstant'
import { YAxisValueFormatter } from '../model/LineChartOptions'
import { common } from '@kit.AbilityKit'
import { LineChartDataModel } from '../model/LineChartDataModel'

@ComponentV2
export struct DayChartCard {
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  @Param @Require type: number = 0
  @Param @Require target: number
  @Param @Require process: number
  @Param @Require unit: Resource
  @Param @Require charData: LineChartDataModel[]
  // 卡片标识
  @Param @Require label?: ResourceStr
  // 是否显示跳转箭头
  @Param isShowArrow: boolean = true

  /**
   * 获取指定资源对应的颜色值（十进制）
   * @param resId 资源ID值/资源信息
   * @returns
   */
  private getColorSync(resId: number | Resource): number {
    if (typeof resId === 'number') {
      return this.context.resourceManager.getColorSync(resId);
    } else {
      return this.context.resourceManager.getColorSync(resId);
    }
  }

  /**
   * 获取指定资源对应的字符串
   * @param resId 资源ID值
   * @param args 格式化字符串资源参数。
   *   支持参数类型：%d、%f、%s、%%、%数字\$d、%数字\$f、%数字\$s；
   *   说明：%%转义为%; %数字\$d表示使用第几个参数；
   *   举例：%%d格式化后为%d字符串; %1\$d表示使用第一个参数
   */
  private getStringSync(resId: number | Resource, args?: (string | number)[]): string {
    if (args !== undefined && args.length > 0) {
      if (typeof resId === 'number') {
        return this.context.resourceManager.getStringSync(resId, ...args);
      } else {
        return this.context.resourceManager.getStringSync(resId, ...args);
      }
    } else {
      if (typeof resId === 'number') {
        return this.context.resourceManager.getStringSync(resId);
      } else {
        return this.context.resourceManager.getStringSync(resId);
      }
    }
  }

  getYAxisMaxValue(labelCount: number): number {
    const max = this.getYAxisMaxValueByData(labelCount, this.charData) ?? 0
    if (this.type === 0 && max <= 10) {
      return 30
    } else if (this.type === 1 && (max === 0 || max <= 10)) {
      // 时长：如果为0或小于等于10，返回1800（显示0、10、20、30分钟）
      // 注意：max是秒数，需要返回1800秒（30分钟），这样格式化后显示为0、10、20、30分钟
      return 1800
    } else if (this.type === 2 && max <= 10) {
      return 30
    } else if (this.type === 3 && (max === 0 || max <= 10)) {
      // 距离：如果为0或小于等于10，返回30000（显示0、10、20、30公里）
      // 注意：max是米数，需要返回30000米（30公里），这样格式化后显示为0、10、20、30公里
      return 30000
    }
    return max
  }

  getYAxisMaxValueByData(labelCount: number, models: LineChartDataModel[]): number | undefined {
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

  getMaxValue(): number {
    // 检查所有数据是否都为0
    let max = 0
    for (let model of this.charData) {
      for (let data of model.dataModel) {
        if (data.data > max) {
          max = data.data
        }
      }
    }
    return max
  }

  /**
   * 获取自定义Y轴标签
   * @returns 自定义标签数组或undefined
   */
  private getCustomYAxisLabels(): number[] | undefined {
    if (this.type === 1 && this.getMaxValue() === 0) {
      // 时长类型：返回0、10、20、30分钟（对应0、600、1200、1800秒）
      return [0, 600, 1200, 1800];
    } else if (this.type === 3 && this.getMaxValue() === 0) {
      // 距离类型：返回0、10、20、30公里（对应0、10000、20000、30000米）
      return [0, 10000, 20000, 30000];
    }
    return undefined;
  }

  /**
   * 判断是否启用自定义Y轴标签
   * @returns 是否启用自定义Y轴标签
   */
  private isEnableCustomYAxisLabels(): boolean {
    return (this.type === 1 && this.getMaxValue() === 0) ||
      (this.type === 3 && this.getMaxValue() === 0);
  }

  /**
   * 获取Y轴数值格式化器
   * @returns Y轴数值格式化器或undefined
   */
  private getYAxisValueFormatter(): YAxisValueFormatter | undefined {
    if (this.type === 1) {
      // 时长类型：将秒转换为分钟显示
      return {
        getFormattedValue: (value: number): string => {
          // 将秒转换为分钟，取整数
          const minutes = Math.round(value / 60);
          return minutes.toString();
        }
      } as YAxisValueFormatter;
    } else if (this.type === 3) {
      // 距离类型：将米转换为公里并保留一位小数
      return {
        getFormattedValue: (value: number): string => {
          // 将米转换为公里，如果是整数不保留小数，否则保留一位小数
          const kilometers = Math.round(value / 1000 * 10) / 10;
          if (kilometers % 1 === 0) {
            return kilometers.toFixed(0);
          } else {
            return kilometers.toFixed(1);
          }
        }
      } as YAxisValueFormatter;
    }
    return undefined;
  }

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.label)
          .fontColor(Color.Black)
          .fontSize($r('app.float.fp_16'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: $r('app.float.vp_4') })
      }.width('100%')

      Stack({ alignContent: Alignment.Top }) {
        DateLineChart({
          dateType: DateType.DAY,
          data: this.charData,
          options: {
            xAxisLineColor: this.getColorSync($r('app.color.color_D9E1E7')),
            xAxisTextColor: this.getColorSync($r('app.color.color_809FB8')),
            xAxisTextSize: 10,
            xAxisLineWidth: 0.6,
            yAxisLineColor: this.getColorSync($r('app.color.color_D9E1E7')),
            yAxisTextColor: this.getColorSync($r('app.color.color_809FB8')),
            yAxisTextSize: 10,
            yAxisLineWidth: 0.6,
            yAxisLabelCount: 3,
            yAxisMaximum: this.getYAxisMaxValue(3),
            customYAxisLabels: this.getCustomYAxisLabels(),
            enableCustomYAxisLabels: this.isEnableCustomYAxisLabels(),
            yAxisValueFormatter: this.getYAxisValueFormatter()
          }
        }).width('100%')
          .height(120)
          .margin({ top: $r('app.float.vp_50') })

        Row() {
          Text() {
            Span((Math.floor(this.process * 10) / 10).toFixed(1).replace(/\.0$/, '').toString())
              .fontColor($r('app.color.color_333333'))
              .fontSize($r('app.float.fp_28'))
            Span('/' + this.target + this.getStringSync(this.unit))
              .fontColor($r('app.color.color_999999'))
              .fontSize($r('app.float.fp_16'))
          }.margin({ top: $r('app.float.vp_4') })

          Blank()
          if (this.isShowArrow) {
            Image($r('app.media.ic_arrow_right'))
              .width($r('app.float.vp_12'))
              .margin({ right: $r('app.float.vp_4') })
          }
        }.width('100%')

      }.backgroundColor(Color.White)
      .borderRadius($r('app.float.vp_12'))
      .padding($r('app.float.vp_16'))
    }
  }
}


