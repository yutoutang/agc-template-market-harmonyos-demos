import { Style } from 'lib_foundation';
import { OrderSkuItem } from 'lib_network';

@ComponentV2
export struct OrderItemCard {
  @Param
  sku: OrderSkuItem | undefined = undefined;

  build() {
    if (this.sku) {
      Row() {
        Image(this.sku.banner)
          .width(80)
          .height(80)
          .objectFit(ImageFit.Cover)
          .borderRadius(Style.BORDER_RADIUS_8)
          .margin({ right: 12 })
          .backgroundColor(Style.ICON_COLOR_GREY);
        Column() {
          Text(this.sku.title)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontSize(Style.FONT_SIZE_14)
            .fontColor(Style.FONT_COLOR_LEVEL1)
            .fontWeight(FontWeight.Medium);
          Text('规格：' + this.sku.skuDesc).textSecondaryStyle();
          Text('数量：' + this.sku.count).textSecondaryStyle();
          Blank();
          Text(this.sku.serviceDesc).textThirdlyStyle();
        }
        .layoutWeight(1)
        .margin({ right: 16 })
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start);

        Column() {
          Text() {
            Span('¥').fontSize(Style.FONT_SIZE_12);
            Span(this.sku.price.toString());
          }
          .fontColor(Style.THEME_COLOR)
          .fontWeight(FontWeight.Medium);

          Text() {
            Span('¥');
            Span(this.sku.dashPrice.toString());
          }
          .decoration({
            type: TextDecorationType.LineThrough,
            color: Style.FONT_COLOR_LEVEL3,
          })
          .fontSize(Style.FONT_SIZE_10)
          .fontColor(Style.FONT_COLOR_LEVEL3)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 });
        }
        .height('100%')
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .height(80)
      .margin({ bottom: 16 });
    }

  }
}

@Extend(Text)
function textSecondaryStyle() {
  .fontColor(Style.FONT_COLOR_LEVEL3)
  .fontSize(Style.FONT_SIZE_12)
  .margin({ top: 4 });
}

@Extend(Text)
function textThirdlyStyle() {
  .fontColor(Style.FONT_COLOR_LEVEL3)
  .fontSize(Style.FONT_SIZE_10);
}