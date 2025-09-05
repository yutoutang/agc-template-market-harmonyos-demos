import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, WindowModel } from 'lib_common';
import { TabModel } from 'lib_common/src/main/ets/models/TabModel';
import { TabNav } from '../models/VideoModel';
import { NewsSearchTransition } from 'lib_widget';

@ComponentV2
export struct TabHeaderView {
  // tab页签的数据
  @Param @Require tabNavs: TabNav[]
  // 当前tab下标
  @Param currentTabIndex: number = 1;
  // 当前indicator的下标
  @Param indicatorIndex: number = 1;
  // 切换事件
  @Event onChangeTabIndex: (index: number) => void = (index: number) => {
  }
  // 返回按钮
  @Local translateX: number = -40
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;

  @Monitor('tabModel.showTabBar')
  onChangeShowTabBar(monitor: IMonitor) {
    if (this.tabModel.isTabVertical) {
      return;
    }
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateX = -40
    } else {
      this.translateX = 0
    }
  }

  @Monitor('tabModel.isTabVertical')
  onShowChangeTabBar(monitor: IMonitor) {
    let isShowCustomTabBar = monitor.value()?.now as boolean
    if (isShowCustomTabBar) {
      this.translateX = -40
    }
  }

  getTextColor(item: TabNav, index: number): ResourceColor {
    if (this.indicatorIndex === index) {
      return item.activeColor
    }
    if (this.indicatorIndex === 0 || this.indicatorIndex === 1) {
      return '#99ffffff'
    }
    return $r('sys.color.font_primary')
  }

  build() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_left_arrow')).width(9).height(16)
            .offset({ right: 10 })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.End)
        .onClick(() => {
          this.tabModel.showTabBar = true
        })

        List({ space: CommonConstants.SPACE_L }) {
          ForEach(this.tabNavs, (item: TabNav, index: number) => {
            ListItem() {
              this.tabBuilder(item, index)
            }
          }, (item: TabNav, index: number) => item.id + index)
        }
        .height(56)
        .width('100%')
        .listDirection(Axis.Horizontal)
        .padding({ left: CommonConstants.PADDING_L, right: CommonConstants.PADDING_L })
        .alignListItem(ListItemAlign.Center)
      }
      .translate({ x: this.translateX })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .layoutWeight(1)

      NewsSearchTransition({
        isVideo:true,
        componentId:'videoPage',
        indicatorIndex:this.indicatorIndex
      })
    }
    .width('100%')
    .padding({
      top: this.windowModel.windowTopPadding,
      right: CommonConstants.PADDING_L
    })
  }

  @Builder
  tabBuilder(item: TabNav, index: number) {
    Column() {
      Text(item.name)
        .fontColor(this.getTextColor(item, index))
        .fontSize(16)
        .fontWeight(this.indicatorIndex === index ? 700 : 400)

      Row() {
      }
      .width(16)
      .height(2)
      .borderRadius(1)
      .backgroundColor(this.indicatorIndex === index ? item.activeColor : '')
      .position({ left: CommonConstants.PADDING_S, bottom: CommonConstants.PADDING_S })
    }
    .justifyContent(FlexAlign.Center)
    .height(CommonConstants.FULL_PERCENT)
    .onClick(() => {
      this.onChangeTabIndex && this.onChangeTabIndex(index)
    })
  }
}