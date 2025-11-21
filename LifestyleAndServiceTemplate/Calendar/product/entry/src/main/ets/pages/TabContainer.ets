import { PerpetualCalendar } from 'perpetual'
import { TabsInfo, ThemeModel, UserState, WeekStart } from 'common'
import { Almanac } from 'almanac'
import { MinePage } from 'mine'
import { PersistenceV2 } from '@kit.ArkUI';
import { baseToast, getDataFromJSON } from 'base_apis';
import { emitter } from '@kit.BasicServicesKit';
import { RouterModule } from 'router_module';

@ComponentV2
export struct TabContainer {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Local currentIndex: number = 0
  @Local tabsInfos: TabsInfo[] = []
  private controller: TabsController = new TabsController()
  @Local weekStart: WeekStart = PersistenceV2.connect(WeekStart, () => new WeekStart())!;
  @Local message: string = '';

  getTabsInfo() {
    this.tabsInfos = getDataFromJSON<TabsInfo>('Tabs_Info.json', this);
  }

  aboutToAppear() {
    let event: emitter.InnerEvent = {
      eventId: 1,
    };
    this.widgetInterception()
    this.getTabsInfo()
    this.registerInterception()
  }

  /*
   * 卡片跳转拦截
   * */
  widgetInterception() {
    this.message = AppStorage.get('widget_router') ?? ''
    if (!this.message) {
      return
    }
    if (this.message === 'almanac') {
      this.controller.changeIndex(1)
    }else {
      this.controller.changeIndex(0)
    }
  }

  /*
   * 路由拦截
   * */
  registerInterception() {
    RouterModule.setInterception({
      // 页面跳转前拦截，允许操作栈，在当前跳转中生效。
      willShow: (from: NavDestinationContext | 'navBar', to: NavDestinationContext | 'navBar',
        operation: NavigationOperation, animated: boolean) => {
        if (typeof to === 'string') {
          console.log('target page is navigation home');
          return;
        }
        /*
         * 判断登录状态,并跳转到我的页面进行关联
         * */
        let target: NavDestinationContext = to as NavDestinationContext;
        if (!this.userState.isLogin &&
        ['PersonInformation','VipOpenCenter'].includes(target?.pathInfo?.name)) {
          baseToast.show({
            type: 'dialog',
            hasTitle: $r('app.string.associated_account'),
            message: $r('app.string.associated_account_tips'),
            confirmAction: () => {
              RouterModule.pushPathByName({ url: 'LoginWithHuaweiID' })
              baseToast.hide()
            },
          })
          target.pathStack.pop();
        }
      },
    })
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column({ space: 5 }) {
      Image(this.currentIndex === index ? $r(this.tabsInfos[index].icon) : $r(this.tabsInfos[index].iconSel))
        .width(24)
        .fillColor(this.currentIndex === index ? this.theme.themeState.tabColor :
        this.theme.themeState.tabColorInActive)
      Text(name)
        .fontColor(this.currentIndex === index ? this.theme.themeState.tabColor :
        this.theme.themeState.tabColorInActive)
        .fontSize($r('sys.float.Caption_M'))
    }
    .width('100%')
    .margin({ top: 5, bottom: Number(AppStorage.get('bottomRectHeight')) })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.controller }) {
        TabContent() {
          PerpetualCalendar({
            jumpToAlmanac: () => {
              this.controller.changeIndex(1)
            },
          })
        }.tabBar(this.tabBuilder(0, '万年历'))

        TabContent() {
          Almanac()
        }.tabBar(this.tabBuilder(1, '黄历'))

        TabContent() {
          MinePage()
        }.tabBar(this.tabBuilder(2, '我的'))
      }
      .vertical(false)
      .scrollable(false)
      .animationDuration(0)
      .barHeight(80)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .onAreaChange(() => {
        this.widgetInterception()
      })
    }
    .width('100%')
    .height('100%')
  }
}