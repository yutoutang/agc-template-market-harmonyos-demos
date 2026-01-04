import { PositionInfo } from '../model/PositionModel'

@ComponentV2
export struct PositionCard {
  @Param @Require positionInfoData: PositionInfo
  @Param isHideHR?: boolean = false

  build() {
    Column() {
      // 职位标题和薪资
      Row() {
        Text(this.positionInfoData.jobTitle)
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)

        Blank()

        Text(this.positionInfoData.salary)
          .fontSize(18)
          .fontColor('#5B6FFF')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')

      // 公司名称
      Text(this.positionInfoData.companyName)
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 8 })
        .width('100%')

      // 标签
      Row() {
        Text(this.positionInfoData.experience)
          .fontSize(12)
          .fontColor('#999999')
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4
          })
          .backgroundColor('#F5F5F5')
          .borderRadius(4)

        Text(this.positionInfoData.education)
          .fontSize(12)
          .fontColor('#999999')
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4
          })
          .backgroundColor('#F5F5F5')
          .borderRadius(4)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ top: 8 })

      if (!this.isHideHR) {
        // HR信息
        Row() {
          Image($r('app.media.hr_avatar'))
            .width(32)
            .height(32)
            .borderRadius(16)

          Column() {
            Text(`${this.positionInfoData.hrName}·${this.positionInfoData.hrTitle}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ left: 8 })
          .alignItems(HorizontalAlign.Start)

          Blank()

          Text(this.positionInfoData.location)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}