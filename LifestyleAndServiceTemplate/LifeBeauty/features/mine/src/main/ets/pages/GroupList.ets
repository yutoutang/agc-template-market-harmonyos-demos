import { GroupListContentView } from '../components/GroupListContentView';
import { NavBarListView, NavItemInfo, TabTypeEnum } from '../components/NavBarListView';

@Builder
export function GroupListBuilder() {
  GroupList()
}

@ComponentV2
export struct GroupList {
  @Local tabType: TabTypeEnum = TabTypeEnum.ALL;
  @Local selectedTabIndex: number = 0;
  private controller: TabsController = new TabsController()
  tabNavList: NavItemInfo[] = [
    {id: TabTypeEnum.ALL, label: '全部'},
    {id: TabTypeEnum.UNUSED, label: '待使用'},
    {id: TabTypeEnum.USED, label: '已使用'},
    {id: TabTypeEnum.REFUNDED, label: '已退款'},
  ]

  build() {
    NavDestination() {
      Column() {
        // 自定义tabbar
        NavBarListView({
          options: this.tabNavList,
          tabType: this.tabType,
          onChangeTabType: (index: number) => {
            this.tabType = this.tabNavList[index].id;
            this.selectedTabIndex = index;
          }
        })
        Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.selectedTabIndex }) {
          ForEach(this.tabNavList, (item: NavItemInfo) => {
            TabContent() {
              GroupListContentView({
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
      .width('100%')
    }
    .title('团购')
    .backgroundColor($r('app.color.common_page_bg'))
  }
}
