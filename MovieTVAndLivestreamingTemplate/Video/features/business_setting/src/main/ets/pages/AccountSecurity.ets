import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingViewModel } from '../viewmodels/SettingVM';

@Builder
export function AccountSecurityBuilder() {
  AccountSecurity()
}

@ComponentV2
struct AccountSecurity {
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    this.vm.getCache();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '账号与安全',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            SettingCard({ list: this.vm.list6 })
            SettingCard({ list: this.vm.list7 })
            SettingCard({ list: this.vm.list8 })
          }
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}



