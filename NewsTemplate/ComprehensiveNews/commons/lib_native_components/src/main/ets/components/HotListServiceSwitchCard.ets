import { UIUtils } from '@kit.ArkUI'
import { ButtonGroup, IButtonItem } from 'lib_widget'
import { LayoutParams } from 'lib_news_api'

@Builder
export function HotListServiceSwitchCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
export struct NativeComponent {
  @Param @Require cardData: LayoutParams
  @Local selectedId: string = '2'

  aboutToAppear(): void {
    this.cardData.nativeCardData = UIUtils.makeObserved(this.cardData.nativeCardData)
  }

  build() {
    Column() {
      ButtonGroup({
        buttonList: this.cardData.extraInfo.hotList as IButtonItem[],
        selectedId: this.selectedId!!,
      })
    }
  }
}