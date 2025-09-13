import { PersistenceV2 } from '@kit.ArkUI'
import { SettingModel, TimeUtils } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'

@ComponentV2
export struct ArticleSourceBuilder {
  @Param @Require cardData: LayoutParams
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!

  build() {
    Row() {
      Text(this.cardData.nativeCardData?.articleFrom)
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Start)
      Text(TimeUtils.formatDate(this.cardData.nativeCardData?.createTime, 'YYYY-MM-DD HH:mm'))
        .fontSize(12 * this.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Start)
        .margin({ left: 8 })
    }
    .visibility(this.cardData.extraInfo.isNeedAuthor ? Visibility.None : Visibility.Visible)
  }
}
