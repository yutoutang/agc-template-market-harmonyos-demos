import { RouterMap, RouterModule } from 'commonlib';
import { ProductItem } from '../commons/Types';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct MainProduct {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      if (this.vm.productAd) {
        Image(this.vm.productAd)
          .width('100%')
          .borderRadius($r('app.string.border_radius_16'));
      }

      GridRow({
        columns: 2,
        gutter: { x: $r('app.string.margin_l'), y: $r('app.string.margin_l') },
        direction: GridRowDirection.Row,
      }) {
        ForEach(this.vm.productList, (item: ProductItem) => {
          GridCol() {
            Column() {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(item.image)
                  .width('100%')
                  .aspectRatio(4 / 3)
                  .objectFit(ImageFit.Cover)
                  .draggable(false)
                  .borderRadius($r('app.string.border_radius_16'));

                Text('月销' + (item.monthlySales? item.monthlySales : '--'))
                  .fontSize($r('app.string.font_size_10'))
                  .borderRadius($r('app.string.border_radius_capsule'))
                  .fontColor($r('app.color.font_color_level1_invert'))
                  .backgroundColor($r('app.color.font_color_level3'))
                  .padding($r('app.string.padding_xs'))
                  .margin({ left: $r('app.string.margin_xs'), bottom: $r('app.string.margin_xs') });
              };

              Text(item.label)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontSize($r('app.string.font_size_16'))
                .margin({ top: $r('app.string.margin_s'), bottom: $r('app.string.margin_xs') })
                .fontColor($r('app.color.font_color_level1'));
              Text() {
                Span('¥' + item.discountedPrice)
                Span(' ').letterSpacing(2)
                Span('¥' + item.originalPrice)
                  .fontSize($r('app.string.font_size_12'))
                  .fontColor($r('app.color.font_color_level2'))
                  .decoration({ type: TextDecorationType.LineThrough });
              }
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.highlight_color'));
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.RESTAURANT_FOOD_INFO, param: Number(item.id) });
            });
          };
        }, (item: ProductItem) => JSON.stringify(item));
      }
      .margin({
        top: $r('app.string.margin_m'),
      });
    };
  }
}