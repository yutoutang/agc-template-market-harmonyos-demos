import { TabListItem } from '../types';
import { MainEntryVM } from '../viewmodels/MainEntryVM';

@Builder
export function MainEntryBuilder() {
  MainEntry()
}

@ComponentV2
struct MainEntry {
  vm: MainEntryVM = MainEntryVM.instance;
  private controller: TabsController = new TabsController();

  build() {
    NavDestination() {
      Tabs({ barPosition: BarPosition.End, index: this.vm.curIndex, controller: this.controller }) {
        ForEach(this.vm.tabList, (item: TabListItem, index: number) => {
          TabContent() {
            item.component.builder();
          }
          .tabBar(this.tabBarBuilder(item, index))
          .clip(index !== 0);
        }, (item: TabListItem, index: number) => JSON.stringify(item));
      }
      .scrollable(false)
      .height('100%')
      .animationDuration(0)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => {
        this.vm.curIndex = index;
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .barBackgroundColor($r('app.color.background_color_white'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onBackPressed(()=> {
      return this.vm.handleBackPressed()
    })
  }

  @Builder
  tabBarBuilder(item: TabListItem, index: number) {
    Column() {
      Image(this.vm.curIndex === index ? item.iconChecked : item.icon)
        .width(24)
        .height(24);
      Text(item.label)
        .fontColor(this.vm.curIndex === index ? $r('app.color.theme_color') :
        $r('app.color.font_color_level3'))
        .fontSize($r('app.string.font_size_10'))
        .margin({ top: $r('app.string.margin_xs') });
    }
    .width($r('app.string.width_percent_full'))
  }
}