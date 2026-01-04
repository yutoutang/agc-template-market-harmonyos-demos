import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingAuthorizationVM } from '../viewmodels/SettingAuthorizationVM';

@Builder
export function SettingAuthorizationBuilder() {
  SettingAuthorization()
}

@ComponentV2
struct SettingAuthorization {
  @Local vm: SettingAuthorizationVM = new SettingAuthorizationVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '授权',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            SettingCard({ list: this.vm.list1 })
          }
          .alignItems(HorizontalAlign.Start)
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.initCheckAuthorization()
    })
  }
}