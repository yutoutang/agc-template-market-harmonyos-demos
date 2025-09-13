import { PersistenceV2, UIUtils } from '@kit.ArkUI'
import { CommonConstants, SettingModel } from 'lib_common'
import { LayoutParams } from 'module_flexlayout'
import { CardViewModel } from '../viewmodel/CardViewModel'

@Builder
export function HotNewsServiceCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
export struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local currentIndex: number = 0
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local cardViewModel: CardViewModel = new CardViewModel(this.getUIContext())

  aboutToAppear(): void {
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
    this.currentIndex = this.cardData.currentIndex
  }

  build() {
    Column() {
      Row() {
        Text((this.currentIndex + 1).toString() + '.')
          .fontColor(this.currentIndex <= 2 ? $r('sys.color.warning') : $r('sys.color.font_primary'))
          .fontSize(14 * this.settingInfo.fontSizeRatio)
        Text(this.cardData.nativeCardData?.title)
          .margin({ left: 12 })
          .maxLines(1)
          .fontSize(14 * this.settingInfo.fontSizeRatio)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('sys.color.font_primary'))
      }
      .justifyContent(FlexAlign.Start)
      .padding({ right: CommonConstants.PADDING_L })
      .width(CommonConstants.FULL_PERCENT)
      .onClick(() => {
        this.cardViewModel.pushToNewsDetails(this.cardData)
      })
    }
  }
}