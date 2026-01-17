import { Constants } from '../commons/Constants';
import { ProductInfo, ProductServiceItem } from '../commons/Types';

@ComponentV2
export struct ProductInfoCard {
  @Param
  productInfo: ProductInfo | undefined = undefined;
  @Param
  bgColor: ResourceColor = Constants.BACKGROUND_COLOR;

  build() {
    if (this.productInfo) {
      Column({ space: 8 }) {
        // 价格、销量
        Row() {
          Text() {
            Span('¥').priceTextStyle();
            Span(this.productInfo.price).priceTextStyle().fontSize(24);
            Span(' ').letterSpacing(4);
            Span('¥').dashPriceTextStyle();
            Span(this.productInfo.dashPrice).dashPriceTextStyle();
          }
          .margin({ right: 4 });

          Blank();
          Text(this.productInfo.sales).infoTextStyle().fontColor(Constants.FONT_COLOR_LEVEL2);
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom);

        // 标题
        Text(this.productInfo.title)
          .width('100%')
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .lineHeight(24)
          .fontColor(Constants.FONT_COLOR_LEVEL1)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        // 标签
        Row({ space: 4 }) {
          ForEach(this.productInfo.tags, (item: string) => {
            Row() {
              Text(item)
                .fontSize(10)
                .fontColor(Constants.THEME_COLOR)
                .fontWeight(FontWeight.Medium);
            }
            .padding({
              left: 8,
              right: 8,
              top: 2,
              bottom: 2,
            })
            .borderRadius(Constants.BORDER_RADIUS_4)
            .backgroundColor(Constants.BACKGROUND_COLOR_THEME);
          }, (item: string) => item);
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);


        //发货信息
        this.serviceInfoBuilder(this.productInfo.logistics);

        // 服务信息
        this.serviceInfoBuilder(this.productInfo.service);

      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12,
      })
      .backgroundColor(this.bgColor);
    }
  }

  @Builder
  serviceInfoBuilder(services: ProductServiceItem[]) {
    Column() {
      ForEach(services, (service: ProductServiceItem) => {
        Row() {
          Image(service.icon)
            .width(14)
            .height(10)
            .fillColor($r('sys.color.mask_tertiary'))
            .margin({ right: 8 });
          Text(service.content)
            .infoTextStyle();
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }, (item: ProductServiceItem) => item.content);
    }
    .alignItems(HorizontalAlign.Start);
  }
}

@Extend(Span)
function priceTextStyle() {
  .fontSize(12)
  .fontWeight(FontWeight.Medium)
  .fontColor(Constants.THEME_COLOR);
}

@Extend(Span)
function dashPriceTextStyle() {
  .fontSize(12)
  .fontWeight(FontWeight.Regular)
  .fontColor(Constants.FONT_COLOR_LEVEL3)
  .decoration({
    type: TextDecorationType.LineThrough,
    color: '#66000000',
  });
}

@Extend(Text)
function infoTextStyle() {
  .fontSize(12)
  .lineHeight(18)
  .fontWeight(FontWeight.Regular)
  .fontColor(Constants.FONT_COLOR_LEVEL3);
}