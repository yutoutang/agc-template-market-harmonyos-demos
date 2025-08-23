import { CheckInItem } from '../types';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@ComponentV2
export struct HotelOrderDetail {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    Column({ space: 12 }) {
      this.hotelInfoCardBuilder();
      this.checkInInfoCardBuilder();
    }
  }

  @Builder
  hotelInfoCardBuilder() {
    if (this.vm.hotelOrderItem) {
      Column({ space: 16 }) {
        Text(this.vm.hotelOrderItem.hotelName)

        Row() {
          Image(this.vm.hotelOrderItem.cover)
            .height($r('app.string.height_percent_full'))
            .aspectRatio(4 / 3)
            .objectFit(ImageFit.Cover)
            .borderRadius($r('app.string.border_radius_16'))
            .margin({ right: $r('app.string.margin_s') })
          Column({ space: 8 }) {
            Row() {
              Text(this.vm.hotelOrderItem.roomName)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.font_color_level1'))
              Text(`¥${this.vm.hotelOrderItem.actualPaidPrice}`)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.font_color_level1'))
            }
            .width($r('app.string.width_percent_full'))
            .justifyContent(FlexAlign.SpaceBetween)

            Text(`${this.vm.hotelOrderItem.nights}晚 ${this.vm.hotelOrderItem.rmQty}间`)
              .labelTextStyle()
              .fontSize($r('app.string.font_size_12'))
            Text(`${this.vm.hotelOrderItem.arrDate} 至 ${this.vm.hotelOrderItem.depDate}`)
              .labelTextStyle()
              .fontSize($r('app.string.font_size_12'))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .height(80)
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.Start)

        Column({ space: 16 }) {
          this.formItemBuilder('支付方式', this.vm.hotelOrderItem.payMethod)
          this.formItemBuilder('订单编号', this.vm.hotelOrderItem.orderNo)
          this.formItemBuilder('下单时间', this.vm.hotelOrderItem.createTime)
          this.formItemBuilder('总价', this.vm.hotelOrderItem.actualPaidPrice)
        }
        .width($r('app.string.width_percent_full'))
      }
      .commonContainerStyle()
    }
  }

  @Builder
  checkInInfoCardBuilder() {
    if (this.vm.hotelOrderItem) {
      Column() {
        Text('入住人信息')
          .fontColor($r('app.color.font_color_level1'))
          .margin({bottom:$r('app.string.margin_l')})

        ForEach(this.vm.hotelOrderItem.checkInList, (item: CheckInItem) => {
          Column({ space: 16 }) {
            this.formItemBuilder('入住人', item.checkInName)
            this.formItemBuilder('联系电话', item.checkInTel)
          }
          .width($r('app.string.width_percent_full'))
        }, (item: CheckInItem) => JSON.stringify(item))
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