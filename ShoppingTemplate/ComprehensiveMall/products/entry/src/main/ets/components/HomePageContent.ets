import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  iResourceMgr,
  RouterMap,
  routerStack,
  Style,
} from 'lib_foundation';
import { ProductWaterFlow } from 'module_product_waterflow';
import { CategoryItem } from 'lib_network';

@ComponentV2
export struct HomePageContent {
  @Param
  bannerList: ResourceStr[] = [
    $r('app.media.mock_homepage_banner1'),
    $r('app.media.mock_homepage_banner2'),
    $r('app.media.mock_homepage_banner3'),
  ];
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

  aboutToAppear(): void {
    this.getCategoryDisplayList();
  }

  build() {
    Column({ space: 12 }) {
      this.bannerBuilder();
      this.categoryBuilder();
      ProductWaterFlow({
        customColumnTemplate: this.waterFlowTemplate,
        handleProductClick: (id) => {
          routerStack.pushPath({
            name: RouterMap.PRODUCT_INFO_NEW,
            param: id,
          });
        },
        handleBack: () => {
          this.scroller.scrollEdge(Edge.Top);
        },
      });
    }
    .padding(16)
    .backgroundColor(Style.BACKGROUND_COLOR_GREY);
  }

  @Builder
  bannerBuilder() {
    Swiper() {
      ForEach(this.bannerList, (item: ResourceStr) => {
        Image(item)
          .objectFit(ImageFit.Cover)
          .draggable(false);
      }, (item: ResourceStr, index: number) => index + JSON.stringify(item));
    }
    .width('100%')
    .indicator(false)
    .autoPlay(true)
    .aspectRatio(this.curBreakpoint.value === BreakpointTypeEnum.SM ? 4 / 3 : 16 / 9)
    .clip(true)
    .borderRadius($r('app.float.border_radius_l'));
  }

  @Builder
  categoryBuilder() {
    Column() {
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.categoryDisplayList, (list: CategoryItem[]) => {
            Column({ space: 16 }) {
              ForEach(list, (category: CategoryItem) => {
                Column() {
                  Image(iResourceMgr.resolveUri(category.iconUrl))
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
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
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