import { HomePageVM } from '../viewModels/HomePageVM';
import { BaseHeader, RouterMap, RouterModule, RdbManager, CommonConstants, PreferenceUtil,
  HeaderRefreshBuilder } from 'commonlib';
import { FeaturedRecipes } from 'featured_recipes';
import { TabItem } from '../types/Index';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private rdbManager: RdbManager = new RdbManager(this.context);

  async aboutToAppear() {
    this.vm.getDishesList()
    this.rdbManager.initDatabase(this.context);
  }

  public emptyToast() {
    this.getUIContext().getPromptAction().showToast({
      message: '暂无更新数据',
      alignment: Alignment.Bottom,
    })
  }

  refresh(): void {
    setTimeout(()=>{
      this.vm.isRefreshing = false;
    },1000)
  }

  build() {
    NavDestination() {
      BaseHeader({ showSearch: this.vm.isSearchVisible, showRightMenu: this.vm.isSearchVisible })
      Refresh({ refreshing: $$this.vm.isRefreshing, builder: HeaderRefreshBuilder() }) {
        Scroll() {
          Column() {
            Swiper() {
              ForEach(this.vm.bannerUrl, (item: ResourceStr, index: number) => {
                Image(item)
                  .width(this.vm.gridCount === 2 ? '100%' : 340)
                  .height('100%')
                  .borderRadius(16)
              }, (item: ResourceStr) => JSON.stringify(item));
            }
            .width('100%')
            .height(this.vm.gridCount === 2 ? 270 : 192)
            .itemSpace(12)
            .nextMargin(this.vm.gridCount === 2 ? 0 : 12)
            .autoPlay(true)
            .loop(true)
            .indicator( // 设置圆点导航点样式
              new DotIndicator()
                .itemWidth(6)
                .itemHeight(6)
                .selectedItemWidth(12)
                .selectedItemHeight(6)
                .color('#33FFFFFF')
                .selectedColor('#E84026'))
            .borderRadius(16)
            .displayCount(this.vm.gridCount / 2)

            Column() {
              Row({ space: 8 }) {
                Image($r('app.media.ic_glass')).width(16);
                Text('今天吃点什么？').fontColor($r('sys.color.font_secondary'));
              }
              .width('100%')
              .backgroundColor('#0D000000')
              .height(40)
              .margin({ top: 12 })
              .padding(12)
              .borderRadius(24)
              .onClick(() => {
                RouterModule.push(RouterMap.SEARCH);
              })
              .onVisibleAreaChange([0.0, 1.0], (isExpanding: boolean, currentRatio: number) => {
                this.vm.isSearchVisible = currentRatio === 0
              });

              Row() {
                ForEach(this.vm.tabList, (item: TabItem, index) => {
                  Column({ space: 2 }) {
                    Image(item.icon).height(32).width(32);
                    Text(item.label).fontSize(10).fontColor($r('sys.color.font_primary'));
                  }.onClick(() => {
                    if ((this.vm.tabList.length - 1) !== index) {
                      PreferenceUtil.getInstance().putToArray(CommonConstants.SEARCH_KEYS, item.label)
                      RouterModule.push(RouterMap.SEARCH, { 'keyword': item.label } as Record<string, string>);
                    } else {
                      emitter.emit('jumpPage');
                    }
                  });
                }, (item: TabItem) => item.label);
              }
              .height(56)
              .margin({ top: 8, bottom: 8 })
              .padding({ top: 4, left: 16, right: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%');
            }
            .width('100%')

            FeaturedRecipes({
              dishesList: this.vm.dishesList,
              showTitle: true,
              isLoading: this.vm.isLoading,
              onClickCb: async (id: number) => {
                RouterModule.push(RouterMap.DISHES, { 'id': id } as Record<string, number>)
              },
              jumpBloggerInfo: (id: number) => {
                RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
              },
              loadMore: () => {
                this.vm.isLoading = true;
                // 模拟接口请求数据的延时操作
                setTimeout(()=>{
                  if(this.vm.dishesList.totalCount() < this.vm.totalCount) {
                    this.vm.dishesList.appendArrayData(this.vm.dishesList.getDataList().slice(0, 25))
                    this.vm.isLoading = false;
                  } else {
                    this.vm.isLoading = false;
                    this.emptyToast();
                  }
                },1000)
              }
            })
          }.padding({ left: 16, right: 16 });
        }.align(Alignment.Top)
        .height('calc(100% - 56vp)')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring);
      }
      .refreshOffset(56)
      .onRefreshing(() => {
        this.refresh();
      })
    }.hideTitleBar(true);
  }
}

