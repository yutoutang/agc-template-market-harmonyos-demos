import { Product } from '../commons/Model';
import { NumberStepper } from './basic/NumberStepper';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct CartCard {
  // 卡片数据
  @Param data: Product = new Product();
  // 是否编辑态
  @Param isEdit: boolean = false;
  // 购物车商品数量变化的事件回调
  @Event onChangeCount: (skuCode: string) => void = (skuCode: string) => {
  };
  // 商品卡片事件回调
  @Event onCardClick: () => void = () => {
  };
  // 管理态，点击删除图标
  @Event onDelete: (skuCode: string) => void = (skuCode: string) => {
  };

  build() {
    Row({ space: 12 }) {
      this.checkboxBuilder();
      this.cardImgBuilder();
      this.cardInfoBuilder();
    }
    .alignItems(VerticalAlign.Top)
    .backgroundColor(Color.White)
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 16,
      bottom: 16,
    })
    .borderRadius(8)
    .onClick(() => {
      this.onCardClick && this.onCardClick();
    })
  }

  @Builder
  checkboxBuilder() {
    Row() {
      Checkbox({ group: 'checkboxGroup', name: this.data.skuCode })
        .selectedColor('#FFE64566')
        .shape(CheckBoxShape.CIRCLE)
        .select(this.data.isSelected)
        .onChange((value: boolean) => {
          this.data.isSelected = value;
        })
    }
    .alignSelf(ItemAlign.Stretch)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  cardImgBuilder() {
    Image(this.data.banner)
      .width(86)
      .height(86)
      .draggable(false)
      .objectFit(ImageFit.Cover)
      .borderRadius(8)
  }

  @Builder
  cardInfoBuilder() {
    Column() {
      Text(this.data.title)
        .width('100%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize(14)
        .fontColor('#E6000000')

      Text(this.data.serviceDesc)
        .fontColor($r('sys.color.mask_tertiary'))
        .fontSize(12)
        .margin({ top: 2 })

      Row({ space: 4 }) {
        Text(this.data.skuDesc)
          .fontColor($r('sys.color.mask_tertiary'))
          .fontSize(10)
        Image($r('app.media.ic_left_arrow'))
          .height(11)
          .objectFit(ImageFit.Contain)
          .rotate({ angle: -90 })
          .fillColor($r('sys.color.mask_tertiary'))
          .draggable(false)
      }
      .borderRadius(4)
      .margin({ top: 4 })
      .padding({
        top: 2,
        bottom: 2,
        left: 8,
        right: 8,
      })
      .backgroundColor('#0D000000')

      Row() {
        Text() {
          Span('¥').fontSize(10).fontColor('#FFE84026')
          Span(this.data.price.toString()).fontSize(16).fontColor('#FFE84026')

          if (this.data.dashPrice) {
            Span(' ').letterSpacing(2)
            Span('¥')
              .decoration({
                type: TextDecorationType.LineThrough,
                color: '#66000000',
              })
            Span(this.data.dashPrice.toString())
              .decoration({
                type: TextDecorationType.LineThrough,
                color: '#66000000',
              })
          }
        }
        .fontSize(10)
        .fontColor('#66000000')

        if (this.isEdit) {
          Button({ type: ButtonType.Normal, stateEffect: true }) {
            Image($r('app.media.ic_delete')).fillColor(Color.White).width(14).height(14)
          }
          .padding(4)
          .backgroundColor($r('app.color.theme_color'))
          .borderRadius(4)
          .onClick(() => {
            this.onDelete && this.onDelete(this.data.skuCode);
          })
        } else {
          NumberStepper({
            value: this.data.count,
            max: this.data.stock,
            buttonType: ButtonType.Circle,
            onChange: (value) => {
              if (value <= 0) {
                promptAction.showToast({
                  message: '宝贝数量不能再减少了~',
                  alignment: Alignment.Center,
                });
                return;
              }
              if (value > this.data.stock) {
                promptAction.showToast({
                  message: '数量不能再增加了，超出库存限制！',
                  alignment: Alignment.Center,
                });
                return;
              }
              this.data.count = value;
              this.onChangeCount && this.onChangeCount(this.data.skuCode);
            },
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ top: 12 })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Start)
  }
}