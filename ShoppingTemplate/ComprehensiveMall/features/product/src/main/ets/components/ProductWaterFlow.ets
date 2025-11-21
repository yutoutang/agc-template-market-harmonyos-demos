import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  LazyDataSource,
  RouterMap,
  routerStack,
} from 'lib_foundation';
import { FilterSelectionItem, ProductApis } from 'lib_network';
import { ProductCardItem, LabelItem } from 'lib_network/src/main/ets/types/responses/ProductResponse';
import { LoneTakeAnimationsTransition, LongTakeTransitionParam } from 'module_transition';
import { LabelPresetType, SortTypeMap } from '../commons/Enums';
import util from '@ohos.util';

@ComponentV2
export struct ProductWaterFlow {
  @Param
  preId: string = ''
  @Param
  categoryId?: string = undefined;
  @Param
  keywords?: string = undefined;
  @Param
  isVertical: boolean = false;
  @Param
  showInitLoading: boolean = false;
  @Param
  bgColor: ResourceColor = $r('app.color.background_color_grey');
  @Param
  customColumnTemplate?: string = undefined
  @Param
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Param
  filterList: FilterSelectionItem[] = []
  @Param
  openSwiper: boolean = false
  @Local
  dataList: LazyDataSource<ProductCardItem> = new LazyDataSource();
  @Local
  reachEnd: boolean = false;
  @Local
  isLoading: boolean = false;
  @Local
  scrollHeight: number = 0;
  @Local
  startBack: boolean = false;
  @Local
  curPage: number = 1
  @Local
  showSheet: boolean = false
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Event
  handleProductClick: (id: string) => void;
  @Event
  handleBack: () => void;
  scroller: Scroller = new Scroller();
  @Local
  testId: string = util.generateRandomUUID(false)

  @Computed
  get columnTemplate() {
    if (this.customColumnTemplate) {
      return this.customColumnTemplate
    }
    if (this.isVertical) {
      return this.curBreakpoint.value === BreakpointTypeEnum.LG ? '1fr 1fr' : '1fr'
    }
    const map: Map<BreakpointTypeEnum, string> = new Map([
      [BreakpointTypeEnum.SM, '1fr 1fr'],
      [BreakpointTypeEnum.MD, '1fr 1fr 1fr'],
      [BreakpointTypeEnum.LG, '1fr 1fr 1fr 1fr'],
    ])
    return map.get(this.curBreakpoint.value);
  }

  @Computed
  get edgeEffect() {
    if (typeof this.scroller.isAtEnd() === 'undefined') {
      return EdgeEffect.Spring;
    }
    return this.reachEnd || this.scroller.isAtEnd() ? EdgeEffect.Spring : EdgeEffect.None;
  }

  @Computed
  get showButton() {
    return this.scrollHeight > 400;
  }

  @Monitor('categoryId','keyword','sortType','filterList')
  async refreshList() {
    this.curPage = 1;
    this.reachEnd = false;
    this.dataList.clear()
    await this.getDataList()
  }

  aboutToAppear(): void {
    this.refreshList();
  }

