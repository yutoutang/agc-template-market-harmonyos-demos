import { AgreementSettingList } from '../commons/Constants'
import { SettingCard } from '../components/SettingCard'

@Builder
export function AgreementPageBuilder() {
  AgreementPage()
}

@ComponentV2
export struct AgreementPage {
  build() {
    NavDestination() {
      SettingCard({
        list: AgreementSettingList,
      })
    }
    .title('隐私政策')
    .backgroundColor($r('app.color.background_color_grey'))
  }
}