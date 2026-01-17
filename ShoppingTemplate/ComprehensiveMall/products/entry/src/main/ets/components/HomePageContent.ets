import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  RouterMap,
  routerStack,
  Style,
} from 'lib_foundation';
import { CategoryItem } from 'lib_network';
import { ProductWaterFlow } from 'product';

@ComponentV2
export struct HomePageContent {
  @Param
  bannerList: ResourceStr[] = [];
  @Param
  categoryList: CategoryItem[] = [];
  @Param
  scroller: Scroller = new Scroller();
  @Local
  categoryDisplayList: CategoryItem[][] = [];
  @Event
  handleClickCategory: (id: string) => void;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  @Computed
  get waterFlowTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr'
    }
    return '1fr 1fr 1fr'
  }

  @Computed
  get bannerAspectRatio() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return 4 / 3
    }
    if (this.curBreakpoint.value === BreakpointTypeEnum.MD) {
      return 2.5
    }
    return 5
  }

  aboutToAppear(): void {
    this.getCategoryDisplayList();
  }

  build() {
    Column({ space: 12 }) {
      this.bannerBuilder();
      this.categoryBuilder();
      ProductWaterFlow({
        preId: 'home/',
        openSwiper: true,
        handleProductClick: (id) => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO,
            param: id,
          });
        },
        handleBack: () => {
          this.scroller.scrollEdge(Edge.Top);
        },
      })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .padding({
      left: $r('app.float.space_l'),
      right: $r('app.float.space_l'),
      top: $r('app.float.space_l'),
    })
    .backgroundColor(Style.BACKGROUND_COLOR_GREY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  bannerBuilder() {
    Swiper() {
      ForEach(this.bannerList, (item: string) => {
        Image(item)
          .objectFit(ImageFit.Cover)
          .draggable(false);
      }, (item: ResourceStr, index: number) => index + JSON.stringify(item));
    }
    .width('100%')
    .indicator(false)
    .autoPlay(true)
    .aspectRatio(this.bannerAspectRatio)
    .clip(true)
    .borderRadius($r('app.float.border_radius_l'));
  }

  @Builder
  categoryBuilder() {
    Column() {
      if (this.curBreakpoint.value === BreakpointTypeEnum.LG) {
        Row() {
          ForEach(this.categoryList, (category: CategoryItem) => {
            Column() {
              Image(category.iconUrl)
                .width(48)
                .height(48)
                .margin({ bottom: 4 });
              Text(category.label)
                .fontSize(12)
                .fontColor(Style.FONT_COLOR_LEVEL3);
            }
            .onClick(() => {
              this.handleClickCategory?.(category.id)
            })
          },(category:CategoryItem)=>category.id)
        }
        .width($r('app.string.size_percent_full'))
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: $r('app.float.space_m'), right: $r('app.float.space_m') })
      } else {
        Scroll() {
          Row({ space: 16 }) {
            ForEach(this.categoryDisplayList, (list: CategoryItem[]) => {
              Column({ space: 16 }) {
                ForEach(list, (category: CategoryItem) => {
                  Column() {
                    Image(category.iconUrl)
                      .width(48)
                      .height(48)
                      .margin({ bottom: 4 });
                    Text(category.label)
                      .fontSize(12)
                      .fontColor(Style.FONT_COLOR_LEVEL3);
                  }
                  .constraintSize({ minWidth: 70 })
                  .onClick(() => {
                    this.handleClickCategory?.(category.id)
                  })
                }, (item: CategoryItem) => item.id)
              }
            }, (_item: CategoryItem[], index: number) => index + '__')
          }
          .constraintSize({ minWidth: '100%' })
          .justifyContent(
            this.curBreakpoint.value === BreakpointTypeEnum.SM ?
              FlexAlign.SpaceBetween :
              FlexAlign.SpaceAround,
          )
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

    }
    .backgroundColor(Style.BACKGROUND_COLOR)
    .padding({ top: 16, bottom: 16 })
    .borderRadius(Style.BORDER_RADIUS_16)
  }

  getCategoryDisplayList() {
    if (this.categoryList.length) {
      for (let i = 0; i < this.categoryList.length; i += 2) {
        const chunk = this.categoryList.slice(i, i + 2);
        this.categoryDisplayList.push(chunk);
      }
    }
  }
}