import { routerStack, RouterMap } from 'lib_foundation'
import { PrivacyAgreementView } from 'module_privacy_agreement'

@Builder
export function SafePageBuilder() {
  SafePage()
}

@ComponentV2
struct SafePage {
  @Local
  openSheet: boolean = false

  build() {
    NavDestination() {
      PrivacyAgreementView({
        appIcon: $r('app.media.app_icon'),
        appName: '综合商城模板',
        appDesc: '这是一个适用于网络购物的综合商城应用模板',
        stack: routerStack,
        handleConfirm: () => {
          routerStack.replacePath({
            name: RouterMap.MAIN_ENTRY,
          })
        },
      })
    }
    .hideTitleBar(true)
  }
}
