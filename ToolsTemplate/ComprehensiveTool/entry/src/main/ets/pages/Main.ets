import { Home } from 'home';
import { Mine } from 'mine';
import { TabBarType } from '../model/Index';

@Entry
@ComponentV2
struct Main {
  @Local homeTabIndex: number = 0;
  @Local stack: NavPathStack = new NavPathStack();

  @Builder
  mainTabBar(title: ResourceStr, targetIndex: number, selectedImg: ResourceStr, normalImg: ResourceStr) {
    Column({ space: 4 }) {
      Image(this.homeTabIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 });
      Text(title)
        .fontSize(10)
        .fontColor(this.homeTabIndex === targetIndex ? $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
        .opacity(this.homeTabIndex === targetIndex ? 1 : 0.6);
    }
    .onClick(() => {
      this.homeTabIndex = targetIndex;
    })
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(241, 243, 245, 0.8)');
  }

  build() {
    Navigation(this.stack) {
      Tabs({ index: this.homeTabIndex }) {
        TabContent() {
          Home({ pathStack: this.stack });
        }
        .tabBar(this.mainTabBar('棣栭〉', TabBarType.HOME, $r('app.media.home_active'), $r('app.media.home_inactive')));

        TabContent() {
          Mine({ pathStack: this.stack });
        }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .tabBar(this.mainTabBar('鎴戠殑', TabBarType.MINE, $r('app.media.mine_active'), $r('app.media.mine_inactive')));
      }
      .clip(true)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .animationDuration(0)
      .barPosition(BarPosition.End)
      .barBackgroundColor($r('sys.color.background_secondary'))
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onChange((value: number) => {
        this.homeTabIndex = value;
      });
    }.hideTitleBar(true).mode(NavigationMode.Stack);
  }
}