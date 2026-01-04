import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingNoticeVM } from '../viewmodels/SettingNoticeVM';

@Builder
export function SettingNoticeBuilder() {
  SettingNotice()
}

@ComponentV2
struct SettingNotice {
  @Local vm: SettingNoticeVM = new SettingNoticeVM();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '通知设置',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            SettingCard({ list: this.vm.list1 })
          }
          .padding({
            right: CommonConstants.PADDING_PAGE,
            left: CommonConstants.PADDING_PAGE,
            top: CommonConstants.PADDING_M,
          })
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .scrollBar(BarState.Off)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}