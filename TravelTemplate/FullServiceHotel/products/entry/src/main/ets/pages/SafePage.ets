import { RouterMap, RouterModule } from 'commonlib'
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
        appIcon: $r('app.media.app_foreground'),
        appName: '酒店模板',
        appDesc: '这是一个适用于综合酒店的应用模板',
        stack:RouterModule.stack,
        handleConfirm: () => {
          RouterModule.replace({
            url: RouterMap.MAIN_ENTRY,
          })
        },
      })
    }
    .hideTitleBar(true)
  }
}
