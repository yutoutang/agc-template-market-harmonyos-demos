import { GENDER_OPTIONS, PHONE_REG } from '../common/Constants';
import { formatDate } from '../common/Utils';
import { GenderOption } from '../types/Gender';
import { PersonalInfo } from '../types/PersonalInfo';
import { EditPersonVM } from '../viewmodels/EditPersonVM';

@Builder
export function EditPersonalInfoCoreBuilder() {
  EditPersonalInfoCore()
}

@ComponentV2
struct EditPersonalInfoCore {
  @Local vm: EditPersonVM = new EditPersonVM();
  @Local showSheetGender: boolean = false;
  @Local showSheetBirth: boolean = false;
  @Local name: string = '';
  @Local gender: number = -1;
  @Local phone: string = '';
  @Local birthDate: Date | null = null;
  @Local isAgree: boolean = false;
  @Local tempGender: number = 0;
  private tempBirth: Date | null = null;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 自定义标题
          this.customTitleBuilder()

          // form表单
          this.formBuilder()

          // 底部说明操作区域
          this.agreePrivacyBuilder()
        }
        .width('100%')
        .height('100%')
        .padding(12)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
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
      Image($r('app.media.ic_close_sheet'))
        .width(40)
        .height(40)
        .draggable(false)
        .onClick(() => {
          this.vm.close();
        })
      Text('编辑个人信息').fontSize(20).fontWeight(700).margin({ left: 8 })
      Blank()
      Image($r('app.media.ic_confirm_sheet'))
        .width(40)
        .height(40)
        .draggable(false)
        .onClick(() => {
          this.onSubmit();
        })
    }
    .width('100%')
    .height(56)
  }

  @Builder
  formBuilder() {
    Column() {
      Row() {
        Text('姓名').formLabel()
        TextInput({ placeholder: '请输入', text: $$this.name })
          .backgroundColor(Color.Transparent)
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
          Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
        }
        .onClick(() => {
          this.showSheetGender = true;
        })
        .bindSheet($$this.showSheetGender, this.genderSheet(), {
          showClose: false,
          height: SheetSize.FIT_CONTENT,
        })
      }.formRowItem()

      Row() {
        Text('手机号').formLabel()
        TextInput({ placeholder: '请输入', text: $$this.phone })
          .type(InputType.PhoneNumber)
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
          this.showSheetBirth = true;
        })
        .bindSheet($$this.showSheetBirth, this.birthSheet(), {
          height: SheetSize.FIT_CONTENT,
          showClose: false,
        })
      }
      .formRowItem()
      .borderWidth(0)
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({
      top: 10,
      bottom: 40,
    })
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
              .fontColor($r('sys.color.brand'))
              .onClick(() => {
                this.vm.sheetStack.pushPathByName('PrivacyH5', null);
              })

            Span('，同时授权你的姓名性别手机号生日信息，用于注册你的会员信息')
          }
          .fontSize(10)
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
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
    .padding({
      bottom: 12,
      left: 6,
      right: 6,
    })
  }

  @Builder
  genderSheet() {
    Column() {
      Row() {
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetGender = false;
        })
        Text('性别').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_confirm_sheet')).width(40).height(40).onClick(() => {
          this.gender = this.tempGender;
          this.showSheetGender = false;
        })
      }
      .width('100%')
      .height(56)

      Column() {
        ForEach(GENDER_OPTIONS, (item: GenderOption, index: number) => {
          Text(item.label)
            .width('100%')
            .height(40)
            .textAlign(TextAlign.Center)
            .padding({ left: 2, right: 2 })
            .backgroundColor(this.tempGender === index ? Color.White : Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              this.tempGender = index;
            })
        }, (item: GenderOption) => JSON.stringify(item))
      }
      .margin({ top: 57, bottom: 86 })
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  birthSheet() {
    Column({ space: 16 }) {
      Row() {
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetBirth = false;
        })
        Text('生日').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_confirm_sheet')).width(40).height(40).onClick(() => {
          this.birthDate = this.tempBirth ?? new Date();
          this.showSheetBirth = false;
        })
      }
      .width('100%')
      .height(56)

      DatePicker({ selected: this.birthDate, start: new Date('1900-1-1'), end: new Date() })
        .onDateChange((date: Date) => {
          this.tempBirth = date;
        })
    }
    .padding({ left: 16, right: 16, bottom: 28 })
  }

  validateInfo(): boolean {
    if (this.vm.isNeedAgreePrivacy && !this.isAgree) {
      this.getUIContext().getPromptAction().showToast({ message: '请勾选并同意协议' });
      return false;
    }
    if (!this.name) {
      this.getUIContext().getPromptAction().showToast({ message: '姓名未填写' });
      return false;
    }

    if (this.gender === -1) {
      this.getUIContext().getPromptAction().showToast({ message: '性别未选择' });
      return false;
    }

    if (!this.phone) {
      this.getUIContext().getPromptAction().showToast({ message: '手机号未填写' });
      return false;
    }

    if (!PHONE_REG.test(this.phone)) {
      this.getUIContext().getPromptAction().showToast({ message: '手机号不正确' });
      return false;
    }

    if (!this.birthDate) {
      this.getUIContext().getPromptAction().showToast({ message: '生日未填写' });
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