import { LengthMetrics } from '@kit.ArkUI';
import { RouterMap, RouterModule, FormatUtil, CommonConstants, TitleBuilder } from 'commonlib';
import { UICalendarPicker, TypePicker, DialogType, SwiperDirection } from 'module_calendar_picker';
import { DayTicketInfo, TicketStatus, TimeStatus } from '../types/Index';
import { OrderTicketVM } from '../viewModels/OrderTicketVM';


@Builder
export function OrderTicketBuilder() {
  OrderTicket();
}


@Entry
@ComponentV2
struct OrderTicket {
  vm: OrderTicketVM = OrderTicketVM.instance;

  aboutToAppear(): void {
    this.vm.initData();
    this.vm.getDayTicketInfo();
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Text('参观日期').margin({ bottom: 10 });
              Row({ space: this.vm.isSmallWidth ? 8 : 10 }) {
                ForEach(this.vm.dayList, (item: DayTicketInfo) => {
                  Column() {
                    Text(item.day)
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_body2'));
                    Text(FormatUtil.dateAsMD(item.date))
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                      .margin(2);
                    Text(item.statusCn)
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_caption'));
                  }
                  .checkBoxStyle()
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.vm.currentSelected?.date === item.date ?
                    '#D1B380' : '')
                  .opacity(item.status !== TicketStatus.HAVE ? $r('sys.float.ohos_id_alpha_disabled') : 1)
                  .enabled(item.status === TicketStatus.HAVE ? true : false)
                  .onClick(() => {
                    if (this.vm.currentSelected?.date !== item.date) {
                      this.vm.currentSelected = item;
                      this.vm.selectedTime = undefined;
                    }
                  });
                }, (item: DayTicketInfo, index: number) => item.date.toString());

                Column() {
                  UICalendarPicker({
                    type: TypePicker.SINGLE,
                    dialogType: DialogType.SHEET,
                    enableSelectTime: true,
                    customColor: '#D1B380',
                    swiperDirection: SwiperDirection.VERTICAL,
                    selected: this.vm.selected,
                    disabledDates: this.vm.disableData,
                    ableDates: this.vm.ableData,
                    customBuildPanel: (): void => {
                      this.customPanelBuilder();
                    },
                    onSelected: (res) => {
                      this.vm.selected = res as Date;
                      this.vm.getCurrentPickDay(res as Date);
                    },
                  });
                }.checkBoxStyle();

              }.margin({ bottom: 24 }).height(70);

              //  参观时间
              if (this.vm.currentSelected) {
                Text('参观时间').margin({ bottom: 10 });
                Row({ space: this.vm.isSmallWidth ? 8 : 10 }) {
                  Column() {
                    Text('上午')
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_body2'));
                    Text(this.vm.currentSelected.morningAmount > 0 ? '可约' : '约满')
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_caption'));
                  }
                  .checkBoxStyle()
                  .backgroundColor(this.vm.selectedTime === TimeStatus.MORNING ?
                    '#D1B380' : '')
                  .justifyContent(FlexAlign.Center)
                  .opacity(this.vm.currentSelected.morningAmount <= 0 ? $r('sys.float.ohos_id_alpha_disabled') : 1)
                  .enabled(this.vm.currentSelected.morningAmount > 0)
                  .onClick(() => {
                    this.vm.selectedTime = TimeStatus.MORNING;
                  });

                  Column() {
                    Text('下午')
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_body2'));
                    Text(this.vm.currentSelected.afternoonAmount > 0 ? '可订' : '约满')
                      .fontColor('#603C00')
                      .fontSize($r('sys.float.ohos_id_text_size_caption'));
                  }
                  .checkBoxStyle()
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.vm.selectedTime === TimeStatus.AFTERNOON ?
                    '#D1B380' : '')
                  .opacity(this.vm.currentSelected.afternoonAmount <= 0 ? $r('sys.float.ohos_id_alpha_disabled') : 1)
                  .enabled(this.vm.currentSelected.afternoonAmount > 0)
                  .onClick(() => {
                    this.vm.selectedTime = TimeStatus.AFTERNOON;
                  });
                }.margin({ bottom: 14 });
              }

            }
            .alignItems(HorizontalAlign.Start)
            .padding(10)
            .width('100%')
            .onSizeChange((oldVal, newVal: SizeOptions) => {
              const newWidth = newVal.width as number;
              if (newWidth >= CommonConstants.DESIGN_WIDTH){
                this.vm.isSmallWidth = false ;
              }else {
                this.vm.isSmallWidth = true ;
              }
            });
          }.backgroundColor($r('sys.color.ohos_id_color_background')).constraintSize({ minHeight: 270 });

        }.height('calc(100% - 75vp)').scrollBar(BarState.Off).align(Alignment.Top);


        Column() {
          Button('预约')
            .type(ButtonType.Normal)
            .borderRadius(20)
            .backgroundColor(this.vm.currentSelected !== undefined && this.vm.selectedTime !== undefined ?
              '#D1B380' : '#99D1B380')
            .width('calc(100% - 32vp)')
            .onClick(() => {
              RouterModule.push({ url: RouterMap.ORDER_INFO });
            })
            .enabled(this.vm.currentSelected !== undefined && this.vm.selectedTime !== undefined);
        }.height(75).backgroundColor(CommonConstants.BG_COLOR_GRAY).justifyContent(FlexAlign.Center);

      }
      .width('100%')
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .padding({ top: 10 });

    }.title(TitleBuilder('参观预约'), { paddingStart: LengthMetrics.vp(16) });
  }

  @Styles
  checkBoxStyle() {
    .borderRadius(4)
    .border({ width: 1, color: '#D1B380' })
    .height(70)
    .width(60);
  }

  @Builder
  customPanelBuilder() {
    Row() {
      Text('指定日期')
        .fontColor('#603C00')
        .width(28)
        .fontSize($r('sys.float.ohos_id_text_size_body2'));
      Image($r('app.media.icon_public_arrow_right')).width(12).fillColor('#603C00');
    }.height(70).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center).width(60);
  }
}
