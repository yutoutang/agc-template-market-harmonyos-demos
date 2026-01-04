import { LoginSheetUtils } from 'lib_account';
import { CommonConstants } from 'lib_common';
import { WallpaperServiceApi } from 'lib_wallpaper_api';
import { NavHeaderBar } from 'lib_widget';
import { WaterFlowComponent } from 'module_waterflow';
import { ComponentDetailTitle, DesktopViewModel, WeatherCardInfo, WoodenFishCardInfo } from '../viewmodels/DeskTopVM';

export interface CardItem {
  cardType: number,
  cards: Card[]
}

@ObservedV2
export class Card {
  @Trace id: number = 0;
  @Trace type: 'weather' | 'woodenFish' = 'weather';
  @Trace cardSize: 'small' | 'medium' | 'large' = 'small';
  @Trace data?: WeatherCardInfo | WoodenFishCardInfo;
}

interface TabType {
  name: string;
  tabName: string
}

interface GuessLikeParams {
  page: number;
  pageSize: number;
}


@Builder
export function DesktopComponentsPageBuilder() {
  DesktopComponentsPage()
}

@ComponentV2
struct DesktopComponentsPage {
  @Local vm: DesktopViewModel = new DesktopViewModel();
  @Local cardData: CardItem[] = [];
  @Local tabList: TabType[] = [
    { name: '推荐', tabName: 'recommended' },
    { name: '天气', tabName: 'weather' },
    { name: '木鱼', tabName: 'woodenFish' },
    { name: '趣味', tabName: 'other' }
  ];
  @Local params: GuessLikeParams = {
    page: 1,
    pageSize: 6
  }
  @Local allTotal: number = 1;
  @Local currentIndex: number = 0

  async queryGuessData(tabName: string, refresh?: boolean) {
    const result: ESObject =
      await WallpaperServiceApi.getDesktopComponents(tabName, this.params.page, this.params.pageSize)
    if (refresh) {
      this.cardData = result.cardItem
    } else {
      this.cardData = this.cardData.concat(result.cardItem)
    }
    this.allTotal = result.total
    this.params.page++
  }

  async onLoad() {
    await this.queryGuessData(this.tabList[this.currentIndex].tabName)
  }

  async toComponentDetail(params: ComponentDetailTitle) {
    await this.vm.jumpComponentDetail(params)
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '桌面小组件',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.rightHeadPartBuilder()
          },
        })

        // Tab 切换栏
        Tabs() {
          ForEach(this.tabList, (item: TabType) => {
            TabContent() {
              this.buildTabContent();
            }.tabBar(SubTabBarStyle.of(item.name))
          }, (item: TabType, index: number) => item.name + '_' + index)
        }
        .scrollable(false)
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          this.params.page = 1
          this.cardData = []
          this.queryGuessData(this.tabList[targetIndex].tabName);
        })
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .backgroundColor($r('sys.color.background_secondary'))
    }
  }

  @Builder
  buildTabContent() {
    Column() {
      Scroll() {
        WaterFlowComponent({
          dataSource: this.cardData,
          finished: Math.ceil(this.allTotal / this.params.pageSize) < this.params.page,
          lanes: this.vm.breakpointModel.currentBreakpoint !== 'md' ? 1 : 2,
          onLoad: async () => {
            await this.onLoad()
          },
          toComponentDetail: async (params: ComponentDetailTitle) => {
            await this.toComponentDetail(params)
          }
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
    }
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  rightHeadPartBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      Image($r('app.media.ic_tutorial')).width($r('app.float.head_icon_width'))
        .onClick(() => {
          this.vm.jumpTutorial()
        })
        .borderRadius('50%')
      Image($r('app.media.ic_my_component')).width($r('app.float.head_icon_width'))
        .onClick(() => {
          if (this.vm.userInfoModel.isLogin) {
            this.vm.jumpMyComponent()
          } else {
            LoginSheetUtils.open();
          }
        })
        .borderRadius('50%')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}