import { common } from '@kit.AbilityKit'
import { CommonConstants, PreferenceUtil, RouterMap, RouterModule } from 'commonlib'

@Builder
export function PrivacyPolicyPageBuilder() {
  PrivacyPolicyPage()
}

@ComponentV2
struct PrivacyPolicyPage {
  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Image($r('app.media.startIcon')).width(72).height(72).margin({ top: 136 }).borderRadius(16)
            Text('菜谱')
              .fontSize(30)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 24 })
            Text('业务描述').fontSize(14).fontColor($r('sys.color.font_secondary')).margin({ top: 2 })
          }

          Column() {
            Image($r('app.media.ic_privacy')).width(24).height(24)
            Text('隐私协议') {
              Span('本应用需')
              Span('联网').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
              Span('，调用')
              Span('XX').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
              Span('、')
              Span('XX').fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
              Span('权限，获取XX信息，以为您提供XX服务。我们仅在您使用具体功能业务时，才会触发上述行为收集使用相关的个人信息。详情请参阅')
              Span('XX业务与隐私的声明、权限使用说明').fontWeight(FontWeight.Medium).fontColor('#FF0000').onClick(() => {
                RouterModule.push(RouterMap.TERMS_OF_SERVICE_PAGE);
              })
              Span('。')
            }.fontSize(10).fontColor($r('sys.color.font_secondary')).margin({ top: 16 })

            Text('请您仔细阅读上述声明，点击“同意”，即表示您知悉并同意我们向您提供本应用服务。')
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor('#E84026')
                .backgroundColor($r('sys.color.background_secondary'))
                .onClick(() => {
                  let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
                  context.terminateSelf()
                })
              Button('同意')
                .layoutWeight(1)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_on_primary'))
                .backgroundColor('#E84026')
                .onClick(() => {
                  PreferenceUtil.getInstance().put(CommonConstants.PRIVACY_POLICY_KEY, '1')
                  RouterModule.replace(RouterMap.MAIN_ENTRY)
                })
            }.margin({ top: 16 })
          }
        }.height(CommonConstants.FULL_HEIGHT).padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceBetween)
      }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)

    }.hideTitleBar(true).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}