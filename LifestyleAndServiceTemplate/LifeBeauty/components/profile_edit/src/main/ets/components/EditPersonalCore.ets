import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { GENDER_OPTIONS, PHONE_REG } from '../common/Constants';
import { formatDate } from '../common/Utils';
import { GenderOption } from '../types/Gender';
import { PersonalInfo } from '../types/PersonalInfo';
import { EditPersonVM } from '../viewmodels/EditPersonVM';
import { DatePickerDialog } from './DatePickerDialog';

@Builder
export function EditPersonalInfoCoreBuilder() {
  EditPersonalInfoCore()
}

@ComponentV2
struct EditPersonalInfoCore {
  @Local vm: EditPersonVM = new EditPersonVM();
  @Local name: string = '';
  @Local gender: number = -1;
  @Local phone: string = '';
  @Local birthDate: Date | null = null;
  @Local isAgree: boolean = false;
  fullNameController: TextInputController = new TextInputController();
  phoneController: TextInputController = new TextInputController();

  endIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.checkmark'))
    .fontSize(24).fontColor([$r('app.color.common_grey')]);

  openDatePickerDialog() {
    UIDialog.open({
      contentBuilder: (): void => this.datePickerDialogView(),
      showConfirmButton: false,
      showCancelButton: false,
    })
  }

  build() {
    NavDestination() {
      Column() {
        // 自定义标题
        this.customTitleBuilder()
        // 内容
        Scroll() {
          Column() {
            // form表单
            this.formBuilder()

            // 底部说明操作区域
            this.agreePrivacyBuilder()
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((context) => {
      this.vm = context.pathInfo.param as EditPersonVM;
    })
  }

  @Builder
  customTitleBuilder() {
    Row() {
      Text(this.vm.title).fontSize(20).fontWeight(700).margin({ left: 8 })
      Blank()
      Image($r('app.media.ic_close_sheet'))
        .width(40)
        .height(40)
        .draggable(false)
        .onClick(() => {
          this.vm.close();
        })
    }
    .width('100%')
    .height(56)
  }

  @Builder
  formBuilder() {
    Column() {
      Column() {
        Row() {
          Text('姓名').formLabel()
          TextInput({ placeholder: '请输入', text: $$this.name, controller: this.fullNameController })
            .backgroundColor(Color.Transparent)
            .contentType(ContentType.PERSON_FULL_NAME)
            .selectionMenuHidden(true)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .padding(0)
            .borderRadius(0)
        }.formRowItem()

        Row() {
          Text('性别').formLabel()
          Blank()
          Row({ space: 6 }) {
            Text(this.genderFill).fontColor($r('app.color.common_grey'))
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .fontSize(12)
              .fontColor(['#CCCCCC'])
          }
          .bindMenu(this.genderMenu)
          .onClick(() => {
            this.fullNameController.stopEditing();
            this.phoneController.stopEditing();
          })
        }.formRowItem()

        Row() {
          Text('手机号码').formLabel()
          TextInput({ placeholder: '请输入', text: $$this.phone, controller: this.phoneController })
            .maxLength(11)
            .contentType(ContentType.PHONE_NUMBER)
            .selectionMenuHidden(true)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .padding(0)
            .borderRadius(0)
        }.formRowItem()

        Row() {
          Text('生日').formLabel()
          Blank()
          Row({ space: 6 }) {
            Text(this.birthFill).fontColor($r('app.color.common_grey'))
            Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
          }
          .onClick(() => {
            this.fullNameController.stopEditing();
            this.phoneController.stopEditing();
            this.openDatePickerDialog()
          })
        }
        .formRowItem()
        .borderWidth(0)
      }
      .padding({ left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ top: 10, bottom: 40 })
    }
    .constraintSize({ minHeight: 250 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  agreePrivacyBuilder() {
    Column({ space: 10 }) {
      Row({ space: 8 }) {
        Checkbox()
          .select($$this.isAgree)
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .shape(CheckBoxShape.CIRCLE)
          .width(10)
          .height(10)

        Row() {
          Text() {
            Span('加入即代表同意')
            Span('《用户授权协议》')
              .fontColor($r('sys.color.multi_color_07'))
              .onClick(() => {
                this.vm.sheetStack.pushPathByName('PrivacyH5', null);
              })

            Span('，同时授权你的姓名性别手机号生日信息，用于注册你的会员信息')
          }
          .fontSize(12)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
        }
        .layoutWeight(1)

      }
      .alignItems(VerticalAlign.Top)
      .visibility(this.vm.isNeedAgreePrivacy ? Visibility.Visible : Visibility.None)

      Button(this.vm.btnLabel)
        .width('100%')
        .height(40)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor(this.vm.themeColor)
        .onClick(() => {
          this.onSubmit();
        })
    }
    .padding({
      bottom: 12,
      left: 6,
      right: 6,
    })
  }

  @Builder
  genderMenu() {
    Menu() {
      ForEach(GENDER_OPTIONS, (item: GenderOption, index: number) => {
        MenuItem({
          content: item.label,
          symbolEndIcon: this.gender === index ? this.endIconModifier : new SymbolGlyphModifier()
        })
          .onClick(() => {
            this.gender = index;
          })
      }, (item: GenderOption) => JSON.stringify(item))
    }
    .width(224)
    .menuItemDivider({
      strokeWidth: LengthMetrics.vp(0.5),
      color: $r('sys.color.comp_divider'),
    })
  }

  @Builder
  datePickerDialogView() {
    Column() {
      DatePickerDialog({
        date: this.birthDate || new Date(),
        confirm: (value: Date) => {
          this.birthDate = value;
          UIDialog.closeLast();
        },
        cancel: () => {
          UIDialog.closeLast();
        }
      })
    }
  }

  validateInfo(): boolean {
    if (this.vm.isNeedAgreePrivacy && !this.isAgree) {
      ToastDialog.showToast({ message: '请勾选并同意协议' });
      return false;
    }
    if (!this.name) {
      ToastDialog.showToast({ message: '姓名未填写' });
      return false;
    }

    if (this.gender === -1) {
      ToastDialog.showToast({ message: '性别未选择' });
      return false;
    }

    if (!this.phone) {
      ToastDialog.showToast({ message: '手机号未填写' });
      return false;
    }

    if (!PHONE_REG.test(this.phone)) {
      ToastDialog.showToast({ message: '手机号不正确' });
      return false;
    }

    if (!this.birthDate) {
      ToastDialog.showToast({ message: '生日未填写' });
      return false;
    }

    return true;
  }

  onSubmit() {
    const isValid = this.validateInfo();
    if (!isValid) {
      return;
    }
    const data: PersonalInfo = {
      name: this.name,
      gender: GENDER_OPTIONS[this.gender].value,
      mobile: this.phone,
      birth: this.birthDate?.getTime() || 0,
    };
    this.vm.confirm(data);
  }

  @Computed
  get genderFill() {
    if (this.gender === -1) {
      return '请选择';
    }
    return GENDER_OPTIONS[this.gender].label;
  }

  @Computed
  get birthFill() {
    if (!this.birthDate) {
      return '请选择';
    }
    return formatDate(this.birthDate.getTime());
  }
}

@Extend(Text)
function formLabel() {
  .fontSize(16)
  .fontWeight(500)
}

@Extend(Row)
function formRowItem() {
  .height(48)
  .width('100%')
  .borderWidth({ bottom: 0.5 })
  .borderColor($r('sys.color.comp_divider'))
}