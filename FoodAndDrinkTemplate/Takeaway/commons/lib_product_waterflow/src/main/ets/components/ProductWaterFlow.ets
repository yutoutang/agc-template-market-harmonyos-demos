import { CommonConstants, LazyDataSource } from 'lib_common';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';
import { Constants } from '../commons/Constants';
import { LabelPresetType, RequestType } from '../commons/Enums';
import { LabelItem, ProductCardItem, ProductListResp } from '../commons/Types';
import { ProductWaterFlowApis } from '../https/Apis';

export interface UniformStoreStyle {
  bodyFg?: Length
  bodyFgColor?: ResourceColor
  imgRatio?: number
}

@ComponentV2
export struct ProductWaterFlow {
  @Param
  scoreThreshold?: number = undefined; //最低评分阈值（可选）
  @Param
  salesThreshold?: number = undefined; // 最低销量阈值（可选）
  @Param
  deliveryTimeThreshold?: number = undefined; // 最大配送时间阈值（可选）
  @Param
  changeByThreshold: number = 0;
  @Param
  changeByCategoryNum: number = 0;
  @Param
  requestType: RequestType = RequestType.DEFAULT;
  @Param
  categoryId?: string = undefined;
  @Consumer()
  searchValue: string = '';
  @Param
  address: string = '';
  @Param
  keywords: string = '';
  @Param
  isVertical: boolean = false;
  @Param
  showInitLoading: boolean = false;
  @Param
  bgColor: ResourceColor = Constants.BACKGROUND_COLOR_GREY;
  @Param
  customColumnTemplate?: string = undefined
  @Local
  dataList: LazyDataSource<StoreResponse> = new LazyDataSource();
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

  @Param customStyle: UniformStoreStyle = {
    bodyFg: $r('sys.float.Title_L'),
    bodyFgColor: $r('sys.color.font_primary'),
    imgRatio: 1,
  };

  @Computed
  get showButton() {
    return this.scrollHeight > 400;
  }

