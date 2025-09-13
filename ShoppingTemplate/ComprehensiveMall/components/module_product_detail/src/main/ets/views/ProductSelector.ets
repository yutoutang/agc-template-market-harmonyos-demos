import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { Constants } from '../commons/Constants';
import { ProductSelectorVM } from '../viewmodels/ProductSelectorVM';
import { SpecViewModel } from '../commons/Models';
import { ProductOperationType } from '../commons/Enums';
import { ProductInfo } from '../commons/Types';

@ComponentV2
export struct ProductSelector {
  @Param
  productInfo: ProductInfo | undefined = undefined;
  @Param
  operationType: ProductOperationType = ProductOperationType.ADD_TO_CART;
  @Event
  handleCancel: () => void;
  @Event
  handleAddCart: (skuCode: string, count: number) => void;
  @Event
  handlePayNow: (skuCode: string, count: number) => void;
  vm: ProductSelectorVM = new ProductSelectorVM();

  async aboutToAppear() {
    if (this.productInfo) {
      this.vm.initData(this.productInfo.id);
    }
  }

  build() {
    Column() {
      if (this.vm.stockInfo) {
        Scroll() {
          Column() {
            this.headerInfoBuilder();
            this.specsInfoBuilder();
            this.amountInfoBuilder();
          }
        }
        .align(Alignment.Top)
        .padding({ bottom: 12 })
        .layoutWeight(1)

        this.bottomOperationBuilder();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius({
      topLeft: 32,
      topRight: 32,
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  headerInfoBuilder() {
    Row() {
      if (this.vm.stockInfo) {
        // banner图
        Image(this.vm.selectorBanner)
          .width(112)
          .height(112)
          .borderRadius(8)
          .margin({ right: 12 });
        // 价格标签
        Column() {
          Text() {
            Span('实付 ¥');
            Span(this.vm.curPrice.toString()).fontSize(24);
            if (!this.vm.curSku) {
              Span('起');
            }
          }
          .fontColor(Constants.THEME_COLOR)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 });

          Text() {
            Span('¥');
            Span(this.vm.curDashPrice.toString());
          }
          .fontSize(12)
          .fontColor(Constants.FONT_COLOR_LEVEL1)
          .decoration({ type: TextDecorationType.LineThrough })
          .margin({ bottom: 20 });

          ForEach(this.vm.stockInfo.services, (str: string) => {
            Text(str)
              .fontColor($r('sys.color.mask_tertiary'))
              .fontSize(12);
          }, (item: string) => item);
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 16 });
      }
    }
    .width('100%')
    .height('auto')
    .alignItems(VerticalAlign.Top)
    .margin({ bottom: 20 });
  }

  @Builder
  specsInfoBuilder() {
    Column() {
      ForEach(Array.from(this.vm.specViewListMap), (item: [string, SpecViewModel[]]) => {
        Text(item[0]).specKeyTextStyle();
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(item[1], (item: SpecViewModel) => {
            Row() {
              if (item.image) {
                Image(item.image).height(32).width(32);
              }
              Text() {
                Span(item.value);
                Span(item.isTempOutOfStock || item.isOutOfStock ? '(缺货)' : '');
              }
              .fontColor(item.isSelected ? Constants.THEME_COLOR : Constants.FONT_COLOR_LEVEL1)
              .fontSize(14)
              .margin(8);
            }
            .borderRadius(4)
            .borderWidth(1)
            .flexShrink(1)
            .borderColor(item.isSelected ? Constants.THEME_COLOR : Constants.BACKGROUND_COLOR_GREY_2)
            .backgroundColor(item.isSelected ? Constants.BACKGROUND_COLOR_THEME : Constants.BACKGROUND_COLOR_GREY_2)
            .opacity(item.isOutOfStock || item.isTempOutOfStock ? 0.5 : 1)
            .onClick(() => {
              this.vm.handleSpecClick(item);
            });
          }, (item: SpecViewModel, index: number) => index + '__' + JSON.stringify(item));
        }
        .margin({ bottom: 24 });
      }, (item: [string, SpecViewModel[]], index: number) => index + '__' + JSON.stringify(item));
    }
    .alignItems(HorizontalAlign.Start);

  }

  @Builder
  amountInfoBuilder() {
    Row() {
      Text('数量').specKeyTextStyle();
      Row() {
        Image($r('app.media.ic_minus'))
          .amountOperatorIconStyle()
          .fillColor(this.vm.selectedCount <= 1 ? Constants.FONT_COLOR_LEVEL3 : Constants.FONT_COLOR_LEVEL1)
          .onClick(() => {
            this.vm.handleCountChange(false);
          });

        Text(this.vm.selectedCount.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(Constants.FONT_COLOR_LEVEL1)
          .margin(4)
          .padding(4)
          .borderRadius(0)
          .width(32)
          .textAlign(TextAlign.Center)
          .backgroundColor(Constants.BACKGROUND_COLOR_GREY);

        Image($r('app.media.ic_plus'))
          .amountOperatorIconStyle()
          .fillColor(
            !this.vm.curSku || this.vm.curSku && this.vm.selectedCount >= this.vm.curSku.stock ?
              Constants.FONT_COLOR_LEVEL3 :
              Constants.FONT_COLOR_LEVEL1)
          .onClick(() => {
            this.vm.handleCountChange();
          });
      }
      .backgroundColor(Constants.BACKGROUND_COLOR_GREY)
      .borderRadius(5)
      .margin({ right: 10 });
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  bottomOperationBuilder() {
    Button(this.vm.enableConfirm ? '确定' : '暂时缺货')
      .width('100%')
      .height(40)
      .backgroundColor(this.vm.enableConfirm ? Constants.THEME_COLOR : Constants.FONT_COLOR_LEVEL3)
      .fontColor(Constants.FONT_COLOR_1_INVERT)
      .onClick(() => {
        if (!this.vm.curSku) {
          promptAction.showToast({ message: '还有规格没有选择' });
          return;
        }
        if (this.vm.enableConfirm) {
          if (this.operationType === ProductOperationType.ADD_TO_CART) {
            this.handleAddCart?.(this.vm.curSku.skuCode, this.vm.selectedCount);
          } else {
            this.handlePayNow?.(this.vm.curSku.skuCode, this.vm.selectedCount);
          }
        }
      });
  }
}

@Extend(Text)
function specKeyTextStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .fontColor(Constants.FONT_COLOR_LEVEL1)
  .margin({ bottom: 12 });
}

@Extend(Image)
function amountOperatorIconStyle() {
  .width(16)
  .height(16)
  .margin({
    left: 12,
    right: 12,
  })
  .objectFit(ImageFit.Contain)
  .fillColor(Constants.FONT_COLOR_LEVEL1);
}