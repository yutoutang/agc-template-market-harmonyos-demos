import { GrayText } from './GrayText'

/**
 * 教育背景卡片组件
 */
@ComponentV2
export struct EducationCard {
  /** 学校名称 */
  @Param school: string = ''
  /** 学历 */
  @Param degree: string = ''
  /** 专业 */
  @Param major: string = ''
  /** 开始日期 */
  @Param startDate: string = ''
  /** 结束日期 */
  @Param endDate: string = ''
  /** 点击事件 */
  @Event onEditClick?: () => void
  @Param isEdit: boolean = true

  build() {
    Row() {
      Row() {
        Stack() {
          Row()
            .width(40)
            .height(40)
            .backgroundColor('#FFD8D8D8')
            .borderRadius(8)
          Text('logo')
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(14)
            .fontColor('#99000000')
        }
        .margin({ right: 12 })

        Column() {
          Text(this.school)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          GrayText({ text: this.degree + '·' + this.major, fontSize: 14 })
            .margin({
              top: 6
            })
        }
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        GrayText({ text: this.startDate + '-' + (this.endDate || '至今') })
        if (this.isEdit) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontSize('24vp')
            .fontColor([$r('sys.color.font_fourth')])
            .margin({ left: 8 })
        }

      }
      .onClick(() => {
        if (this.onEditClick) {
          this.onEditClick()
        }
      })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .borderRadius(8)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
