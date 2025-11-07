import { HomePageVM } from '../viewModels/HomePageVM';
import { BaseHeader, RouterMap, RouterModule } from 'commonlib';
import { FeaturedRecipes } from 'featured_recipes';
import { TabItem } from '../types/Index';
import { emitter } from '@kit.BasicServicesKit';

@Builder
export function HomePageBuilder() {
  HomePage();
}

@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getDishesList()
  }

  build() {
    NavDestination() {
      BaseHeader({ showSearch: this.vm.isSearchVisible, showRightMenu: this.vm.isSearchVisible })
      Scroll() {
        Column() {
          Swiper() {
            ForEach(this.vm.bannerUrl, (item: ResourceStr) => {
              Image(item).width('100%').height(270).borderRadius(16);
            }, (item: ResourceStr) => item.toString());
          }
          .width('100%')
          .height(270)
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
          .borderRadius(16);

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
            onClickCb: (id: number) => {
              RouterModule.push(RouterMap.DISHES, { 'id': id } as Record<string, number>)
            },
            jumpBloggerInfo: (id: number) => {
              RouterModule.push(RouterMap.BLOGGER_PROFILE_PAGE, { 'id': id } as Record<string, number>)
            },
          })
        }.padding({ left: 16, right: 16 });
      }.align(Alignment.Top)
      .height('calc(100% - 56vp)')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }.hideTitleBar(true);
  }
}

