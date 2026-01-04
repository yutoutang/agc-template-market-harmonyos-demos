@ComponentV2
export struct PositionInfoCard {
  // 定义组件参数
  @Param jobTitle: string = '测试工程师'
  @Param salary: string = '15-20K'
  @Param location: string = '软件大道'
  @Param experience: string = '5年以上'
  @Param education: string = '本科'
  // 可选的图标参数，如果不传则使用默认值
  @Param addressIcon?: Resource = $r('app.media.address_icon')
  @Param degreeIcon?: Resource = $r('app.media.degree_icon')
  @Param workIcon?: Resource = $r('app.media.work_icon')
  // 可选的样式参数
  @Param titleColor?: ResourceColor = '#333333'
  @Param salaryColor?: ResourceColor = '#5B6FFF'
  @Param subtitleColor?: ResourceColor = '#999999'

  build() {
    Column() {
      // 职位标题和薪资行
      Row() {
        Text(this.jobTitle)
          .fontSize(24)
          .fontColor(this.titleColor)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Blank()

        Text(this.salary)
          .fontSize(24)
          .fontColor(this.salaryColor)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      // 职位详细信息行
      Row({ space: 16 }) {
        // 地点信息
        this.buildInfoRow(this.addressIcon, this.location)

        // 工作经验
        this.buildInfoRow(this.workIcon, this.experience)

        // 学历要求
        this.buildInfoRow(this.degreeIcon, this.education)
      }
      .width('100%')
      .margin({ top: 12 })
      .alignItems(VerticalAlign.Center)

      Column() {

      }
      .width('100%')
      .height('1px')
      .backgroundColor('#EFEFEF')
      .margin({
        top: 16
      })
    }
    .width('100%')
    .padding({
      top: 16,
      left: 16,
      right: 16
    })
    .backgroundColor('#FFFFFF')

  }

  // 封装可复用的信息行构建方法
  @Builder
  private buildInfoRow(icon: Resource | undefined, text: string) {
    Row({ space: 4 }) {
      if (icon) {
        Image(icon)
          .width(20)
          .height(20)
      }
      Text(text)
        .fontSize(14)
        .fontColor(this.subtitleColor)
        .maxLines(1)
    }
    .alignItems(VerticalAlign.Center)
  }
}