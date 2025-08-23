import { LengthMetrics, AlertDialog } from '@kit.ArkUI';
import { FormatUtil, RouterMap, RouterModule, TitleBuilder } from 'commonlib';
import { ActiveOrder } from 'network';
import { ACTIVE_LABEL_MAP, FLAG_MAP } from '../constants/Constants';
import { OrderStatus } from '../types/Index';
import { ActiveOrdersVM } from '../viewModels/ActiveOrdersVM';


@Builder
export function ActiveOrdersBuilder() {
  ActiveOrders();
}


@ComponentV2
struct ActiveOrders {
  vm: ActiveOrdersVM = ActiveOrdersVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要取消订单吗？',
      primaryButton: {
        value: '取消',
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.cancelActiveOrder();
        },
      },
    }),
  });
  private controller: TabsController = new TabsController();

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.vm.selectedIndex === index ? '#603C00' : $r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(this.vm.selectedIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .height(19)
        .margin({ bottom: 6, top: 18 });
      Divider()
        .strokeWidth(2)
        .color('#603C00')
        .opacity(this.vm.selectedIndex === index ? 1 : 0)
        .width(36);
    }.width('100%').height(60);
  }

  build() {
    NavDestination() {
      Column() {
        Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
          ForEach(this.vm.tabList, (item: string, index) => {
            TabContent() {
              if (this.vm.isLoading) {
                LoadingProgress().width(40);
              } else {
                List({ space: 12 }) {
                  if (this.vm.orders.length === 0) {
                    ListItem() {
                      Row() {
                        Divider().strokeWidth(1).width(40);
                        Text('没有更多了').fontColor($r('sys.color.font_tertiary')).fontSize(14);
                        Divider().strokeWidth(1).width(40);
                      }.margin({ top: 15 }).width('100%').justifyContent(FlexAlign.Center);
                    };
                  }
                  ForEach(this.vm.orders, (val: ActiveOrder, i) => {
                    ListItem() {
                      Column() {
                        Row() {
                          Stack() {
                            Image(FLAG_MAP.get(val.status)).width('100%').height('100%');
                            Text(ACTIVE_LABEL_MAP.get(val.status))
                              .margin({ right: 11 })
                              .fontSize($r('sys.float.Body_M'))
                              .fontWeight(FontWeight.Medium)
                              .fontColor($r('sys.color.font_on_primary'));
                          }.width(73).height(24).alignContent(Alignment.End);
                        }.width('100%').padding({ top: 15 }).justifyContent(FlexAlign.End);

                        Column({ space: 12 }) {
                          Row() {
                            Text('活动名称').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                            Text(val.title).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                          Divider().strokeWidth(0.5);

                          Row() {
                            Text('活动时间').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                            Text(val.activeTime)
                              .fontSize($r('sys.float.Body_M'))
                              .fontColor($r('sys.color.font_primary'));
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                          Divider().strokeWidth(0.5);

                          Row() {
                            Text('联系人').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                            Text(val.contactName)
                              .fontSize($r('sys.float.Body_M'))
                              .fontColor($r('sys.color.font_primary'));
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                          Divider().strokeWidth(0.5);

                          Row() {
                            Text('参观人').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                            Text(val.visitors.map((item) => item.name).join('、'))
                              .fontSize($r('sys.float.Body_M'))
                              .fontColor($r('sys.color.font_primary'));
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                          Divider().strokeWidth(0.5);

                          Row() {
                            Text('预约时间').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
                            Text(FormatUtil.formatFullDate(new Date(val.orderTime), true))
                              .fontSize($r('sys.float.Body_M'))
                              .fontColor($r('sys.color.font_primary'));
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                          if (val.status === OrderStatus.PENDING_PAY || val.status === OrderStatus.PENDING_USE) {
                            Divider().strokeWidth(0.5);
                          }
                          if (val.status === OrderStatus.PENDING_PAY) {
                            Row() {
                              Button('前往支付').commonBtnExtend().onClick(() => {
                                this.vm.toPayOrder(val);
                              });
                            }.width('100%').justifyContent(FlexAlign.End);
                          }

                          if (val.status === OrderStatus.PENDING_USE) {
                            Row() {
                              Button('取消活动').commonBtnExtend().onClick(() => {
                                this.vm.delNo = val.orderNo;
                                this.dialogControllerConfirm.open();
                              });
                            }.width('100%').justifyContent(FlexAlign.End);
                          }

                        }.padding(12);
                      }.borderRadius(16).backgroundColor('#FFFFFF');
                    }.onClick(() => {
                      RouterModule.push({ url: RouterMap.ACTIVE_ORDER_DETAIL, param: val });
                    });
                  }, (val: ActiveOrder) => val.orderNo);
                }
                .padding({ bottom: 10 })
                .scrollBar(BarState.Off)
                .height('100%')
                .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden);
              }
            }.tabBar(this.tabBuilder(index, item));
          }, (item: string) => item);
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barHeight(60)
        .animationDuration(400)
        .onChange((index: number) => {
          this.vm.currentIndex = index;
          this.vm.selectedIndex = index;
          this.vm.getActiveOrders();
        })
        .onAnimationStart((index: number, targetIndex: number) => {
          if (index === targetIndex) {
            return;
          }
          this.vm.selectedIndex = targetIndex;
        });

      }.width('100%').padding({ left: 16, right: 16 });

    }
    .backgroundColor('#F3F4F5')
    .title(TitleBuilder('活动订单'), { paddingStart: LengthMetrics.vp(16) })
    .onShown(() => {
      this.vm.getActiveOrders();
    });

  }
}


@Extend(Button)
function commonBtnExtend() {
  .width(64)
  .height(28)
  .backgroundColor('#D1B380')
  .fontSize(12)
  .fontColor($r('sys.color.font_on_primary'))
  .fontWeight(500)
  .padding(0)
  .hitTestBehavior(HitTestMode.Block);
}