  @Monitor('changeByThreshold')
  changeThreshold() {
    if (this.requestType === RequestType.DEFAULT) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList(this.address);
    }
  }

  @Monitor('categoryId')
  changeCategory() {
    if (this.requestType === RequestType.BY_CATEGORY && this.categoryId) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList(this.address);
    }
  }

  @Monitor('changeByCategoryNum')
  changeByCategory() {
    if (this.requestType === RequestType.BY_CATEGORY) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList(this.address);
    }
  }

  @Monitor('searchValue')
  changeKeywords() {
    if (this.requestType === RequestType.BY_WORDS) {
      this.scroller.scrollEdge(Edge.Top);
      this.dataList.clear();
      this.reachEnd = false;
      this.getDataList(this.address);
    }
  }

  @Monitor('address')
  changeAddress() {
    this.scroller.scrollEdge(Edge.Top);
    this.dataList.clear();
    this.reachEnd = false;
    this.getDataList(this.address);
  }

  aboutToAppear(): void {
    this.getDataList(this.address);
  }

  build() {
    Column() {
      if (this.isLoading && this.showInitLoading && this.dataList.isEmpty()) {
        LoadingProgress()
          .size({ width: 72, height: 72 })
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
            LazyForEach(this.dataList, (item: StoreResponse) => {
              FlowItem() {
                if (!this.isVertical) {
                  this.horizontalProductCardBuilder(item);
                } else {
                  this.verticalProductCardBuilder(item);
                }
              }
              .onClick(() => {
                this.handleProductClick?.(item.id);
              });
            }, (item: ProductCardItem, index: number) => index + item.productId);
          }
          .height('100%')
          .cachedCount(4)
          .columnsTemplate(this.columnTemplate)
          .columnsGap(12)
          .rowsGap(12)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .onReachEnd(() => {
            this.getDataList(this.address);
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
    .backgroundColor(Color.Transparent)
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
  horizontalProductCardBuilder(item: StoreResponse) {
    Column() {
      Image($r(`app.media.${item.coverUrl}`))

      Column({ space: CommonConstants.SPACE_XS }) {
        //店铺名称
        this.titleBuilder(item.name);
        //评分 月售
        Row({ space: CommonConstants.SPACE_M }) {
          Row() {
            RelativeContainer() {
              //替换成 收藏svg图片
              Image($r('app.media.ic_star_yellow'))
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .borderRadius($r('app.float.small_radius'))
            }
            .width(14 / (this.customStyle.imgRatio ?? 1))
            .height(14 / (this.customStyle.imgRatio ?? 1))
            .accessibilityGroup(true)
            .accessibilityLevel('no')
            .margin({ right: 2 })

            //评分
            Text(item?.score.toString())
              .fontSize(10)
              .fontWeight(400)
              .fontColor('#888888')
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          //月销量
          Text('月售' + item?.monthlySales.toString())
            .fontSize(10)
            .fontWeight(400)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        }
        .alignItems(VerticalAlign.Center)
        .margin({
          bottom: 8
        })

        //配送信息
        Row({ space: CommonConstants.SPACE_S }) {
          // 配送时间
          Text(item?.deliveryTime.toString() + '分钟')
            .fontSize(10)
            .fontWeight(400)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          //起送价
          Text('起送¥' + item?.startingPrice.toString())
            .fontSize(10)
            .fontWeight(400)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(VerticalAlign.Center)

        //距离
        Row({ space: CommonConstants.SPACE_S }) {
          // 距离
          Text(item?.distance.toString() + 'km')
            .fontSize(10)
            .fontWeight(400)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          //配送费
          Text('配送¥' + item?.deliveryFee.toString())
            .fontSize(10)
            .fontWeight(400)
            .fontColor('#888888')
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        }
        .alignItems(VerticalAlign.Center)
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
  verticalProductCardBuilder(item: StoreResponse) {
    Row() {
      Image($r(`app.media.${item.coverUrl}`))
        .width(100)
        .height(100)
        .borderRadius(8);

      Column({ space: 2 }) {
        //店铺名称
        Text(item?.name)
          .fontSize(18)
          .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        //评分 月售
        Row({ space: CommonConstants.SPACE_S }) {
          Row() {
            RelativeContainer() {
              //替换成 收藏svg图片
              Image($r('app.media.ic_star_yellow'))
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .borderRadius($r('app.float.small_radius'))
            }
            .width(14 / (this.customStyle.imgRatio ?? 1))
            .height(14 / (this.customStyle.imgRatio ?? 1))
            .accessibilityGroup(true)
            .accessibilityLevel('no')

            //评分
            Text(item?.score.toString())
              .fontSize(13)
              .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          //月销量
          Text('月售' + item?.monthlySales.toString())
            .fontSize(13)
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)

        // 起送价+配送费+配送时间+配送距离
        Row({ space: CommonConstants.SPACE_S }) {
          //起送价
          Text('起送¥' + item?.startingPrice.toString())
            .fontSize(13)
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          //配送费
          Text('配送¥' + item?.deliveryFee.toString())
            .fontSize(13)
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Blank().width('16%')
          // 配送时间
          Text(item?.deliveryTime.toString() + '分钟')
            .fontSize(13)
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          // 距离
          Text(item?.distance.toString() + 'km')
            .fontSize(13)
            .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding(8)
    }
    .height(280)
    .clip(true)
    .borderRadius(16)
    .backgroundColor(Constants.BACKGROUND_COLOR);
  }

  @Builder
  waterFlowFootBuilder() {
    Row() {
      if (this.dataList.totalCount() && this.isLoading) {
        LoadingProgress()
          .size({ width: 32, height: 32 })
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
      .fontColor('#333333')
      .fontWeight(400)
      .fontSize(14)
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
        }, (label: LabelItem) => label.data);
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
        }, (promotion: string) => promotion);
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

  async getDataList(address: string) {
    this.isLoading = true;
    if (!this.reachEnd) {
      let res: ProductListResp | undefined = undefined;
      switch (this.requestType) {
        case RequestType.DEFAULT:
          res = await ProductWaterFlowApis.getProductListByOptionalFilters(address, this.scoreThreshold,
            this.salesThreshold, this.deliveryTimeThreshold);
          break;
        case RequestType.BY_CATEGORY:
          if (this.categoryId) {
            res = await ProductWaterFlowApis.getProductListByCategoryId(address, this.categoryId, this.scoreThreshold,
              this.salesThreshold, this.deliveryTimeThreshold);
          }
          break;
        case RequestType.BY_WORDS:
          if (typeof this.searchValue !== 'undefined') {
            res = await ProductWaterFlowApis.getProductListByKeywords(address, this.searchValue, this.categoryId);
          }
          break;
        default:
          break;
      }
      if (res) {
        const newData: StoreResponse[] = res.list;
        if (!res.isFinal && res.list.length <= 4) {
          // 模拟数据已经全部查询完,额外添加结果数量判断,保持与cacheCount一致
          this.reachEnd = true;
        } else {
          this.reachEnd = res.isFinal;
        }
        newData.forEach((item) => {
          this.dataList.pushData(item);
        });
      }
    }
    this.isLoading = false;
  }
}
