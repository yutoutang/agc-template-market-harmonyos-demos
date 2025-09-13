import { PersistenceV2 } from '@kit.ArkUI'
import { CommonConstants, RouterMap, RouterUtils, SettingModel, TimeUtils } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'

@ComponentV2
export struct AuthorCard {
  @Param @Require cardData: LayoutParams
  @Param isNeedAuthor: boolean = false
  @BuilderParam watchBuilder: () => void
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: CommonConstants.SPACE_S }) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.cardData.nativeCardData.author.authorIcon || $r('app.media.icon_default'))
            .alt($r('app.media.icon_default'))
            .width(40)
            .height(40)
            .borderRadius('50%')
            .clip(true)
            .accessibilityText(this.cardData.nativeCardData.author.authorNickName + '头像')
            .onClick(() => {
              RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.cardData.nativeCardData.author.authorId)
            })
        }

        Column({ space: CommonConstants.SPACE_S }) {
          Text(this.cardData.nativeCardData.author.authorNickName)
            .fontSize(16 * this.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
          Text(TimeUtils.formatDate(this.cardData.nativeCardData?.createTime, 'YYYY-MM-DD HH:mm'))
            .fontSize(12 * this.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }.alignItems(HorizontalAlign.Start)
      }

      if (this.watchBuilder) {
        this.watchBuilder()
      }
    }
    .visibility(this.isNeedAuthor ? Visibility.Visible : Visibility.None)
  }
}
