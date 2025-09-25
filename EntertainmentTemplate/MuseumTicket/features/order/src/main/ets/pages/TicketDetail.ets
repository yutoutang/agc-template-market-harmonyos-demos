import { AlertDialog, LengthMetrics } from '@kit.ArkUI';
import { TicketOwner } from 'network';
import { CommonConstants, TitleBuilder } from 'commonlib';
import { NoticeBar } from '../components/NoticeBar';
import { DetailHeader } from '../components/DetailHeader';
import { TicketOrdersVM } from '../viewModels/TicketOrdersVM';
import { OrderClass } from '../types/Index';


@Builder
export function TicketDetailBuilder() {
  TicketDetail();
}


@ComponentV2
struct TicketDetail {
  vm: TicketOrdersVM = TicketOrdersVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要取消订单吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.cancelOrderInDetail(this.vm.orderDetail!.orderNo);
        },
      },
    }),
  });

  aboutToAppear(): void {
    this.vm.getOrderDetail();
  }

  build() {
    NavDestination() {
      if (this.vm.isLoading) {
        LoadingProgress().width(40);
      } else {
        Scroll() {
          Column({ space: 12 }) {
            DetailHeader({
              icon: this.vm.getIcon(this.vm.orderDetail?.status ?? ''),
              label: this.vm.getLabel(this.vm.orderDetail?.status ?? ''),
              visitTime: this.vm.orderDetail?.visitTime,
              name: this.vm.orderDetail?.performanceName,
            });

            NoticeBar({
              noticeText: this.vm.orderDetail?.notice,
            });
            Column({ space: 12 }) {
              if (!this.vm.orderDetail?.isFree) {
                this.ticketOwnerBuilder();
              }
              this.orderInfoBuilder();
            }.padding(12).backgroundColor('#FFFFFF').borderRadius(16);

          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 10,
            bottom: 10,
          })
          .backgroundColor('#F0F0F0')
          .constraintSize({ minHeight: CommonConstants.FULL_HEIGHT });
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .height(this.vm.orderDetail && this.vm.orderDetail.status === OrderClass.PENDING_PAYMENT ? 'calc(100% - 65vp)' :
        CommonConstants.FULL_HEIGHT);

        if (this.vm.orderDetail && this.vm.orderDetail.status === OrderClass.PENDING_PAYMENT) {
          Row() {
            Button('取消')
              .fontWeight(500)
              .width(72)
              .height(28)
              .margin({ right: 10 })
              .backgroundColor('#0C000000')
              .fontSize(CommonConstants.FONT_SIZE_M)
              .padding(0)
              .fontColor(CommonConstants.FONT_COLOR_BLACK)
              .onClick(() => {
                this.dialogControllerConfirm.open();
              });
            Button('前往支付')
              .fontWeight(500)
              .width(72)
              .height(28)
              .backgroundColor('#D1B380')
              .fontSize(CommonConstants.FONT_SIZE_M)
              .padding(0)
              .onClick(() => {
                this.vm.toPay(this.vm.orderDetail?.orderNo ?? '', this.vm.orderDetail?.orderStr ?? '');
              });

          }
          .height(65)
          .width('100%')
          .backgroundColor(CommonConstants.BG_COLOR_WHITE)
          .justifyContent(FlexAlign.End)
          .padding(10);
        }
      }
    }.title(TitleBuilder(this.vm.navTitle), { paddingStart: LengthMetrics.vp(16) }).backgroundColor('#F3F4F5');
  }

  @Builder
  ticketOwnerBuilder() {
    Text('购票人信息').commonTitleStyle();
    Divider();
    Column() {
      Row() {
        Text('购票人:').ownerTextStyle().width(61);
        Column({ space: 12 }) {
          ForEach(this.vm.orderDetail?.ticketOwner, (item: TicketOwner) => {
            Row() {
              Text(item.name + `（${this.vm.ticketTypeMap.get(item.ticketType)}）`).ownerTextStyle().width(120);
              Text(`×${item.ticket}张`).ownerTextStyle().width(40);
              Text('¥' + item.price).ownerTextStyle().constraintSize({ minWidth: 20 }).textAlign(TextAlign.End);
            }.justifyContent(FlexAlign.SpaceBetween).width('100%');
          }, (item: TicketOwner) => item.personId);
          Divider();
          Row() {
            Text('合计').ownerTextStyle().width(120);
            Text(`×${this.vm.getTotal(this.vm.orderDetail?.ticketOwner).total}张`).ownerTextStyle().width(40);
            Text('¥' + this.vm.getTotal(this.vm.orderDetail?.ticketOwner).totalPrice)
              .ownerTextStyle()
              .constraintSize({ minWidth: 20 })
              .textAlign(TextAlign.End);
          }.justifyContent(FlexAlign.SpaceBetween).width('100%');
        }.width('calc(100% - 61vp)');
      }.alignItems(VerticalAlign.Top);

      Row() {
        Text('联系电话:').ownerTextStyle().width(61);
        Text(this.vm.orderDetail?.contactPhone).ownerTextStyle();
      }.margin({ top: 12 });
    }.alignItems(HorizontalAlign.Start).width('100%');

    Divider().margin({ bottom: 10 });
  }

  @Builder
  orderInfoBuilder() {
    Text('订单信息').commonTitleStyle();
    Column({ space: 12 }) {
      if (this.vm.orderDetail?.isFree) {
        this.visitorBuilder();
      } else {
        Row() {
          Text('下单时间：').commonTextStyle();
          Text(this.vm.orderDetail?.placeTime).commonTextStyle();
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        if (this.vm.orderDetail?.status !== OrderClass.PENDING_PAYMENT && this.vm.orderDetail?.payTime) {
          Divider();
          Row() {
            Text('付款时间：').commonTextStyle();
            Text(this.vm.orderDetail?.payTime).commonTextStyle();
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        }
        if (this.vm.orderDetail?.status !== OrderClass.PENDING_PAYMENT && this.vm.orderDetail?.actualPay) {
          Divider();
          Row() {
            Text('实付款：').commonTextStyle();
            Text(this.vm.orderDetail?.actualPay.toString()).commonTextStyle();
          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

        }
      }
      if (this.vm.orderDetail?.status === OrderClass.INVALIDATION) {
        Divider();
        Row() {
          Text('取消时间：').commonTextStyle();
          Text(this.vm.orderDetail?.cancelTime).commonTextStyle();
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);
      }

    }.alignItems(HorizontalAlign.Start).width('100%');
  }

  @Builder
  visitorBuilder() {
    Row() {
      Text('参观人：').commonTextStyle();
      Text(this.vm.orderDetail?.visitors?.map(item => item.name).join('、')).commonTextStyle();
    }.width('100%').justifyContent(FlexAlign.SpaceBetween);

    Divider();
    Row() {
      Text('参观人数：').commonTextStyle();
      Text(`${this.vm.orderDetail?.visitors?.length}人`).commonTextStyle();
    }.width('100%').justifyContent(FlexAlign.SpaceBetween);

    Divider();

    Row() {
      Text('联系电话：').commonTextStyle();
      Text(this.vm.orderDetail?.contactPhone).commonTextStyle();
    }.width('100%').justifyContent(FlexAlign.SpaceBetween);

    Divider();

    Row() {
      Text('预约时间：').commonTextStyle();
      Text(this.vm.orderDetail?.orderTime).commonTextStyle();
    }.width('100%').justifyContent(FlexAlign.SpaceBetween);

  }
}

@Extend(Text)
function commonTextStyle() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}


@Extend(Text)
function ownerTextStyle() {
  .fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
}

@Extend(Text)
function commonTitleStyle() {
  .fontSize($r('sys.float.Subtitle_M'))
  .height(21)
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_primary'))
  .width('100%');
}
