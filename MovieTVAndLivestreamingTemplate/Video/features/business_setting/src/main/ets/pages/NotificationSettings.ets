import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingPrivacyVM } from '../viewmodels/SettingPrivacyVM';

@Builder
export function NotificationSettingsBuilder() {
  NotificationSettings()
}

@ComponentV2
struct NotificationSettings {
  @Local vm: SettingPrivacyVM = new SettingPrivacyVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({ title: '通知设置' })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            SettingCard({ list: this.vm.list4 })
          }
          .padding({
            right: CommonConstants.PADDING_PAGE,
            left: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
        }
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .hideTitleBar(true)
  }
}