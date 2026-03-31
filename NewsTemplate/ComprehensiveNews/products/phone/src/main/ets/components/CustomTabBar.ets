import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, TabModel, TabBarType } from 'lib_common';
import { PhoneConstants, TabBarItem } from '../common/Constants';

@ComponentV2
export struct CustomTabBar {
  @Require @Param item: TabBarItem;
  @Param fontSizeRatio: number = 1;
  @Consumer() selectedIndex: number = TabBarType.HOME;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  build() {
    Column() {
      Image(this.item.activeIcon)
        .width($r('app.float.normal_img_size'))
        .draggable(false)
        .fillColor(this.getTabColor(this.item.id))
        .objectFit(ImageFit.Contain)
      Text(this.item.title)
        .fontSize(10 * this.fontSizeRatio)
        .fontColor(this.getTabColor(this.item.id))
        .margin({
          top: CommonConstants.PADDING_XS,
        })
    }
    .width(this.tabItemWidth)
    .height(this.tabItemHeight)
    .justifyContent(FlexAlign.Center)
    .padding({
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .onClick(() => {
      this.selectedIndex = this.item.id;
    })
  }

  getTabColor(id: number): ResourceColor {
    if (this.selectedIndex === id) {
      return $r('app.color.app_theme')
    }
    if (this.selectedIndex === TabBarType.VIDEO &&
      (this.tabModel.videoCurrentTabIndex === 0 ||
        this.tabModel.videoCurrentTabIndex === 1)) {
      return $r('sys.color.icon_on_secondary')
    }
    return $r('sys.color.font_tertiary')
  }

  @Computed
  get tabItemWidth(): Length {
    return CommonConstants.FULL_PERCENT;
  }

  @Computed
  get tabItemHeight(): Length {
    if (this.tabModel.isTabVertical) {
      return PhoneConstants.LEFT_TAB_BAR_ITEM_HEIGHT;
    }
    return PhoneConstants.BOTTOM_TAB_BAR_HEIGHT;
  }
}