import { CompanyInfo } from '../model/PositionModel'

@ComponentV2
export struct CompanyCard {
  @Param @Require companyInfoData: CompanyInfo

  build() {
    Row() {
      // Logo
      Row() {
        Text('logo')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width(64)
      .height(64)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      // 公司信息
      Column() {
        Text(this.companyInfoData.companyName)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${this.companyInfoData.companySize}·${this.companyInfoData.industry}`)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      // 箭头
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(24)
        .height(24)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
