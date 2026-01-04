import { GrayText } from './GrayText'

/**
 * 经历卡片组件
 * 用于展示工作经历和项目经验的统一卡片样式
 */
@ComponentV2
export struct ExperienceCard {
  /** 标题（公司名/项目名） */
  @Param title: string = ''
  /** 副标题（职位/角色） */
  @Param subtitle: string = ''
  /** 描述内容 */
  @Param description: string = ''
  /** 开始日期 */
  @Param startDate: string = ''
  /** 结束日期 */
  @Param endDate: string = ''
  /** 标题字号，默认14 */
  @Param titleFontSize: number = 14
  /** 标题行高，默认16 */
  @Param titleLineHeight: number = 16
  /** 标题字重，默认700 */
  @Param titleFontWeight: number = 700
  /** 标题颜色，默认#E5000000 */
  @Param titleColor: ResourceColor = '#E5000000'
  /** 点击事件 */
  @Event onEditClick?: () => void
  @Param isEdit: boolean = true

  build() {
    Column() {
      // 标题行
      Row() {
        Text(this.title)
          .fontSize(this.titleFontSize)
          .lineHeight(this.titleLineHeight)
          .fontWeight(this.titleFontWeight)
          .fontColor(this.titleColor)
          .wordBreak(WordBreak.BREAK_ALL)
          .layoutWeight(1)
        Blank()
        Row() {
          GrayText({ text: (this.startDate || '') + '-' + (this.endDate || '至今') })
            .margin({ right: 4 })
          if (this.isEdit) {
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize('24vp')
              .fontColor([$r('sys.color.font_fourth')])
              .offset({
                bottom: 5
              })

          }
        }

        .alignItems(VerticalAlign.Top)
        .justifyContent(FlexAlign.End)
        .margin({
          left: 6
        })
        .onClick(() => {
          if (this.onEditClick) {
            this.onEditClick()
          }
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)
      .width('100%')

      // 副标题
      if (this.subtitle) {
        Row() {
          GrayText({ text: this.subtitle, fontSize: 14 })
        }
        .width('100%')
        .margin({ top: 4 })
      }

      // 描述
      if (this.description) {
        GrayText({
          text: this.description,
          lineHeight: 18,
          maxLines: 2,
          textOverflow: TextOverflow.Ellipsis,
          fontSize: 14
        })
          .width('100%')
          .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }
}
