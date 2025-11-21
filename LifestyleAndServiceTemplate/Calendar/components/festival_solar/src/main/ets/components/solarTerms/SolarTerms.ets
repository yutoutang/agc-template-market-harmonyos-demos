import { BaseTextStyleModifier } from 'base_apis'
import dayjs from 'dayjs'
import { SolarInfo } from '../../model/model'
import { getSolarInfo } from '../../utils/Utils'

@ComponentV2
export struct SolarTerms {
  /**
   * 传入的日期
   */
  @Param selectedDate: Date = new Date()
  /**
   * 节气信息
   */
  @Local solarInfo: SolarInfo[] = []

  /**
   * 节气卡片事件
   */
  @Event onSolarCardClick: (solarInfo: SolarInfo) => void = () => {}

  aboutToAppear(): void {
    this.solarInfo = getSolarInfo(this.selectedDate)
  }

  build() {
    Grid() {
      ForEach(this.solarInfo, (item: SolarInfo) => {
        GridItem() {
          Column({ space: 8 }) {
            Text(item.solarTerm)
              .attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
            Text(item.solarDate)
              .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_S/Regular'))
          }
          .onClick(() => {
            this.onSolarCardClick(item)
          })
          .backgroundColor(item.solarDate === dayjs(this.selectedDate).format('YYYY年M月D日') ?
          $r('sys.color.comp_background_tertiary') : $r('sys.color.background_primary'))
          .padding(12)
          .borderRadius(8)
        }
      }, (item: SolarInfo) => JSON.stringify(item))
    }
    .columnsTemplate('1fr 1fr 1fr')
  }
}
