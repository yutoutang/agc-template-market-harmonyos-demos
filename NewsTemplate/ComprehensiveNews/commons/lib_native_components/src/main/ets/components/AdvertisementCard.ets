
import { AdvertisementComponent } from 'module_advertisement'
import { LayoutParams } from 'module_flexlayout'

@Builder
export function AdvertisementCard(cardData: LayoutParams) {
  NativeComponent({
    cardData: cardData,
  })
}

@ComponentV2
export struct NativeComponent {
  @Param @Require cardData: LayoutParams
  build() {
    AdvertisementComponent({
      testAd: 'testw6vs28auh3',
      adType: 8,
    })
  }
}