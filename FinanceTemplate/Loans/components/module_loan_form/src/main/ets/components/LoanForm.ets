import { hilog } from '@kit.PerformanceAnalysisKit';
import { LoanFormVM } from '../viewmodels/LoanFormVM';
import { CameraGetCardInfoDialog } from './CameraGetCardInfoDialog';

@ComponentV2
export struct LoanForm {
  @Local loanFormVM: LoanFormVM = new LoanFormVM();
  //外界传入申请人的名字-不可编辑，不能为空
  @Param idCardName: string = ''
  //可有外界传入申请人的身份证号-不可编辑，不能为空
  @Param idCardNumber: string = ''
  @Param maxLoanAmount: number = 10000
  @Event LoanFormCallBack: (loanFormVMData: LoanFormVM) => void = (loanFormVMData: LoanFormVM) => {
  }

  aboutToAppear() {
    this.loanFormVM.initLoanFormVm()
    this.loanFormVM.userRealName = this.idCardName
    this.loanFormVM.idNumber = this.idCardNumber
    this.loanFormVM.maxLoanAmount = this.maxLoanAmount
  }

  build() {

    Column({ space: 16 }) {

      Scroll() {
        Column() {
          this.personalForm()
          this.ensureForm()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

      Column() {
        Row({ space: 8 }) {
          Checkbox()
            .height(20)
            .select(this.loanFormVM.isConfirm)
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .onChange((value: boolean) => {
              this.loanFormVM.isConfirm = value
            })
          Text('我确认填写的信息和上传的资料真实有效，并同意用于贷款申请审核')
            .fontSize(12)
            .layoutWeight(1)

        }.padding(12)
        .width('100%')

        Text('提交申请')
          .backgroundColor('#317AF7')
          .fontColor(Color.White)
          .fontSize(16)
          .lineHeight(19)
          .width('100%')
          .height(40)
          .padding({ top: 10, bottom: 10 })
          .textAlign(TextAlign.Center)
          .borderRadius(20)
          .onClick(() => {
            this.loanFormVM.confirmLordForm(this.loanFormVM, (form: LoanFormVM) => {
              this.LoanFormCallBack(form)
            })
          })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 10, right: 10 })
  }

  @Builder
  ensureForm() {
    List() {
      ListItemGroup({ header: this.personalFormHeader('贷款信息表') }) {
        ListItem() {
          this.ensureTypeSelectBuilder();
        }
        .border({
          width: { bottom: (this.loanFormVM.ensureType === '' && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          this.textInputCase('贷款金额（元）', this.loanFormVM.myLoanAmount,
            `单笔最高可借${this.loanFormVM.maxLoanAmount}`, InputType.Number);
        }
        .border({
          width: { bottom: (!this.loanFormVM.isMyLoanAmountOk && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          this.bankSelectBuilder();
        }
        .border({
          width: { bottom: (this.loanFormVM.selectBankBrand === '' && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          TextInputComp({
            title: '银行卡号',
            inputValue: this.loanFormVM.bankAccountNumber,
            placeText: '请输入银行卡号',
            inputType: InputType.Number,
            onBacktextInputComp: (value: string) => {
              this.loanFormVM.bankAccountNumber = value
            }
          })
        }
        .border({
          width: { bottom: (!this.loanFormVM.isBankAccountNumberOk && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          this.textCase('还款方式', this.loanFormVM.repaymentMethod);
        }

        ListItem() {
          this.textCase('还款期数', this.loanFormVM.loanTerms + '期');
        }

      }.divider({ strokeWidth: 1 });

    }
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding({ left: 12, right: 12 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_FIRST,
      scrollBackward: NestedScrollMode.PARENT_FIRST
    })
  }

  @Builder
  personalForm() {
    List() {
      ListItemGroup({ header: this.personalFormHeader('个人资料表') }) {
        ListItem() {
          this.textCase('姓名', this.loanFormVM.userRealName);
        }
        .border({
          width: { bottom: (!this.loanFormVM.isUserRealNameOk && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          this.IDTypeSelectBuilder();
        }
        .border({
          width: { bottom: (this.loanFormVM.idType === '' && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })

        ListItem() {
          if (this.loanFormVM.idType === '身份证') {
            this.textCase('证件号码', this.loanFormVM.idNumber);
          } else if (this.loanFormVM.idType === '护照') {
            this.textInputCase('证件号码', this.loanFormVM.passPortNumber, '请输入证件号');
          }
        }
        .border({
          width: {
            bottom: this.loanFormVM.idType === '身份证' ?
              (!this.loanFormVM.isIdNumberOk && this.loanFormVM.isStartCheck ? 1 : 0) :
              (!this.loanFormVM.isPassPortNumberOk && this.loanFormVM.isStartCheck ? 1 : 0)
          },
          color: $r('sys.color.warning')
        })

        ListItem() {
          this.MarryTypeSelectBuilder();
        }
        .border({
          width: { bottom: (this.loanFormVM.marryType === '' && this.loanFormVM.isStartCheck) ? 1 : 0 },
          color: $r('sys.color.warning')
        })
      }.divider({ strokeWidth: 1 });

    }
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .padding({ left: 12, right: 12 })
    .margin({ top: 8, bottom: 16 })
  }

  @Builder
  personalFormHeader(groupTitle: string) {
    Text(groupTitle)
      .fontWeight(FontWeight.Bold)
      .width('100%')
      .textAlign(TextAlign.Start)
      .fontSize(18)
      .fontColor($r('sys.color.font_primary'))
      .padding({ top: 16, bottom: 16 })
  }

  @Builder
  IDTypeSelectBuilder() {
    Column() {
      Row() {
        Text('证件类型')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          Text(this.loanFormVM.idType)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Image($r('app.media.ic_public_arrow_right'))
              .height(24)
              .width(12)
          }
          .width(16)
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .height(48)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.loanFormVM.isShowIdType = true;
      })
      .bindSheet(this.loanFormVM.isShowIdType,
        this.sheetTypeCase(this.loanFormVM.idType, this.loanFormVM.idTypeList, '证件类型'), {
          onDisappear: () => {
            this.loanFormVM.isShowIdType = false;
          },
          showClose: false,
          height: SheetSize.FIT_CONTENT,
          dragBar: true,
          detents: [SheetSize.FIT_CONTENT, SheetSize.MEDIUM, SheetSize.LARGE],
          preferType: SheetType.CENTER
        })
    }
    .height(48)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  MarryTypeSelectBuilder() {
    Column() {
      Row() {
        Text('婚姻状况')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          Text(this.loanFormVM.marryType)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Image($r('app.media.ic_public_arrow_right'))
              .height(24)
              .width(12)
          }
          .width(16)
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .height(48)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.loanFormVM.isShowMarryType = true;
      })
      .bindSheet(this.loanFormVM.isShowMarryType,
        this.sheetTypeCase(this.loanFormVM.marryType, this.loanFormVM.marryTypeList, '婚姻状况'), {
          onDisappear: () => {
            this.loanFormVM.isShowMarryType = false;
          },
          showClose: false,
          height: SheetSize.FIT_CONTENT,
          dragBar: true,
          detents: [SheetSize.FIT_CONTENT, SheetSize.MEDIUM, SheetSize.LARGE],
          preferType: SheetType.CENTER
        })
    }
    .height(48)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ensureTypeSelectBuilder() {
    Column() {
      Row() {
        Text('担保类型')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          Text(this.loanFormVM.ensureType)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_primary'))
          Row() {
            Image($r('app.media.ic_public_arrow_right'))
              .height(24)
              .width(12)
          }
          .width(16)
          .justifyContent(FlexAlign.Center)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End);
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.loanFormVM.isShowEnsureType = true;
      })
      .bindSheet(this.loanFormVM.isShowEnsureType,
        this.sheetTypeCase(this.loanFormVM.ensureType, this.loanFormVM.ensureTypeList, '担保类型'), {
          onDisappear: () => {
            this.loanFormVM.isShowEnsureType = false;
          },
          showClose: false,
          height: SheetSize.FIT_CONTENT,
          dragBar: true,
          detents: [SheetSize.FIT_CONTENT, SheetSize.MEDIUM, SheetSize.LARGE],
          preferType: SheetType.CENTER
        })
    }.height(48)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  bankSelectBuilder() {
    Column() {
      Row() {
        Text('收款银行')
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          Text(this.loanFormVM.selectBankBrand !== '' ? this.loanFormVM.selectBankBrand : '请选择收款银行')
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.loanFormVM.selectBankBrand !== '' ? $r('sys.color.font_primary') :
            $r('sys.color.font_tertiary'))
          Row() {
            Image($r('app.media.ic_public_arrow_right'))
              .height(24)
              .width(12)
          }
          .width(16)
          .justifyContent(FlexAlign.End)
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End);
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.loanFormVM.isShowBankBrand = true;
      })
      .bindSheet(this.loanFormVM.isShowBankBrand,
        this.sheetTypeCase(this.loanFormVM.selectBankBrand, this.loanFormVM.bankBrandList, '收款银行'), {
          onDisappear: () => {
            this.loanFormVM.isShowBankBrand = false;
          },
          showClose: false,
          height: SheetSize.FIT_CONTENT,
          dragBar: true,
          detents: [SheetSize.FIT_CONTENT, SheetSize.MEDIUM, SheetSize.LARGE],
          preferType: SheetType.CENTER
        })
    }.height(48)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  textInputCase(title: string, inputValue: string, placeText: string, inputType: InputType = InputType.Normal,
    filterStr?: ResourceStr) {
    Column() {
      Row() {
        Text(title)
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          TextInput({ placeholder: placeText, text: inputValue })
            .layoutWeight(1)
            .type(inputType)
            .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .placeholderColor($r('sys.color.font_secondary'))
            .inputFilter(filterStr)
            .onWillChange((info: EditableTextChangeValue) => {
              // 表情不包括数字
              let regx1 = /\p{Emoji}(?<!\p{N})/gu;
              // 数字表情
              let regx2 = /[\d#*]\uFE0F?\u20E3/gu
              // 圆圈数字表情
              let regx3 = /[\u2460-\u24FF\u3250-\u32FF]/g

              if (info.content.match(regx1) || info.content.match(regx2) || info.content.match(regx3)) {
                return false
              } else {
                return true
              }
            })
            .onChange((value: string) => {
              if (title === '姓名') {
                this.loanFormVM.userRealName = value
              } else if (title === '证件号码') {
                if (this.loanFormVM.idType === '身份证') {
                  this.loanFormVM.idNumber = value
                } else if (this.loanFormVM.idType === '护照') {
                  this.loanFormVM.passPortNumber = value
                }
              } else if (title === '贷款金额（元）') {
                this.loanFormVM.myLoanAmount = value
              } else if (title === '银行卡号') {
                this.loanFormVM.bankAccountNumber = value
              }
            })
            .backgroundColor(Color.Transparent)
            .textAlign(TextAlign.End)
            .padding({ right: 0, left: 0 })

          Row() {
            Image(title === '银行卡号' ? $r('app.media.camera_icon') : '')
              .height(16)
              .width(16)
          }.width(16)
        }.layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height(48)
      .alignItems(VerticalAlign.Center)
    }
    .height(48)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  textCase(title: string, value: string) {
    Column() {
      Row() {
        Text(title)
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          Text(value)
            .layoutWeight(1)
            .textAlign(TextAlign.End)
            .fontColor($r('sys.color.font_fourth'))
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          Text('')
            .height(24)
            .width(16)
        }
        .layoutWeight(1)
      }.width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .height(48)
    }
    .height(48)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  sheetTypeCase(title: string, valueList: string[], type: string) {
    Column({ space: 8 }) {
      Row() {

        Image($r('app.media.close_icon'))
          .width(40)
          .height(40)
          .onClick(() => {
            if (type === '证件类型') {
              this.loanFormVM.isShowIdType = false
            } else if (type === '婚姻状况') {
              this.loanFormVM.isShowMarryType = false
            } else if (type === '担保类型') {
              this.loanFormVM.isShowEnsureType = false
            } else if (type === '收款银行') {
              this.loanFormVM.isShowBankBrand = false
            }
          })

        Text(type)
          .fontSize(20)
          .lineHeight(24)
          .fontColor('rgba(0,0,0,0.9)')
        Row() {
          Image($r('app.media.dialog_select_icon'))
            .width(24)
            .height(24)
        }
        .padding(8)
        .borderRadius(20)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .width(40)
        .height(40)
        .onClick(() => {
          if (type === '证件类型') {
            this.loanFormVM.idType = this.loanFormVM.idTypeList[this.loanFormVM.idTypeIndex]
            this.loanFormVM.isShowIdType = false
          } else if (type === '婚姻状况') {
            this.loanFormVM.marryType = this.loanFormVM.marryTypeList[this.loanFormVM.marryTypeIndex]
            this.loanFormVM.isShowMarryType = false
          } else if (type === '担保类型') {
            this.loanFormVM.ensureType = this.loanFormVM.ensureTypeList[this.loanFormVM.ensureTypeIndex]
            this.loanFormVM.isShowEnsureType = false
          } else if (type === '收款银行') {
            this.loanFormVM.selectBankBrand = this.loanFormVM.bankBrandList[this.loanFormVM.idTypeIndex]
            this.loanFormVM.isShowBankBrand = false
          }
        })
      }.width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      TextPicker({
        range: valueList,
        selected: type === '证件类型' ? this.loanFormVM.idTypeIndex :
          type === '婚姻状况' ? this.loanFormVM.marryTypeIndex :
            type === '担保类型' ? this.loanFormVM.ensureTypeIndex : this.loanFormVM.bankBrandIndex
      })
        .canLoop(false)
        .onChange((value: string | string[], index: number | number[]) => {
          hilog.info(0, 'Picker item changed, value: ' + value + ', index: ' + index, '');
          if (type === '证件类型') {
            this.loanFormVM.idTypeIndex = index as number
          } else if (type === '婚姻状况') {
            this.loanFormVM.marryTypeIndex = index as number
          } else if (type === '担保类型') {
            this.loanFormVM.ensureTypeIndex = index as number
          } else if (type === '收款银行') {
            this.loanFormVM.bankBrandIndex = index as number
          }
        })
        .width('100%')
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
  }
}

@ComponentV2
struct TextInputComp {
  @Param title: string = ''
  @Param placeText: string = ''
  @Param inputValue: string = ''
  @Param filterStr: ResourceStr = ''
  @Param loanFormVM: LoanFormVM = new LoanFormVM()
  @Param inputType: InputType = InputType.Normal
  @Event onBacktextInputComp: (value: string) => void
  controller: CustomDialogController = new CustomDialogController({
    builder: CameraGetCardInfoDialog({
      onBackCode: (value: string) => {
        this.loanFormVM.bankAccountNumber = value ?? ''
        this.onBacktextInputComp(value)
      },
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom,
  });

  build() {
    Column() {
      Row() {
        Text(this.title)
          .textAlign(TextAlign.Start)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: 10 }) {
          TextInput({ placeholder: this.placeText, text: this.loanFormVM.bankAccountNumber })
            .layoutWeight(1)
            .type(this.inputType)
            .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Medium })
            .placeholderColor($r('sys.color.font_secondary'))
            .inputFilter(this.filterStr)
            .onWillChange((info: EditableTextChangeValue) => {
              // 表情不包括数字
              let regx1 = /\p{Emoji}(?<!\p{N})/gu;
              // 数字表情
              let regx2 = /[\d#*]\uFE0F?\u20E3/gu
              // 圆圈数字表情
              let regx3 = /[\u2460-\u24FF\u3250-\u32FF]/g

              if (info.content.match(regx1) || info.content.match(regx2) || info.content.match(regx3)) {
                return false
              } else {
                return true
              }
            })
            .onChange((value: string) => {
              this.onBacktextInputComp(value)
            })
            .backgroundColor(Color.Transparent)
            .textAlign(TextAlign.End)
            .padding({ right: 0, left: 0 })

          Row() {
            Image(this.title === '银行卡号' ? $r('app.media.camera_icon') : '')
              .height(16)
              .width(16)
              .onClick(() => {
                if (this.title === '银行卡号') {
                  this.controller.open()
                }
              })
          }.width(16)
        }.layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .height(48)
      .alignItems(VerticalAlign.Center)
    }
    .height(48)
    .alignItems(HorizontalAlign.Center)
  }
}