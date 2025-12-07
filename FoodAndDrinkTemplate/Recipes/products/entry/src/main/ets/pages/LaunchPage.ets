import { AccountUtil, CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib'

@Builder
export function LaunchPageBuilder() {
  LaunchPage()
}

@ComponentV2
struct LaunchPage {
  aboutToAppear(): void {
    setTimeout(() => {
      if (AccountUtil.getMembership()) {
        let privacyState = PreferenceUtil.getInstance().get(CommonConstants.PRIVACY_POLICY_KEY, '0')
        if (privacyState === '1') {
          RouterModule.replace(RouterMap.MAIN_ENTRY)
        } else {
          RouterModule.replace(RouterMap.PRIVACY_POLICY_PAGE)
        }
      }else{
        RouterModule.replace(RouterMap.LAUNCH_AD_PAGE)
      }
    }, 1000)
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.ic_launch')).width(192).height(192)
        Column() {
          Text('菜谱').fontSize(24).fontWeight(FontWeight.Medium).fontColor('#FF0000')
          Text('开启舌尖上的美味').fontSize(16).fontWeight(FontWeight.Medium).fontColor('#99FF0000')
        }
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor('#FDF7F8')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}