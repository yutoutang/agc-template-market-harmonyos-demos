import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingViewModel } from '../viewmodels/SettingVM';

@Builder
export function SettingPageBuilder() {
  SettingPage()
}

@ComponentV2
struct SettingPage {
  @Local vm: SettingViewModel = new SettingViewModel();

  aboutToAppear(): void {
    this.vm.getCache();
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '设置',
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            SettingCard({ list: this.vm.list1 })
            SettingCard({ list: this.vm.list2 })
            SettingCard({ list: this.vm.list3 })
            SettingCard({ list: this.vm.list4 })
              .visibility(this.vm.userInfoModel.isLogin ? Visibility.Visible : Visibility.None)
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

        Column() {
          Button() {
            Row({ space: CommonConstants.SPACE_XS }) {
              LoadingProgress()
                .size({ width: 24, height: 24})
                .aspectRatio(1)
                .color($r('sys.color.icon_on_primary'))
                .visibility(this.vm.isLoading ? Visibility.Visible : Visibility.None)
              Text(this.vm.signOutBtnLabel)
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor(Color.White)
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .enabled(!this.vm.isLoading)
          .onClick(() => {
            this.vm.onSignOutBtnClick();
          })
        }
        .visibility(this.vm.userInfoModel.isLogin ? Visibility.Visible : Visibility.None)
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}