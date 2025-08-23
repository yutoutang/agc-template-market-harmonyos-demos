import { getString } from '@agctemplate/resources';
import { appRouter } from '@agctemplate/utils';
import { ListItemModel, MinePageVM, NavDestinationModifier } from '@agctemplate/widgets'
import { VipCenter } from 'vip_center';

@Preview
@ComponentV2
export struct VIPCenterPage {
  @Local vm: MinePageVM = MinePageVM.instance
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        VipCenter({
          userName: this.vm.userInfo.nickname,
          avatar: this.vm.userInfo.avatar,
          isVip: this.vm.userInfo.isVip,
          vipExpiryDate: this.vm.userInfo.vipExpiryDate,
          packageBack: (isVip, vipExpiryDate) => {
            this.vm.userInfo.isVip = isVip
            this.vm.userInfo.vipExpiryDate = vipExpiryDate
          }
        })
      }.width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(false)
    .title(this.title())
    .backgroundImage($r('app.media.vip_bg'))
    .backgroundImageSize({ width: '100%' })
    .attributeModifier(this.navDestinationModifier)
    .height('100%')
  }

  @Builder
  title() {
    Text(getString('app.string.VIP_button'))
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .height(27)
      .margin({ top: 15, left: 8 })
  }
}

@Builder
export function VIPCenterPageBuilder() {
  VIPCenterPage()
}