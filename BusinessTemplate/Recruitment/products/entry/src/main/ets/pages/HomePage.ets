import { BarVM, Constants, RouterMap, UserInfo } from 'common';
import { MessageListPage } from 'message';
import { MinePage } from 'person';
import { PositionPage } from 'position';
import { PersistenceV2 } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import { LoginPageBuilder } from 'aggregated_login';

/**
 * @usage: tab 页面控制类，包括职位、消息、我的
 * @layout:
 * @constraints: tab 页面控制类，包括职位（position）、消息（message）、我的（person）。
 * 根据用户实际需求仅修改代码中 TAB 变量，当前仅支持删除变量中的元素，以及修改 id，从 0 开始并保证 id 顺序，其他元素不允许修改。
 * @isGen: true
 * @fileType: tab
 */

@Builder
function message() {
  Column() {
    MessageListPage()
  }
  .backgroundColor($r('sys.color.background_primary'))
}

@Builder
function person() {
  MinePage()
}

@Builder
function position() {
  Column() {
    PositionPage()
  }
  .backgroundColor($r('sys.color.background_primary'))
}

const positionBuilder: WrappedBuilder<[string]> = wrapBuilder(position);
const messageListPageBuilder: WrappedBuilder<[string]> = wrapBuilder(message);
const personBuilder: WrappedBuilder<[string]> = wrapBuilder(person);

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  @Local currentIndexTab: number = 0;
  tabsController: TabsController = new TabsController();
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndexTab === index ? selectedImg : normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 4 })
        .fontSize(10)
        .fontColor(this.currentIndexTab === index ? '#FF564AF7' : '#99000000')
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
    .onClick(() => {
      if (!this.userInfo?.isLogin && index === 1) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
        return
      }
      this.currentIndexTab = index;
      this.tabsController.changeIndex(this.currentIndexTab);
    })

  }

  @Builder
  tabContentBuilder(text: Resource,
    index: number,
    selectedImg: Resource,
    normalImg: Resource,
    builder: WrappedBuilder<[string]>) {
    TabContent() {
      Stack() {
        builder.builder('');
      }
      .height('100%')
    }
    .backgroundColor(Color.White)
    .tabBar(this.tabBuilder(text, index, selectedImg, normalImg))
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: BarPosition.End,
        controller: this.tabsController
      }) {
        this.tabContentBuilder($r('app.string.position_tab'),
          Constants.TAB_INDEX_ZERO, $r('app.media.position_tab_active'), $r('app.media.position_tab'), positionBuilder)
        this.tabContentBuilder($r('app.string.message_tab'),
          Constants.TAB_INDEX_ONE, $r('app.media.message_tab_active'), $r('app.media.message_tab'),
          messageListPageBuilder)
        this.tabContentBuilder($r('app.string.person_tab'),
          Constants.TAB_INDEX_TWO, $r('app.media.person_tab_active'), $r('app.media.person_tab'), personBuilder)
      }
      .clip(true)
      .width('100%')
      .padding({
        bottom: BarVM.instance.aiBarH
      })
      .backgroundColor('#F3F4F5')
      .barHeight(50)
      .barMode(BarMode.Fixed)
      .animationDuration(0)
      .scrollable(false)
      .onAnimationStart((targetIndex: number) => {
        this.currentIndexTab = targetIndex;
      })
      .onChange((index: number) => {
        if (index === 1) {
          this.getUIContext().getHostContext()?.eventHub.emit(Constants.onMessagePageShowChange);
        }
      })
    }
    .hideTitleBar(true)
    .onShown(() => {
      if (this.currentIndexTab === 1) {
        this.getUIContext().getHostContext()?.eventHub.emit(Constants.onMessagePageShowChange);
      }
    })
    .onHidden(() => {
      if (this.currentIndexTab === 1) {
        this.getUIContext().getHostContext()?.eventHub.emit(Constants.onMessagePageHideChange);
      }
    })
  }
}
