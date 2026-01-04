import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingPersonalVM } from '../viewmodels/SettingPersonalVM';

@Builder
export function SettingAccountSecurityBuilder() {
  SettingAccountSecurity()
}

@ComponentV2
struct SettingAccountSecurity {
  @Local vm: SettingPersonalVM = new SettingPersonalVM();

  aboutToAppear(): void {
    this.vm.registerKeyboard();
  }

  aboutToDisappear(): void {
    this.vm.unRegisterKeyboard();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '账户安全中心',
        onBack: () => {
          this.vm.customBack();
        },
      })
      Scroll() {
        Column({ space: CommonConstants.SPACE_M }) {


          this.phoneBuilder('换绑手机号', 0)
          this.phoneBuilder('注销账号', 1)
        }
        .padding({
          top: CommonConstants.PADDING_M,
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.vm.customBack();
      return true;
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  // 账户安全中心
  @Builder
  phoneBuilder(text: string, index: number) {
    Row() {
      Row() {
        Text(text)
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor(index === 1 ? $r('sys.color.warning') : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Image($r('app.media.ic_right'))
          .width($r('app.float.arrow_right_w'))
          .draggable(false)
      }
      .innerCard()
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
    }
    .outerCard()
    .onClick(() => {
      if (index === 0) {
        //   换绑定手机号
        RouterUtils.pushPathByName(RouterMap.SETTING_CHANGE_PHONE)
      } else {
        //   注销手机号

        RouterUtils.pushPathByName(RouterMap.DELETE_ACCOUNT)
      }
    })
  }
}

@Extend(Row)
function innerCard(height: number | string = CommonConstants.FULL_PERCENT) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_S)
  .borderRadius($r('app.float.large_radius'))
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Row)
function outerCard(height: number = 56) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_XS)
  .borderRadius($r('app.float.large_radius'))
  .backgroundColor($r('sys.color.comp_background_primary'))
}