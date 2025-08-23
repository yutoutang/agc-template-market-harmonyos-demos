import { RouteEntryVM } from 'common'

@Builder
export function PrivacyPageBuilder() {
  PrivacyPage()
}

@ComponentV2
export struct PrivacyPage {
  scroller: Scroller = new Scroller()
  vm: RouteEntryVM = RouteEntryVM.instance;

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Column() {
          Column() {
            this.privacyCard('隐私服务')
          }
          .width('100%')
          .padding(16)
        }
        .height('100%')
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical) // 滚动方向纵向
      .scrollBar(BarState.Auto) // 滚动条常驻显示
      .scrollBarColor(Color.Gray) // 滚动条颜色
      .scrollBarWidth(0) // 滚动条宽度
      .friction(0.6)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title('隐私管理')
  }

  @Builder
  privacyCard(title: string) {
    Row() {
      Text(title)
      Image($r('app.media.moreicon'))
        .width(7)
        .height(13)
    }
    .width('100%')
    .height(61)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.white'))
    .borderRadius(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .onClick(()=>{
      this.vm.toRouteDetail('PrivacyPolicyDetailPage')
    })
  }
}