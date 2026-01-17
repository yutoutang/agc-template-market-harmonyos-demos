import { AppStorageV2, display } from '@kit.ArkUI';
import { BreakpointModel } from 'foundation';

export interface NavItemInfo {
  id: number
  label: ResourceStr
}

export enum TabTypeEnum {
  ALL = 0,
  NEW = 10,
  FINISH = 30,
  CANCEL = 40,
  OVER_TIME = 50,
  UNUSED = 60,
  USED = 70,
  REFUNDED = 80,
}

@ComponentV2
export struct NavBarListView {
  @Param options: NavItemInfo[] = [];
  @Param tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Event onChangeTabType: (index: number) => void = (index: number) => {};
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local isEdgeEffect: boolean = false;
  listScroller: ListScroller = new ListScroller();

  @Monitor('tabType')
  onChangeTabTypeWatch() {
    const index = this.options.findIndex((item) => item.id === this.tabType);
    this.listScroller.scrollToIndex(index, true)
  }

  build() {
    List({space: 8, scroller: this.listScroller}) {
      ForEach(this.options, (item: NavItemInfo, index: number) => {
        ListItem() {
          Row() {
            Text(item.label)
              .fontSize(14)
              .fontWeight(500)
              .fontColor(this.tabType === item.id ? Color.White : $r('sys.color.font_primary'))
          }
          .padding({left: 16, right: 16, top: 8, bottom: 8})
          .borderRadius(20)
          .backgroundColor(this.tabType === item.id ? '#E64566' : $r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            this.onChangeTabType?.(index)
          })
        }
      }, (v: NavItemInfo) => JSON.stringify(v))
    }
    .width('100%')
    .height(56)
    .listDirection(Axis.Horizontal)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
    })
    .scrollBar(BarState.Off)
    .edgeEffect(this.isEdgeEffect ? EdgeEffect.Spring : EdgeEffect.None, { alwaysEnabled: true })
    .alignListItem(ListItemAlign.Center)
    .onAreaChange((oldValue: Area, newValue: Area) => {
      const displayClass = display.getDefaultDisplaySync();
      const displayWidth = this.getUIContext().px2vp(displayClass.width)
      const rect = this.listScroller.getItemRect(1);
      const distance = rect.width + rect.x;
      const all = distance * this.options.length;
      this.isEdgeEffect = all > displayWidth;
      this.onChangeTabTypeWatch();
    })
  }
}