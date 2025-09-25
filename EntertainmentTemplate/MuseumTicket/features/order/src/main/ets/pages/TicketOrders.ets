import { AlertDialog, LengthMetrics } from '@kit.ArkUI';
import { RouterMap, RouterModule, CommonConstants, TitleBuilder } from 'commonlib';
import { TicketOrdersVM } from '../viewModels/TicketOrdersVM';
import { OrderClass, OrderTabListItem, OrderInfo } from '../types/Index';


@Builder
export function TicketOrdersBuilder() {
  TicketOrders();
}


@ComponentV2
struct TicketOrders {
  vm: TicketOrdersVM = TicketOrdersVM.instance;
  private controller: TabsController = new TabsController();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: this.vm.currentIndex === 0 ? '确定要取消预定吗？' : '确定要取消订单吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.controller.changeIndex(parseInt(OrderClass.INVALIDATION) - 1);
          this.vm.cancelOrder(this.vm.targetOrderNo);
        },
      },
    }),
  });

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.vm.selectedIndex === index ? '#603C00' : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.vm.selectedIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .height(19)
        .margin({ bottom: 6, top: 18 });
      Row()
        .height(2)
        .backgroundColor('#603C00')
        .opacity(this.vm.selectedIndex === index ? 1 : 0)
        .width(36);
    }.width('100%').height(60);
  }

  @Builder
  orderItemBuilder(item: OrderInfo) {
    Column() {
      Row() {
        Stack() {
          Image(this.vm.getFlag(item.status)).width('100%').height('100%');
          Text(this.vm.getLabel(item.status))
            .commonTagStyle()
            .margin({ right: 12 });
        }.width(72)
        .height(24)
        .alignContent(Alignment.End);
      }.padding({ top: 15 }).width('100%').justifyContent(FlexAlign.End);

      Column({ space: 12 }) {
        Row() {
          Text('展览名称:').commonLabelStyle();
          Text(item.performanceName).commonValueStyle();
        };


        Divider();
        Row() {
          Text('参观时间:').commonLabelStyle();
          Text(item.visitTime).commonValueStyle();
        };

        Divider();
        Row() {
          Text('参观人:').commonLabelStyle();
          Text(item.visitor + '人').commonValueStyle();
        };

        Divider();
        if (this.vm.currentIndex !== 4) {
          Row() {
            Text('预约时间:').commonLabelStyle();
            Text(item.orderTime).commonValueStyle();
          };

          if ((this.vm.currentIndex !== 2 && this.vm.currentIndex !== 3) || (item.actualPay || item.orderAmount)) {
            Divider();
          }
        }
        if (this.vm.currentIndex === 4 && item.cancelTime) {
          Row() {
            Text('取消时间:').commonLabelStyle();
            Text(item.cancelTime).commonValueStyle();
          };
        }

        if ((this.vm.currentIndex === 0 || this.vm.currentIndex === 2) && item.actualPay) {
          Row() {
            Text('实付款:').commonLabelStyle();
            Text('¥' + item.actualPay.toString()).commonValueStyle();
          };


          if (this.vm.currentIndex !== 2) {
            Divider();
          }


        }
        if ((this.vm.currentIndex === 1 || this.vm.currentIndex === 3) && item.orderAmount) {
          Row() {
            Text('订单金额:').commonLabelStyle();
            Text('¥' + item.orderAmount.toString()).commonValueStyle();
          };

          if (this.vm.currentIndex !== 3) {
            Divider();
          }
        }
        if (this.vm.currentIndex === 0) {
          Row() {
            Button('取消预定')
              .commonBtnExtend()
              .onClick(() => {
                this.vm.targetOrderNo = item.orderNo;
                this.dialogControllerConfirm.open();
              });
          }.justifyContent(FlexAlign.End).width('100%');
        }
        if (this.vm.currentIndex === 1) {
          Row() {
            Button('取消')
              .fontWeight(500)
              .width(64)
              .height(28)
              .backgroundColor('#0C000000')
              .fontSize($r('sys.float.Body_S'))
              .padding(0)
              .hitTestBehavior(HitTestMode.Block)
              .fontColor($r('sys.color.font_primary'))
              .onClick(() => {
                this.vm.targetOrderNo = item.orderNo;
                this.dialogControllerConfirm.open();
              })
              .margin({ right: 12 });
            Button('前往支付')
              .commonBtnExtend()
              .onClick(() => {
                this.vm.toPay(item.orderNo,item.orderStr ?? '');
              });
          }.justifyContent(FlexAlign.End).width('100%');
        }
      }.padding(12);

    }
    .alignItems(HorizontalAlign.Start)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      RouterModule.push({ url: RouterMap.TICKET_DETAIL, param: { orderNo: item.orderNo } });
    });
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
          ForEach(this.vm.orderTabList, (item: OrderTabListItem, index) => {
            TabContent() {
              if (this.vm.isLoading) {
                LoadingProgress().width(40);
              } else {
                if (this.vm.orderTabList.length) {
                  Scroll() {
                    Column({ space: 10 }) {
                      ForEach(this.vm.orderList, (item: OrderInfo, index) => {
                        this.orderItemBuilder(item);
                      }, (item: OrderInfo, index) => item.orderNo);
                      if (this.vm.orderList.length === 0) {
                        Row() {
                          Divider().width(40);
                          Text('没有更多了').fontColor($r('sys.color.font_tertiary')).fontSize(14);
                          Divider().width(40);
                        }.margin({ top: 15 });
                      }

                    }.width('100%').constraintSize({
                      minHeight: '100%',
                    }).padding({ left: 16, right: 16 });
                  }.scrollBar(BarState.Off)
                  .edgeEffect(EdgeEffect.Spring)
                  .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden);
                } else {
                  Text('暂无数据').fontSize(CommonConstants.FONT_SIZE_M);
                }
              }

            }.tabBar(this.tabBuilder(index, item.label));
          }, (item: OrderTabListItem, index) => item.label);
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barHeight(60)
        .animationDuration(400)
        .onChange((index: number) => {
          // currentIndex控制TabContent显示页签
          this.vm.currentIndex = index;
          this.vm.selectedIndex = index;
          this.vm.getOrderList();
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return;
          }
          // selectedIndex控制自定义TabBar内Image和Text颜色切换
          this.vm.selectedIndex = targetIndex;
        });

      }.width('100%');
    }.title(TitleBuilder('门票订单'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5')
    .onShown(() => {
      this.vm.initData();
    });

  }
}


@Extend(Button)
function commonBtnExtend() {
  .fontWeight(500)
  .width(64)
  .height(28)
  .backgroundColor('#D1B380')
  .fontColor($r('sys.color.font_on_primary'))
  .fontSize($r('sys.float.Body_S'))
  .padding(0)
  .hitTestBehavior(HitTestMode.Block);
}

@Extend(Text)
function commonTagStyle() {
  .fontSize($r('sys.float.Body_M'))
  .fontColor($r('sys.color.font_on_primary'))
  .fontWeight(FontWeight.Medium);

}

@Extend(Text)
function commonValueStyle() {
  .fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Body_M')).layoutWeight(1).textAlign(TextAlign.End);
}

@Extend(Text)
function commonLabelStyle() {
  .fontColor($r('sys.color.font_primary')).fontSize($r('sys.float.Body_M'));
}
