/**
 * 简历页面分隔线组件
 * 统一样式的分隔线，用于各个模块之间的分隔
 */

@ComponentV2
export struct ResumeDivider {
  /** 上边距，默认20 */
  @Param marginTop: number = 20
  /** 下边距，默认20 */
  @Param marginBottom: number = 20

  build() {
    Row()
      .height(1)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .margin({ top: this.marginTop, bottom: this.marginBottom })
  }
}
