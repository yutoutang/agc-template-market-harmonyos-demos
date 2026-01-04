/**
 * 简历页面分隔线组件
 * 统一样式的分隔线，用于各个模块之间的分隔
 */
@ComponentV2
export struct ResumeDivider {
  /** 上边距，默认10 */
  @Param marginTop: number = 16
  /** 下边距，默认10 */
  @Param marginBottom: number = 16

  build() {
    Row()
      .height(1)
      .backgroundColor('#EFEFEF')
      .width('100%')
      .margin({ top: this.marginTop, bottom: this.marginBottom })
  }
}
