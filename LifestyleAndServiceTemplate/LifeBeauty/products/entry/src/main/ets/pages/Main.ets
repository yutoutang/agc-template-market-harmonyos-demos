import { CommonConstants, CustomShareModel,
  getGroupList,
  getSingleVisitCardList,
  OrderType, RouterMap, RouterModule,
} from 'foundation';
import { Home } from 'home';
import { Mine } from 'mine';
import { AppStorageV2 } from '@kit.ArkUI';

class TabItemModel {
  label: ResourceStr = '';
  icon: ResourceStr = '';
  iconSelected: ResourceStr = '';
}

@Builder
export function MainBuilder() {
  Main()
}

@ComponentV2
struct Main {
  @Local selectedIndex: number = 0;
  @Local shareRouter: CustomShareModel = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;

  aboutToAppear(): void {
    if (this.shareRouter.id) {
      this.formShareChange()
    }
  }

  @Monitor('shareRouter.id')
  formShareChange() {
    if (this.shareRouter.id) {
      // 通过this.shareRouter.goodsId查询商品详情，并实现页面跳转
      this.jumpPage(this.shareRouter.pageName)
    }
  }

  async jumpPage(url: string) {
    let currentName: string[] = RouterModule.getStack().getAllPathName()
    // 打开首页
    if (currentName.length && currentName[currentName.length-1] === RouterMap.MAIN &&
      url === RouterMap.MAIN) {
      RouterModule.popToName(RouterMap.MAIN);
    } else if (currentName.length && currentName[currentName.length-1] === url) {
      // 当前页
      const params = await this.getParams()
      RouterModule.replace({ url, param: params });
    } else {
      const params = await this.getParams()
      RouterModule.push({ url, param: params });
    }
  }

  async getParams() {
    const type = this.shareRouter.goodType
    if (type === OrderType.SINGLE_CARD) {
      const singleList = await getSingleVisitCardList();
      const singleData = (singleList ?? []).find(item => item.id === this.shareRouter.goodId);
      return singleData
    }
    const goodList = await getGroupList();
    const groupInfo = (goodList ?? []).find(item => item.id === this.shareRouter.goodId);
    return groupInfo
  }

  @Builder
  tabBuilder(index: number, item: TabItemModel) {
    Column({ space: 4 }) {
      Image(this.selectedIndex === index ? item.iconSelected : item.icon)
        .width(17)
        .height(17)
        .objectFit(ImageFit.Contain)
      Text(item.label)
        .fontColor(this.selectedIndex === index ? $r('app.color.common_theme_color') :
        $r('app.color.home_tab_unselected'))
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width(CommonConstants.FULL_PERCENT)
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ index: $$this.selectedIndex }) {
          TabContent() {
            Home()
          }
          .clip(false)
          .tabBar(this.tabBuilder(0, {
            label: $r('app.string.tab_home'),
            icon: $r('app.media.ic_home_home_grey'),
            iconSelected: $r('app.media.ic_home_home_highlight'),
          }))

          TabContent() {
            Mine()
          }
          .clip(false)
          .tabBar(this.tabBuilder(1, {
            label: $r('app.string.tab_mine'),
            icon: $r('app.media.ic_public_person'),
            iconSelected: $r('app.media.ic_public_person_highlight'),
          }))
        }
        .clip(false)
        .height(CommonConstants.FULL_PERCENT)
        .width(CommonConstants.FULL_PERCENT)
        .scrollable(false)
        .barPosition(BarPosition.End)
        .onTabBarClick((index: number) => {
          this.selectedIndex = index;
        })
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }.hideTitleBar(true)
  }
}