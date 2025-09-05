import { common } from '@kit.AbilityKit';
import { CircleButtonModifier, CommonConstants, LinearColumnModifier, NewsScan } from 'lib_common'
import { FlexLayout } from 'lib_flex_layout';
import { NewsSearchTransition } from 'lib_widget';
import { NavHeaderBar } from 'lib_widget';
import { FloatingPublishBtn } from '../components/FloatingPublishBtn';
import { HomeViewModel } from '../viewmodels/HomeViewModel';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  @Local homeViewModel: HomeViewModel = new HomeViewModel();
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  aboutToAppear(): void {
    this.homeViewModel.sendPushNotice(getContext(this) as common.UIAbilityContext)
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '首页',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          },
        })
        Column() {
          FlexLayout()
        }
        .layoutWeight(1)

        this.publishNewsBtn()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_primary'))
      .attributeModifier(this.modifier)
      .padding({
        bottom: this.homeViewModel.pagePaddingBottom,
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  publishNewsBtn() {
    FloatingPublishBtn()
  }

  @Builder
  rightHeadPartBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      NewsSearchTransition({
        componentId: 'homePage',
      })

      Button() {
        SymbolGlyph($r('sys.symbol.line_viewfinder'))
          .fontColor([$r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('扫码')
      .onClick(() => {
        new NewsScan().scan()
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}