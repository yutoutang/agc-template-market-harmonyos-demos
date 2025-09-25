import { LengthMetrics, AlertDialog } from '@kit.ArkUI';
import { TitleBuilder, RouterModule } from 'commonlib';
import { JoinActivePageVM } from '../viewModels/JoinActivePageVM';
import { Contact, PersonManage, SelectMode } from 'module_person_manage';


@Builder
export function JoinActivePageBuilder() {
  JoinActivePage();
}


@ComponentV2
struct JoinActivePage {
  vm: JoinActivePageVM = JoinActivePageVM.instance;
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
    this.vm.disableId = [];
    this.vm.contactName = '';
    this.vm.contactPhone = '';
    this.vm.getActiveInfo();
  }

  build() {
    NavDestination() {
      if (this.vm.activeInfo) {
        Scroll() {
          Column({ space: 12 }) {
            Column() {
              Row({ space: 4 }) {
                Image($r('app.media.contact_person')).width(24).height(24);
                Text('活动联系人').commonExtend();
              }.padding(12).width('100%');

              Divider().width('100%');

              Column({ space: 12 }) {
                Row() {
                  Text('姓名').subTextExtend();
                  TextInput({ placeholder: '请输入活动联系人姓名', text: this.vm.contactName })
                    .baseInputExtend()
                    .onChange((res) => {
                      this.vm.contactName = res;
                    });
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().width('100%');
                Row() {
                  Text('联系方式').subTextExtend();
                  TextInput({ placeholder: '请输入活动联系人联系方式', text: this.vm.contactPhone })
                    .baseInputExtend()
                    .onChange((res) => {
                      this.vm.contactPhone = res;
                    });
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              }.padding(12).width('100%');

            }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);

            Row() {
              Text('请添加参与活动的人员').subTextExtend();
              PersonManage({
                navPathStack: RouterModule.getStack(),
                selectMode: SelectMode.MORE_SELECT,
                disableId: this.vm.disableId,
                onSelect: (data) => {
                  this.vm.handleVisitors(data as Contact[]);
                },
                onBeforeNavigate: () => {
                  focusControl.requestFocus('focusBtn');
                  return true;
                },
              }) {
                Button() {
                  Row({ space: 4 }) {
                    SymbolGlyph($r('sys.symbol.plus')).fontColor([$r('sys.color.font_on_primary')]);
                    Text('添加预约人')
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor($r('sys.color.font_on_primary'))
                      .fontWeight(500);
                  };
                }.width(96).height(28).backgroundColor('#D1B380');
              };
            }
            .padding(12)
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .borderRadius(16)
            .backgroundColor('#FFFFFF')
            .id('focusBtn');

            ForEach(this.vm.visitors, (item: Contact, index: number) => {
              Column() {
                Row() {
                  Row({ space: 4 }) {
                    Image($r('app.media.contact_person')).width(24).height(24);
                    Text(`参观人${index + 1}`).commonExtend();
                  };

                  Image($r('app.media.contact_delete')).width(24).height(24).onClick(() => {
                    this.vm.delPersonId = item.personID;
                    this.dialogControllerConfirm.open();
                  });
                }.padding(12).width('100%').justifyContent(FlexAlign.SpaceBetween);

                Divider().width('100%');

                Column({ space: 12 }) {
                  Row() {
                    Text('姓名').subTextExtend();
                    Text(item.name).subTextExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  Divider().width('100%');
                  Row() {
                    Text('证件类型').subTextExtend();
                    Text(item.cardType).subTextExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  Divider().width('100%');
                  Row() {
                    Text('证件号').subTextExtend();
                    Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14)).subTextExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  Divider().width('100%');
                  Row() {
                    Text('联系方式').subTextExtend();
                    Text(item.phone).subTextExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                }.padding(12).width('100%');

              }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);
            }, (item: Contact) => JSON.stringify(item));


            if (this.vm.visitors.length) {
              Column() {
                Row({ space: 4 }) {
                  Image($r('app.media.active_money')).width(24).height(24);
                  Text('费用明细').commonExtend();
                }.padding(12).width('100%');

                Divider().width('100%');

                Column({ space: 12 }) {
                  Row() {
                    Text(`诚意金x${this.vm.visitors.length}`).subTextExtend();
                    Text(`¥${this.vm.visitors.length * this.vm.activeInfo.deposit}`)
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.Body_M'))
                      .fontColor($r('sys.color.font_tertiary'));
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  Text('温馨提示：诚意金仅作为确认参观意向，活动结束后均原路返还。')
                    .width('100%')
                    .fontWeight(FontWeight.Regular)
                    .fontSize($r('sys.float.Caption_M'))
                    .fontColor($r('sys.color.multi_color_08'));

                }.padding(12).width('100%');

              }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);
            }
          }.padding({ left: 16, right: 16, bottom: 16 });

        }.layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).align(Alignment.Top);

        Row() {
          Row({ space: 8 }) {
            Text('诚意金合计').commonExtend();
            Text(`¥ ${this.vm.visitors.length * this.vm.activeInfo.deposit}`)
              .fontWeight(FontWeight.Bold)
              .fontSize($r('sys.float.Body_M'))
              .fontColor('#D1B380');
          };

          Button('确定')
            .width(164)
            .height(40)
            .backgroundColor('#D1B380')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.background_primary'))
            .onClick(() => {
              if (this.vm.isValidate()) {
                this.vm.preActiveOrder();
              }
            });

        }
        .width('100%')
        .height(64)
        .padding({ left: 12, right: 16 })
        .backgroundColor('#FFFFFF')
        .justifyContent(FlexAlign.SpaceBetween);

      }
    }
    .title(TitleBuilder('参加活动'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor($r('sys.color.background_secondary'));

  }
}


@Extend(TextInput)
function baseInputExtend() {
  .padding(0)
  .textAlign(TextAlign.End)
  .height(19)
  .width(180)
  .borderRadius(0)
  .backgroundColor('transparent')
  .placeholderFont({ weight: FontWeight.Regular, size: $r('sys.float.Body_M') })
  .placeholderColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function commonExtend() {
  .fontWeight(FontWeight.Medium).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}


@Extend(Text)
function subTextExtend() {
  .fontWeight(FontWeight.Regular).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}