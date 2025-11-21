import { CommonConfirmDialog } from 'module_ui_base';
import { PopupSheet } from './PopupSheet';

@ComponentV2
export struct CartControlPanel {
  // 是否是编辑态
  @Param isEdit: boolean = false;
  // 是否是子页面路由
  @Param isChildRoute: boolean = false;
  // 总价
  @Param totalPrice: number = 0;
  // 优惠
  @Param discountAmount: number = 0;
  // 选择的商品个数
  @Param quantity: number = 0;
  // 全选的回调事件
  @Event onSelectAll: () => void = () => {
  };
  // 删除事件
  @Event onDelete: () => void = () => {
  };
  // 结算
  @Event onCheckout: () => void = () => {
  };
  @Local visible: boolean = false;
  @Local popupMaskHeight: Length = '';

  build() {
    Column() {
      Row() {
        Row() {
          CheckboxGroup({ group: 'checkboxGroup' })
            .selectedColor('#FFE64566')
            .checkboxShape(CheckBoxShape.CIRCLE)
            .onChange((event: CheckboxGroupResult) => {
              this.visible = false;
              this.onSelectAll && this.onSelectAll();
            })
          Text('全选')
            .fontColor($r('sys.color.mask_secondary'))
            .fontSize(13)
            .baselineOffset(-1)
            .margin({ left: 8, right: 8 })
        }

        Row() {
          if (this.isEdit) {
            // 删除
            this.DeleteBtn();
          } else {
            // 总价大于0，需要展示明细
            if (this.totalPrice > 0) {
              this.TotalCostDetailView();
            } else {
              this.TotalView();
            }
            // 结算按钮
            this.CheckoutBtn();
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height(60)
      .borderWidth(this.isChildRoute ? { top: 0.1 } : {})
      .borderColor('#30000000')
      .backgroundColor(Color.White)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16 })

      PopupSheet({
        visible: this.visible!!,
        cornerRadius: 12,
        maskHeight: this.popupMaskHeight,
        customContentBuilder: () => {
          this.PopupContentBuilder();
        },
        title: '金额明细',
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .backgroundColor(Color.White)
    .onAreaChange((ov, nv) => {
      if (nv.globalPosition.y) {
        this.popupMaskHeight = nv.globalPosition.y;
      }
    })
  }

  @Builder
  DeleteBtn() {
    Button('删除')
      .width(80)
      .backgroundColor($r('app.color.theme_color'))
      .margin({ left: 16 })
      .onClick(() => {
        CommonConfirmDialog.show({
          content: '确认删除选中的商品吗？',
          confirm: () => {
            this.onDelete();
          },
        })
      })
  }

  @Builder
  TotalView() {
    Row() {
      Text('合计: ')
        .fontSize(12)
        .fontColor('#E6000000')
      Text('¥')
        .fontSize(12)
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
      Text(this.totalPrice.toString())
        .fontSize(16)
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
    }
    .justifyContent(FlexAlign.End)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  TotalCostDetailView() {
    Column({ space: 4 }) {
      Row() {
        Text(`已选${this.quantity}件, `).fontSize(12).fontColor('#959496')
        this.TotalView();
      }
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)

      Row() {
        if (this.discountAmount) {
          Text() {
            Span('共减 ¥')
            Span(this.discountAmount.toString())
          }
          .fontSize(10).fontColor($r('app.color.theme_color'))
          .margin({ right: 8 })
        }
        Text('查看明细').fontSize(10).fontColor($r('app.color.theme_color')).margin({ right: 2 })
        Image($r('app.media.ic_left_arrow'))
          .height(12)
          .objectFit(ImageFit.Contain)
          .rotate({ angle: 90 })
          .fillColor($r('app.color.theme_color'))
          .draggable(false)
      }
      .onClick(() => {
        this.visible = !this.visible;
      })
    }
    .alignItems(HorizontalAlign.End)
  }

  @Builder
  CheckoutBtn() {
    Button() {
      Text('结算')
        .fontSize(13)
        .fontColor(Color.White)
        .fontWeight(500)
    }
    .width(80)
    .height(32)
    .type(ButtonType.Normal)
    .backgroundColor('#FFE64566')
    .borderRadius(21)
    .margin({ left: 16 })
    .onClick(() => {
      this.onCheckout && this.onCheckout();
    })
  }

  @Builder
  PopupContentBuilder() {
    Column({ space: 14 }) {
      this.PopupContentItem('商品金额', this.totalPrice + (this.discountAmount || 0));
      // 是否有优惠
      if (this.discountAmount) {
        this.PopupContentItem('活动优惠', this.discountAmount);
      }
      // 合计
      Row() {
        Text('合计')
          .fontSize(16)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)

        Text() {
          Span('¥').fontSize(12)
          Span(this.totalPrice.toString())
            .fontSize(16)
        }
        .fontColor($r('app.color.theme_color'))
        .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.white'))
  }

  @Builder
  PopupContentItem(label: string, value: number) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .fontWeight(FontWeight.Regular)

      Text(`¥${value}`)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}