import { FormatUtil } from 'commonlib';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@ComponentV2
export struct MealOrderDetail {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    Column({ space: 12 }) {
      this.mealInfoCardBuilder();
      this.usageRuleCardBuilder();
      this.orderInfoBuilder();
    }
  }

  @Builder
  mealInfoCardBuilder() {
    if (this.vm.mealOrderItem) {
      Column({ space: 16 }) {
        Row() {
          Image(FormatUtil.getImgResource(this.vm.mealOrderItem.images))
            .height($r('app.string.height_percent_full'))
            .aspectRatio(4 / 3)
            .objectFit(ImageFit.Cover)
            .borderRadius($r('app.string.border_radius_16'))
            .margin({ right: $r('app.string.margin_s') })

          Column({ space: 8 }) {
            Row() {
              Text(this.vm.mealOrderItem.packageName)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.font_color_level1'))
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('70%')
              Text(`¥${this.vm.mealOrderItem.actualPaidPrice}`)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.font_color_level1'))
                .width('30%')
                .textAlign(TextAlign.End)
            }
            .width($r('app.string.width_percent_full'))
            .alignItems(VerticalAlign.Top)
            .justifyContent(FlexAlign.SpaceBetween)

            Text(`×${this.vm.mealOrderItem.totalCount}`)
              .fontColor($r('app.color.font_color_level2'))
              .fontSize($r('app.string.font_size_16'));
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .height(80)
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.Start)

        if (this.vm.mealOrderItem.status === '2') {
          this.formItemBuilder('券码', this.vm.mealOrderItem.orderNo)
          Row() {
            QRCode(this.vm.mealOrderItem.orderNo)
              .width(100)
              .height(100)
          }
          .width($r('app.string.width_percent_full'))
          .justifyContent(FlexAlign.Center)
        }
      }
      .commonContainerStyle()
    }
  }

  @Builder
  usageRuleCardBuilder() {
    if (this.vm.mealOrderItem) {
      Column({ space: 16 }) {
        Text('使用须知')
          .fontColor($r('app.color.font_color_level1'))
        Text(this.vm.mealOrderItem.usageRule)
          .fontColor($r('app.color.font_color_level2'))
          .fontSize($r('app.string.font_size_14'))
          .lineHeight(21)
      }
      .commonContainerStyle()
    }
  }

  @Builder
  orderInfoBuilder() {
    if (this.vm.mealOrderItem) {
      Column({ space: 16 }) {
        this.formItemBuilder('支付方式', '华为支付')
        this.formItemBuilder('订单编号', this.vm.mealOrderItem.orderNo)
        this.formItemBuilder('下单时间', this.vm.mealOrderItem.updateTime)
        this.formItemBuilder('总价', `¥${this.vm.mealOrderItem.actualPaidPrice}`)
      }
      .commonContainerStyle()
    }
  }

  @Builder
  formItemBuilder(label: string, content: string) {
    Row() {
      Text(label).labelTextStyle()
      Text(content).detailTextStyle()
    }
    .width($r('app.string.width_percent_full'))
  }
}

@Extend(Text)
function labelTextStyle() {
  .fontColor($r('app.color.font_color_level2'))
  .fontSize($r('app.string.font_size_14'))
  .layoutWeight(1)
}

@Extend(Text)
function detailTextStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level1'))
}

@Extend(Column)
function commonContainerStyle() {
  .alignItems(HorizontalAlign.Start)
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}