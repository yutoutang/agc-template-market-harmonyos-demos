import {
  BaseTextStyleModifier,
  CommonConstants,
  CommonHeader,
  FontUtil,
  PopViewUtils,
  RouterMap,
  RouterModule,
  settingFontBuilder,
  SettingFontParams,
  WindowUtil,
} from 'lib_foundation';
import { MineVM } from '../viewmodels/MineVM';

@ComponentV2
export struct SettingPage {
  vm: MineVM = MineVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: '设置' }).margin({ bottom: CommonConstants.SPACE_8 })

      List() {
        this.itemBuilder('字号设置', () => {
          PopViewUtils.showSheet<SettingFontParams>(
            wrapBuilder(settingFontBuilder),
            { height: SheetSize.FIT_CONTENT, showClose: false },
            new SettingFontParams(FontUtil.getRate() === 1 ? 0 : 1, (index: number) => {
              FontUtil.setRate(index);
            }));
        })

        this.itemBuilder('隐私协议', () => {
          RouterModule.push({ url: RouterMap.PRIVACY_POLICY });
        })
      }
      .layoutWeight(1)
      .divider({
        strokeWidth: 0.5,
        color: $r('sys.color.comp_divider'),
        startMargin: 0,
        endMargin: 0,
      }).width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })

      if (this.vm.userInfo.isLogin) {
        Text('退出登录')
          .width('calc(100% - 32vp)')
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .height(40)
          .borderRadius(CommonConstants.HALF_PERCENT)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.vm.logout();
          })
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }

  @Builder
  itemBuilder(label: string, click: () => void) {
    ListItem() {
      Row() {
        Text(label)
          .layoutWeight(1)
          .attributeModifier(new BaseTextStyleModifier('font_primary/Body_L/Medium'))
        Image($r('app.media.right_arrow')).width(7).fillColor($r('sys.color.icon_secondary'))
      }
    }
    .height(48)
    .onClick(() => {
      click();
    })
  }
}


@Builder
export function settingPageBuilder() {
  SettingPage()
}