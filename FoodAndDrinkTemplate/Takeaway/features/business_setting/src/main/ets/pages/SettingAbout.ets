import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingAboutVM } from '../viewmodels/SettingAboutVM';

@Builder
export function SettingAboutBuilder() {
  SettingAbout()
}

@ComponentV2
struct SettingAbout {
  vm: SettingAboutVM = new SettingAboutVM();

  build() {
    NavDestination() {
      NavHeaderBar({ title: '关于我们' })
      Scroll() {
        Column() {
          this.appInfo()
        }
        .width(CommonConstants.FULL_PERCENT)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE,
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  appInfo() {
    Column({ space: CommonConstants.SPACE_XL }) {
      Text('关于我们')
        .fontSize(29 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bolder)
        .alignSelf(ItemAlign.Start)
      Image($r('app.media.about_us'))
        .width('100%')
        .draggable(false)
      Text('app简介')
        .fontSize(22 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.Start)
      Text(this.vm.appDesc)
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Normal)
        .alignSelf(ItemAlign.Start)
        .letterSpacing(1)
      Image($r('app.media.app_introduction'))
        .width('100%')
        .draggable(false)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(224)
    .justifyContent(FlexAlign.Center)
  }
}