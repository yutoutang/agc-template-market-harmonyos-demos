import { common, EnvironmentCallback, Configuration } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { RouterMap, RouterModule } from 'foundation';
import { NavBarListView, NavItemInfo, TabTypeEnum } from '../components/NavBarListView';
import { AppointmentContentView } from '../components/AppointmentContentView';

const TAG = '[AppointmentList]';

@Builder
export function appointmentListBuilder() {
  AppointmentList()
}

@ComponentV2
export struct AppointmentList {
  @Local systemLanguage: string = '';
  @Local isRefreshing: boolean = false;
  @Local tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Local selectedTabIndex: number = 0;
  private controller: TabsController = new TabsController()
  tabNavList: NavItemInfo[] = [
    {id: TabTypeEnum.ALL, label: '全部'},
    {id: TabTypeEnum.NEW, label: '已预约'},
    {id: TabTypeEnum.FINISH, label: '已完成'},
    {id: TabTypeEnum.CANCEL, label: '已取消'},
    {id: TabTypeEnum.OVER_TIME, label: '已失效'},
  ]
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // 注册订阅系统环境变化的ID
  private callbackId: number = 0;

  aboutToAppear(): void {
    const paramList: TabTypeEnum[] = RouterModule.getNavParam({ url: RouterMap.MY_APPOINTMENT_LIST });
    if (paramList.length) {
      this.tabType = paramList[paramList.length - 1] as TabTypeEnum;
      const index = this.tabNavList.findIndex((item) => item.id === this.tabType);
      this.selectedTabIndex = index;
      this.controller.changeIndex(index);
    }
    this.subscribeConfigurationUpdate();
  }

  aboutToDisappear(): void {
    this.unsubscribeConfigurationUpdate();
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义tabbar
        NavBarListView({
          options: this.tabNavList,
          tabType: this.tabType,
          onChangeTabType: (index: number) => {
            this.tabType = this.tabNavList[index].id;
            this.controller.changeIndex(index);
            this.selectedTabIndex = index;
          }
        })

        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.selectedTabIndex }) {
          ForEach(this.tabNavList, (item: NavItemInfo) => {
            TabContent() {
              AppointmentContentView({
                systemLanguage: this.systemLanguage,
                tabType: item.id,
                currentType: this.tabType
              })
            }
          }, (item: NavItemInfo) => JSON.stringify(item))
        }
        .width('100%')
        .layoutWeight(1)
        .barHeight(0)
        .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
          this.tabType = this.tabNavList[targetIndex].id;
        })
        .onChange((index: number) => {
          this.selectedTabIndex = index;
        })
      }
    }
    .title('我的预约')
    .backgroundColor($r('app.color.common_page_bg'))
  }

  subscribeConfigurationUpdate(): void {
    // 获取系统当前语言
    this.systemLanguage = this.context.config.language || i18n.System.getFirstPreferredLanguage();

    // 1.获取ApplicationContext
    let applicationContext = this.context.getApplicationContext();

    // 2.通过applicationContext订阅环境变量变化
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (newConfig: Configuration) => {
        if (this.systemLanguage !== newConfig.language) {
          this.systemLanguage = newConfig.language || '';
        }
      },
      onMemoryLevel: (level) => {
      },
    }
    try {
      this.callbackId = applicationContext.on('environment', environmentCallback);
    } catch (err) {
      Logger.error(TAG, 'applicationContext.on(environment error: ' + JSON.stringify(err));
    }
  }

  unsubscribeConfigurationUpdate() {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('environment', this.callbackId);
    } catch (err) {
      Logger.error(TAG, 'applicationContext.off(environment error: ' + JSON.stringify(err));
    }
  }
}