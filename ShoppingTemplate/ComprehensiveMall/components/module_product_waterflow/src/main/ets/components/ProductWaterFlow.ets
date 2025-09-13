import { Constants } from '../commons/Constants';
import { LabelPresetType, RequestType } from '../commons/Enums';
import { LabelItem, ProductCardItem, ProductListResp } from '../commons/Types';
import { ProductWaterFlowApis } from '../https/Apis';
import { LazyDataSource } from '../utils/LazyDataSource';

@ComponentV2
export struct ProductWaterFlow {
  @Param
  requestType: RequestType = RequestType.DEFAULT;
  @Param
  categoryId?: string = undefined;
  @Param
  keywords?: string = undefined;
  @Param
  isVertical: boolean = false;
  @Param
  showInitLoading: boolean = false;
  @Param
  bgColor: ResourceColor = Constants.BACKGROUND_COLOR_GREY;
  @Param
  customColumnTemplate?: string = undefined
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
  @Event
  handleProductClick: (id: string) => void;
  @Event
  handleBack: () => void;
  scroller: Scroller = new Scroller();

  @Computed
  get columnTemplate() {
    if (this.customColumnTemplate) {
      return this.customColumnTemplate
    }
    return this.isVertical ? '1fr' : '1fr 1fr';
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

  @Monitor('categoryId')
  changeCategory() {
    if (this.requestType === RequestType.BY_CATEGORY && this.categoryId) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList();
    }
  }

  @Monitor('keywords')
  changeKeywords() {
    if (this.requestType === RequestType.BY_WORDS) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList();
    }
  }

  aboutToAppear(): void {
    this.getDataList();
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
              .fontColor(Constants.FONT_COLOR_LEVEL2);
          };
        } else {
          WaterFlow({
            scroller: this.scroller,
            footer: this.waterFlowFootBuilder(),
          }) {
            LazyForEach(this.dataList, (item: ProductCardItem) => {
              FlowItem() {
                if (!this.isVertical) {
                  this.horizontalProductCardBuilder(item);
                } else {
                  this.verticalProductCardBuilder(item);
                }
              }
              .onClick(() => {
                this.handleProductClick?.(item.productId);
              });
            }, (item: ProductCardItem, index: number) => index + item.productId);
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
    .justifyContent(FlexAlign.Center);
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
    .backgroundColor(Constants.BACKGROUND_COLOR);
  }

  @Builder
  verticalProductCardBuilder(item: ProductCardItem) {
    Row() {
      Image(item.banner)
        .width(100)
        .height(100)
        .borderRadius(8);

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
    .backgroundColor(Constants.BACKGROUND_COLOR);
  }

  @Builder
  waterFlowFootBuilder() {
    Row() {
      if (this.dataList.totalCount() && this.isLoading) {
        LoadingProgress().width(32);
      } else if (!this.isLoading) {
        Text(this.reachEnd ? '已经到达底部' : '向上滑动加载数据')
          .fontSize(12)
          .fontColor(Constants.FONT_COLOR_LEVEL3);
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
      .fontColor(Constants.FONT_COLOR_LEVEL1)
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
            Span(label.data).fontColor(Constants.LABEL_COLOR_PRIMARY);
          } else if (label.preset === LabelPresetType.SECONDARY) {
            Span(label.data).fontColor(Constants.LABEL_COLOR_SECONDARY);
          }
          if (index < labels.length - 1) {
            Span(' | ').fontColor(Constants.FONT_COLOR_LEVEL3);
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
              .fontColor(Constants.THEME_COLOR)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          .borderWidth(1)
          .borderColor(Constants.THEME_COLOR)
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
          .fontColor(Constants.FONT_COLOR_LEVEL3)
          .decoration({ type: TextDecorationType.LineThrough, color: Constants.FONT_COLOR_LEVEL3 });
      }
    }
    .fontSize(12)
    .fontColor(Constants.THEME_COLOR)
    .fontWeight(FontWeight.Medium);
  }

  async getDataList() {
    this.isLoading = true;
    if (!this.reachEnd) {
      let res: ProductListResp | undefined = undefined;
      switch (this.requestType) {
        case RequestType.DEFAULT:
          res = await ProductWaterFlowApis.getProductList();
          break;
        case RequestType.BY_CATEGORY:
          if (this.categoryId) {
            res = await ProductWaterFlowApis.getProductListByCategoryId(this.categoryId);
          }
          break;
        case RequestType.BY_WORDS:
          if (typeof this.keywords !== 'undefined') {
            res = await ProductWaterFlowApis.getProductListByKeywords(this.keywords);
          }
          break;
        default:
          break;
      }
      if (res) {
        const newData: ProductCardItem[] = res.list;
        this.reachEnd = res.isFinal;
        newData.forEach((item) => {
          this.dataList.pushData(item);
        });
      }
    }
    this.isLoading = false;
  }
}
