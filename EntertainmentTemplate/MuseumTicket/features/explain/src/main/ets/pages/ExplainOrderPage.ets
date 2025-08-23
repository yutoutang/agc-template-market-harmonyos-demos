import { LengthMetrics, AlertDialog, promptAction } from '@kit.ArkUI';
import { TitleBuilder, RouterModule, FormatUtil } from 'commonlib';
import { PersonManage, SelectMode, Contact } from 'module_person_manage';
import { ExplainOrderPageVM } from '../viewModels/ExplainOrderPageVM';

@Builder
export function ExplainOrderPageBuilder() {
  ExplainOrderPage();
}


@ComponentV2
struct ExplainOrderPage {
  vm: ExplainOrderPageVM = ExplainOrderPageVM.instance;
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: '确定要删除该参观人吗？',
      primaryButton: {
        value: '取消',
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.vm.removeVisitor();
        },
      },
    }),
  });

  aboutToAppear(): void {
    this.vm.visitors = [];
    this.vm.disableId = []
    this.vm.getExplainDetail();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          if (this.vm.details) {
            Row({ space: 12 }) {
              Image(this.vm.details.cover).width(88).height(114).borderRadius(8);
              Column({ space: 12 }) {
                Text(this.vm.details.title).commonTextExtend();
                Text(`${FormatUtil.dateAsISOCN(new Date(this.vm.details.time))} ${this.vm.details.timeSegment}`)
                  .commonTextExtend();
                Text(this.vm.details.name).commonTextExtend();
                Row() {
                  Text(this.vm.details.language).commonTextExtend();
                  Text(`¥${this.vm.details.price}/人`)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.multi_color_08'));
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);
              }.layoutWeight(1).padding({ top: 3 }).alignItems(HorizontalAlign.Start);
            }.commonWrapperExtend();
          }


          Row() {
            Text('请添加参与活动的人员').commonTextExtend();
            PersonManage({
              navPathStack: RouterModule.getStack(),
              selectMode: SelectMode.MORE_SELECT,
              disableId:this.vm.disableId,
              onSelect: (data) => {
                this.vm.handleVisitors(data as Contact[]);
              },
              onBeforeNavigate: () => {
                return true;
              },
            }) {
              Button() {
                Row({ space: 4 }) {
                  Image($r('app.media.contact_add')).width(16).height(16);
                  Text('添加预约人').fontSize(12).fontColor('#FFFFFF').fontWeight(500);
                };
              }.width(96).height(28).backgroundColor('#D1B380');
            };

          }
          .padding(12)
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .borderRadius(16)
          .backgroundColor('#FFFFFF');


          ForEach(this.vm.visitors, (item: Contact, index: number) => {
            Column() {
              Row() {
                Row({ space: 4 }) {
                  Image($r('app.media.contact_person')).width(24).height(24);
                  Text(`参观人${index + 1}`)
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.Body_M'))
                    .fontColor($r('sys.color.font_primary'));
                };

                Image($r('app.media.contact_delete')).width(24).height(24).onClick(() => {
                  this.vm.delPersonId = item.personID;
                  this.dialogControllerConfirm.open();
                });
              }.padding(12).width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider().width('100%');

              Column({ space: 12 }) {
                Row() {
                  Text('姓名').commonTextExtend();
                  Text(item.name).commonTextExtend();
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().width('100%');
                Row() {
                  Text('证件类型').commonTextExtend();
                  Text(item.cardType).commonTextExtend();
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().width('100%');
                Row() {
                  Text('证件号').commonTextExtend();
                  Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14)).commonTextExtend();
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().width('100%');
                Row() {
                  Text('联系方式').commonTextExtend();
                  Text(item.phone).commonTextExtend();
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              }.padding(12).width('100%');

            }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);
          }, (item: Contact) => JSON.stringify(item));

          if (this.vm.visitors.length) {
            Column() {
              Row({ space: 4 }) {
                Image($r('app.media.active_money')).width(24).height(24);
                Text('费用明细')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'));
              }.padding(12).width('100%');

              Divider().width('100%');
              Column({ space: 12 }) {
                Row() {
                  Text(`讲解费x${this.vm.visitors.length}`).commonTextExtend();
                  if (this.vm.details) {
                    Text(`¥${this.vm.visitors.length * this.vm.details.price}`)
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_tertiary'));
                  }

                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Row() {
                  Text(`耳机押金x${this.vm.visitors.length}`).commonTextExtend();
                  if (this.vm.details) {
                    Text(`¥${this.vm.visitors.length * this.vm.details.headsetPrice}`)
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_tertiary'));
                  }

                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              }.padding(12).width('100%');

            }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);
          }


        }.padding({ bottom: 10 });

      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Top)
      .padding({ left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

      Row() {
        Row({ space: 12 }) {
          Text('共需支付')
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'));
          if (this.vm.details) {
            Text(`¥${this.vm.visitors.length * (this.vm.details.headsetPrice + this.vm.details.price)}`)
              .fontColor('#D1B380')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Bold);
          }

        }.layoutWeight(1);

        Button('确定')
          .width(164)
          .height(40)
          .backgroundColor('#D1B380')
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.background_primary'))
          .onClick(() => {
            if (this.vm.visitors.length) {
              this.vm.preOrderExplain();
            } else {
              promptAction.showToast({ message: '请至少选择1位参观人！' });
            }
          });

      }.width('100%').height(64).backgroundColor('#FFFFFF').padding({ left: 12, right: 16 });
    }
    .title(TitleBuilder('预约'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor($r('sys.color.background_secondary'));

  }
}


@Extend(Row)
function commonWrapperExtend() {
  .padding(12).borderRadius(16).backgroundColor('#FFFFFF');
}

@Extend(Text)
function commonTextExtend() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Regular);
}

