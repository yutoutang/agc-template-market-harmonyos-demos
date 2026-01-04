import { CommonConfirmDialog, CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from '../components/SettingCard';
import { SettingItem } from '../types/Types';
import { SettingViewModel } from '../viewmodels/SettingVM';
import { promptAction } from '@kit.ArkUI';

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
            SettingCard({
              list: [new SettingItem({
                label: '注销账号',
                labelFontColor: '#e84026',
                onClick: () => {
                  if (this.vm.userInfoModel.isLogin) {
                    CommonConfirmDialog.show({
                      primaryTitle: '请确认是否注销?',
                      content: '您的订单记录、优惠券、积分等将全部失效且无法恢复。',
                      priBtnV: '取消',
                      secBtnV: '确认注销',
                      secBtnFg: '#e84026',
                      confirm: () => {
                        this.vm.cancelOutBtnClick();
                      },
                    })
                  } else {
                    promptAction.showToast({ message: '请先登录' });
                  }
                },
              })]
            })
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
                .width($r('app.float.loading_icon_size'))
                .aspectRatio(1)
                .color($r('sys.color.icon_secondary'))
                .visibility(this.vm.isLoading ? Visibility.Visible : Visibility.None)
              Text(this.vm.signOutBtnLabel)
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .margin({ top: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
          .enabled(!this.vm.isLoading)
          .onClick(() => {
            CommonConfirmDialog.show({
              content: '确定要退出登录吗?',
              confirm: () => {
                this.vm.onSignOutBtnClick();
              },
            })
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