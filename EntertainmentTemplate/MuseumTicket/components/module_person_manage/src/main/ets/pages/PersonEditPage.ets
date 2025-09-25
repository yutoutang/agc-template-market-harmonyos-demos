import { util } from '@kit.ArkTS';
import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder } from '../common/TitleBuilder';
import { PersonEditPageVM } from '../viewModels/PersonEditPageVM';
import { Context, Contact } from '../common/Types';

@Builder
export function PersonEditPageBuilder(_: string, context: Context) {
  PersonEditPage({ ctx: context });
}


@ComponentV2
struct PersonEditPage {
  @Param ctx: Context = new Context();
  vm: PersonEditPageVM = PersonEditPageVM.instance;

  aboutToAppear(): void {
    this.vm.cloneContact(this.ctx.contact);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row({ space: 4 }) {
            Image($r('app.media.module_person')).width(24).height(24);
            Text('常用人信息').commonExtend();
          }.padding(12).width('100%');

          Divider().width('100%');

          Column({ space: 12 }) {
            Row() {
              Text('姓名').subTextExtend();
              TextInput({ placeholder: '请输入预约人的姓名', text: this.vm.contact.name })
                .baseInputExtend()
                .onChange((res) => {
                  this.vm.contact.name = res;
                });
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);

            Divider().width('100%');
            Row() {
              Text('证件类型').subTextExtend();
              Row({ space: 4 }) {
                Text(this.vm.contact.cardType).subTextExtend();
                Image($r('app.media.card_type_right')).width(12).height(24);
              }.onClick(() => {
                this.getUIContext().showTextPickerDialog({
                  range: ['身份证'],
                  selected: 0,
                  alignment: DialogAlignment.Center,
                  defaultPickerItemHeight: 36,
                  onAccept: (value: TextPickerResult) => {
                    this.vm.contact.cardType = value.value as string;
                  },
                });
              });
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);

            Divider().width('100%');
            Row() {
              Text('证件号码').subTextExtend();
              TextInput({ placeholder: '请选择预约人的证件号码', text: this.vm.contact.cardID })
                .baseInputExtend()
                .onChange((res) => {
                  this.vm.contact.cardID = res;
                });
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);

            Divider().width('100%');
            Row() {
              Text('联系方式').subTextExtend();
              TextInput({ placeholder: '请输入预约人的联系方式', text: this.vm.contact.phone })
                .baseInputExtend()
                .type(InputType.PhoneNumber)
                .onChange((res) => {
                  this.vm.contact.phone = res;
                });
            }.width('100%').justifyContent(FlexAlign.SpaceBetween);

          }.padding(12).width('100%');

        }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);

      }.padding({ top: 5, left: 16, right: 16 }).layoutWeight(1);

      Column() {
        Button('确定')
          .height(40)
          .width('100%')
          .backgroundColor('#D1B380')
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (this.vm.isContactInfoValid()) {
              this.vm.updatePersonInfo(this.vm.contact, () => {
                this.ctx.navPathStack.pop();
              });
            }
          });
      }.padding(12).backgroundColor('#F3F4F5');
    }.title(TitleBuilder(this.vm.contact.cardID ? '编辑常用人' : '新增常用人'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5');

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

