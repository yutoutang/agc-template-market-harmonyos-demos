import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, TabModel, WindowModel } from 'lib_common';
import { TabBarItem, TabBarType, TABS_INFO } from '../common/Constants';

@ComponentV2
export struct CustomTabBar {
  @Param fontSizeRatio: number = 0;
  @Consumer() selectedIndex: number = TabBarType.HOME;
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  getTabColor(id: number): ResourceColor {
    if (this.selectedIndex === id) {
      return '#0A59F7'
    }
    return $r('sys.color.font_tertiary')
  }

  getBgColor(): ResourceColor {
    return $r('sys.color.background_primary');
  }

  build() {
    Row() {
      ForEach(TABS_INFO, (item: TabBarItem) => {
        Column({ space: CommonConstants.SPACE_XS }) {
          Image(item.activeIcon)
            .width($r('app.float.normal_img_size'))
            .draggable(false)
            .fillColor(this.getTabColor(item.id))
            .objectFit(ImageFit.Contain)
          Text(item.title)
            .fontSize(10 * this.fontSizeRatio)
            .fontColor(this.getTabColor(item.id))
        }
        .layoutWeight(1)
        .padding({ top: CommonConstants.PADDING_XS, bottom: CommonConstants.PADDING_XS })
        .onClick(() => {
          this.selectedIndex = item.id;
        })
      }, (v: TabBarItem) => v.id.toString())
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }
}