  build() {
    Column() {
      if (this.isLoading && this.showInitLoading && this.dataList.isEmpty()) {
        LoadingProgress()
          .width(32);
      } else {
        if (!this.dataList.totalCount()) {
          Column() {
            Image($r('app.media.ic_search_empty'))
              .width(120)
              .height(120);
            Text('暂无搜索结果')
              .fontSize(14)
              .fontColor($r('app.color.font_color_level2'));
          };
        } else {
          WaterFlow({
            scroller: this.scroller,
            footer: this.waterFlowFootBuilder(),
          }) {
            LazyForEach(this.dataList, (item: ProductCardItem, index: number) => {
              FlowItem() {
                if (!this.isVertical) {
                  this.horizontalProductCardBuilder(item);
                } else {
                  this.verticalProductCardBuilder(item);
                }
              }
              .id(this.testId + '/' + item.productId)
              .onClick(() => {
                if (this.openSwiper) {
                  // routerStack.pushPath({
                  //   name: RouterMap.PRODUCT_SWIPER,
                  //   param: item.productId,
                  // })
                  this.jumpToSwiperPage(this.testId + '/' + item.productId)
                } else {
                  this.handleProductClick?.(item.productId);
                }
              });
            }, (item: ProductCardItem, index: number) => this.testId + '/' + item.productId);
          }
          .height('100%')
          .cachedCount(4)
          .columnsTemplate(this.columnTemplate)
          .columnsGap(12)
          .rowsGap(12)
          .edgeEffect(this.edgeEffect)
          .onReachEnd(() => {
            this.getDataList();
          })
          .onScrollStop(() => {
            this.scrollHeight = this.scroller.currentOffset().yOffset;
            if (this.scrollHeight === 0 && this.startBack) {
              this.handleBack?.();
              this.startBack = false;
            }
          })
          .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])

          if (this.showButton) {
            this.backTopButtonBuilder();
          }
        }
      }
    }
    .backgroundColor(this.bgColor)
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP]);
  }

  @Builder
  backTopButtonBuilder() {
    if (this.showButton) {
      Image($r('app.media.ic_back_top_button'))
        .width(40)
        .height(40)
        .position({
          right: 16,
          bottom: 56,
        })
        .onClick(() => {
          this.startBack = true;
          this.scroller.scrollTo({
            xOffset: 0,
            yOffset: 0,
            animation: {
              curve: Curve.Linear,
              duration: 500,
            },
          });
        });
    }
  }

  @Builder
  horizontalProductCardBuilder(item: ProductCardItem) {
    Column() {
      Image(item.banner);
      Column({ space: 8 }) {
        this.titleBuilder(item.title);
        this.labelBuilder(item.label);
        this.promotionBuilder(item.promotion);
        this.priceBuilder(item.price, item.dashPrice);
      }
      .padding(8)
      .alignItems(HorizontalAlign.Start);
    }
    .borderRadius(16)
    .clip(true)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_color_white'));
  }

  @Builder
  verticalProductCardBuilder(item: ProductCardItem) {
    Row() {
      Image(item.banner)
        .width(100)
        .height(100)
        .borderRadius(8)

      Column({ space: 4 }) {
        this.titleBuilder(item.title);
        this.labelBuilder(item.label);
        this.promotionBuilder(item.promotion);
        this.priceBuilder(item.price, item.dashPrice);
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding(8)
      .height('100%');
    }
    .height(100)
    .clip(true)
    .borderRadius(16)
    .backgroundColor($r('app.color.background_color_white'));
  }

  @Builder
  waterFlowFootBuilder() {
    Row() {
      if (this.dataList.totalCount() && this.isLoading) {
        LoadingProgress().width(32);
      } else if (!this.isLoading) {
        Text(this.reachEnd ? '已经到达底部' : '向上滑动加载数据')
          .fontSize(12)
          .fontColor($r('app.color.font_color_level3'));
      }
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
    .padding(16);
  }

  @Builder
  titleBuilder(title: string) {
    Text(title)
      .fontColor($r('app.color.font_color_level1'))
      .fontWeight(FontWeight.Medium)
      .fontSize(12)
      .maxLines(2)
      .textOverflow({ overflow: TextOverflow.Ellipsis });
  }

  @Builder
  labelBuilder(labels: LabelItem[]) {
    if (labels.length) {
      Text() {
        ForEach(labels, (label: LabelItem, index: number) => {
          if (label.preset === LabelPresetType.PRIMARY) {
            Span(label.data).fontColor($r('app.color.label_color_primary'));
          } else if (label.preset === LabelPresetType.SECONDARY) {
            Span(label.data).fontColor($r('app.color.label_color_secondary'));
          }
          if (index < labels.length - 1) {
            Span(' | ').fontColor($r('app.color.font_color_level3'));
          }
        }, (label: LabelItem, index: number) => index + label.data);
      }
      .fontSize(12)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis });
    }
  }

  @Builder
  promotionBuilder(promotions: string[]) {
    if (promotions.length) {
      Flex() {
        ForEach(promotions, (promotion: string) => {
          Row() {
            Text(promotion)
              .fontSize(8)
              .fontColor($r('app.color.theme_color'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          .borderWidth(1)
          .borderColor($r('app.color.theme_color'))
          .borderRadius(2)
          .padding(2)
          .flexShrink(1);
        }, (promotion: string, index: number) => index + promotion);
      };
    }
  }

  @Builder
  priceBuilder(price: number, dashPrice?: number) {
    Text() {
      Span('¥');
      Span(price.toString()).fontSize(16);
      if (dashPrice) {
        Span(' ').letterSpacing(2);
        Span('¥' + dashPrice)
          .fontColor($r('app.color.font_color_level3'))
          .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.font_color_level3') });
      }
    }
    .fontSize(12)
    .fontColor($r('app.color.theme_color'))
    .fontWeight(FontWeight.Medium);
  }

  async getDataList() {
    if (this.reachEnd) {
      return;
    }
    this.isLoading = true
    const res = await ProductApis.getProductList({
      curPage: this.curPage,
      categoryId: this.categoryId,
      keyword: this.keywords,
      sortType: this.sortType,
      filterList: this.filterList,
    })
    if (res.list.length) {
      const newData: ProductCardItem[] = res.list;
      this.reachEnd = res.isFinal;
      newData.forEach((item) => {
        this.dataList.pushData(item);
      });
      this.curPage++
    }
    this.isLoading = false;
  }

  private async jumpToSwiperPage(snapShotComponentId: string) {
    let longTakeTransitionParam: LongTakeTransitionParam | undefined =
      LoneTakeAnimationsTransition.generateLongTakeParam(this.getUIContext(), snapShotComponentId, 9);
    const res = await ProductApis.getProductList({
      curPage: 1,
      targetId: snapShotComponentId.split('/')[1],
    })
    const param: Record<string, Object | undefined> = {
      'snapShotId': snapShotComponentId,
      'longTakeTransitionParam': longTakeTransitionParam,
      'dataList': res.list ?? [],
    };
    routerStack.pushPath({
      name: RouterMap.PRODUCT_SWIPER,
      param: param,
    })
  }
}
