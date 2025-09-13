import { Constants, TabBarData, TabBarType, TABS_INFO, WindowModel } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct CustomTabBar {
  @Consumer('currentIndex') currentIndex: TabBarType = TabBarType.HOMEPAGE;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!

  onChange(index: TabBarType): void {
    this.currentIndex = index;
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(TABS_INFO, (value: TabBarData) => {
        TabItem({
          selectedIndex: this.currentIndex,
          index: value.id,
          onChange: (index: number) => this.onChange(index),
        })
      }, (value: TabBarData) => value.id.toString())
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .shadow({
      radius: 4.5,
      color: '#80EDEDED',
      offsetX: 0,
      offsetY: -3,
    })
    .padding({
      top: 6,
      bottom: 3,
      left: 28,
      right: this.windowModel.getWindowBottomHeight(),
    })
    .clip(false)
    .height(48)
    .width(Constants.FULL_SIZE)
  }
}

@ComponentV2
struct TabItem {
  @Param @Require selectedIndex: number;
  @Param @Require index: number
  @Event onChange: (index: number) => void = () => {
  };

  build() {
    Column() {
      Image(this.selectedIndex === this.index ? TABS_INFO[this.index].activeIcon : TABS_INFO[this.index].defaultIcon)
        .width(24)
      Text(TABS_INFO[this.index].title)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor(this.index === this.selectedIndex ? ($r('sys.color.multi_color_09')) :
        $r('sys.color.font_secondary'))
    }.width(80)
    .onClick(() => this.onChange(this.index))
  }
}