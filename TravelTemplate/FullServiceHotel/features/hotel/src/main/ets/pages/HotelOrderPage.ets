import { CommonButton } from 'componentlib';
import { HotelOrderPageVM } from '../viewmodels/HotelOrderPageVM';

@Builder
export function hotelOrderPageBuilder() {
  HotelOrderPage();
}

@ComponentV2
export default struct HotelOrderPage {
  vm: HotelOrderPageVM = HotelOrderPageVM.instance;

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          this.roomInfoBuilder();
          this.orderInfoBuilder();
        }
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
        bottom: $r('app.string.padding_l'),
      })

      this.paymentPanelBuilder();
    }
    .title(this.vm.pageTitle)
    .backgroundColor($r('app.color.background_color_grey'));
  }

  @Builder
  roomInfoBuilder() {
    Column({ space: 12 }) {
      Text('房间信息').cardTitleStyle()
      Row() {
        Text(this.vm.checkInData.checkInDateLabel)
          .labelStyle()
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.checkInData.checkInDateDescription)
          .contentStyle();
        Text('⇀')
          .fontSize(14)
          .fontColor('#FF191919')
          .margin({ left: 7, right: 7 })
          .fontWeight(700);
        Text(this.vm.checkInData.checkOutDateLabel)
          .labelStyle()
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.checkInData.checkOutDateDescription)
          .contentStyle();
        Blank()
        Text('共' + this.vm.checkInData.totalDays + '晚')
          .contentStyle()
      }
      .width($r('app.string.width_percent_full'))

      Divider().color($r('app.color.divider_color'))
      Row() {
        ForEach(this.vm.checkInData.roomTag, (item: string, index: number) => {
          if (index > 0) {
            Text('·')
              .labelStyle()
              .margin({
                left: $r('app.string.margin_xs'),
                right: $r('app.string.margin_xs'),
              });
          }
          Text(item)
            .labelStyle();
        }, (item: string, index: number) => JSON.stringify(item + index));
      };
    }
    .commonContainerStyle();
  }

  @Builder
  orderInfoBuilder() {
    Column({ space: 12 }) {
      Text('入住信息')
        .cardTitleStyle()
      this.roomCountInfoBuilder();
      Divider().color($r('app.color.divider_color'))
      this.nameInfoBuilder();
      Divider().color($r('app.color.divider_color'))
      this.phoneNumberInfoBuilder();
    }
    .commonContainerStyle();
  }

  @Builder
  roomCountInfoBuilder() {
    Row() {
      Text('房间数')
        .labelStyle()
        .width('20%');
      Blank()
      Text(this.vm.checkInData.roomCount + '间')
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .textAlign(TextAlign.End)
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  nameInfoBuilder() {
    Row() {
      Text('入住人')
        .labelStyle()
        .width('20%');
      TextInput({ text: this.vm.checkInData.guestName, placeholder: '请输入住客姓名' })
        .formInputStyle()
        .onChange((value: string) => {
          this.vm.checkInData.guestName = value;
        });
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  phoneNumberInfoBuilder() {
    Row() {
      Text('手机号')
        .labelStyle()
        .width('20%');
      TextInput({ text: this.vm.checkInData.guestPhone, placeholder: '请输入手机号' })
        .formInputStyle()
        .maxLength(11)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.vm.checkInData.guestPhone = value;
        });
    }
    .width($r('app.string.width_percent_full'));
  }

  @Builder
  paymentPanelBuilder() {
    Row() {
      Text() {
        Span('总额').fontColor($r('app.color.font_color_level2'))
        Span(' ').letterSpacing(4)
        Span('¥')
        Span(this.vm.checkInData.actualPaidPrice)
          .fontSize($r('app.string.font_size_20'));
      }
      .fontSize($r('app.string.font_size_14'))
      .fontColor($r('app.color.highlight_color'));

      Blank()

      CommonButton({
        title: '立即支付',
        fullWidth: false,
        handleClick: () => {
          this.vm.prepayRoom();
        },
      });
    }
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.background_color_white'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.string.padding_l'),
      right: $r('app.string.padding_l'),
      top: $r('app.string.padding_l'),
    });
  }
}

@Extend(Text)
function cardTitleStyle() {
  .fontSize($r('app.string.font_size_18'))
  .fontWeight(FontWeight.Medium)
  .lineHeight(24)
  .fontColor($r('app.color.font_color_level1'));
}


@Extend(Text)
function labelStyle() {
  .fontSize($r('app.string.font_size_16'))
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function contentStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level2'));
}

@Extend(TextInput)
function formInputStyle() {
  .type(InputType.Normal)
  .placeholderFont({ size: $r('app.string.font_size_14') })
  .fontSize($r('app.string.font_size_14'))
  .placeholderColor($r('app.color.font_color_level3'))
  .caretColor($r('app.color.theme_color'))
  .fontColor($r('app.color.font_color_level1'))
  .backgroundColor($r('app.color.background_color_white'))
  .textAlign(TextAlign.End)
  .layoutWeight(1)
  .borderRadius(0)
  .padding(0)
  .margin(0);
}

@Extend(Column)
function commonContainerStyle() {
  .alignItems(HorizontalAlign.Start)
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}