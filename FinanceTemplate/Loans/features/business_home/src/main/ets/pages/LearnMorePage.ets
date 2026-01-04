import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, WindowModel } from 'lib_common';
import { FeatureType, ShopInfoType } from 'lib_loan_api';
import { NavHeaderBar } from 'lib_widget';
import { LearnMoreVM } from '../viewmodels/LearnMoreVM';


@Builder
export function LearnMorePageBuilder() {
  LearnMorePage()
}

@ComponentV2
export struct LearnMorePage {
  @Local learnMoreVM: LearnMoreVM = new LearnMoreVM();
  @Local shopInfo: ShopInfoType | undefined = undefined;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  aboutToAppear() {
    this.shopInfo = this.learnMoreVM.getShopInfoData() as ShopInfoType
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '了解更多',
        showBackBtn: true
      })
      Scroll() {
        Column({ space: CommonConstants.SPACE_L }) {
          Image(this.shopInfo?.bannerIcon ?? '')
            .width('100%')
            .aspectRatio(2 / 1)
            .borderRadius(8)
          this.introduceDetailBuilder('', this.shopInfo?.interduceStart ?? '', false, false)
          Column({ space: 6 }) {
            if (this.shopInfo && this.shopInfo.features && this.shopInfo.features.length > 0) {
              ForEach(this.shopInfo?.features, (item: FeatureType) => {
                this.introduceDetailBuilder(item.featureTitle, item.featureDesc, true, true)
              }, (item: FeatureType) => JSON.stringify(item))
            }
          }

          this.introduceDetailBuilder('', this.shopInfo?.interduceEnd ?? '', false, true)
        }
        .padding({ left: 16, right: 16 })
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
    }
    .hideTitleBar(true)
    .height('100%')
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }

  @Builder
  introduceDetailBuilder(title: string, desc: string, isShowTitle: boolean = true, isUseIndent: boolean = true) {
    Column({ space: 10 }) {
      if (isShowTitle) {
        Row({ space: 10 }) {

          Text(title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .lineHeight(21)

        }.width('100%')
        .justifyContent(FlexAlign.Start);
      }

      Text(desc)
        .textIndent(isUseIndent ? 20 : 0)
        .width('100%')
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .lineHeight(16)
        .fontColor('rgba(0, 0, 0, 0.60)')
    }.width('100%')
  }
}