import { hilog } from '@kit.PerformanceAnalysisKit';
import { BmiAdviceParam, BmiInfomation, BmiParam, PersonalInfo } from '../models/PersonalInfo';
import { BmiStore, EditPersonVM, UserInfo } from '../viewmodels/EditPersonVM';
import { bmiToPercent, calcBMI, formatDate } from '../models/Utils';
import { GENDER_OPTIONS } from '../models/Constants';
import { PersistenceV2, promptAction } from '@kit.ArkUI';

@Builder
export function EditUserInfoBuilder() {
  EditUserInfo()
}

@ComponentV2
export struct EditUserInfo {
  @Param btnLabel: ResourceStr = '评估我的BMI';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Event confirm: (value: PersonalInfo) => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  };
  @Local vm: EditPersonVM = new EditPersonVM();
  @Local showSheetGender: boolean = false;
  @Local showSheetBMI: boolean = false;
  @Local showSheetBirth: boolean = false;
  @Local showSheetHeight: boolean = false;
  @Local showSheetWeight: boolean = false;
  @Local showSheetBMIRole: boolean = false;
  @Local showSheetRoleHeight: boolean = false;
  @Local showSheetRoleWeight: boolean = false;
  @Local userheight: string = '';
  @Local gender: number = -1;
  @Local weight: string = '';
  @Local birthDate: Date | null = null;
  @Local isAgree: boolean = false;
  @Local tempGender: number = 0;
  private tempBirth: Date | null = null;
  @Local tempUserHeight: string = '';
  // BMI计算规则 height weight
  @Local ruleUserHeight: string = '';
  @Local ruleUserWeight: string = '';
  @Local heightOptions: string[] =
    ['135cm', '136cm', '137cm', '138cm', '139cm', '140cm', '141cm', '142cm', '143cm', '144cm', '145cm', '146cm',
      '147cm', '148cm', '149cm', '150cm',
      '151cm', '152cm', '153cm', '154cm', '155cm', '156cm', '157cm', '158cm', '159cm', '160cm', '161cm', '162cm',
      '163cm', '164cm', '165cm', '166cm',
      '167cm', '168cm', '169cm', '170cm', '171cm', '172cm', '173cm', '174cm', '175cm', '176cm', '177cm', '178cm',
      '179cm', '180cm', '181cm', '182cm',
      '183cm', '184cm', '185cm', '186cm', '187cm', '188cm', '189cm', '190cm', '191cm', '192cm', '193cm', '194cm',
      '195cm', '196cm', '197cm', '198cm', '199cm', '200cm']
  // 数据：五行两列
  private readonly data: [string, string][] = [
    ['<18.5', '体重过低'],
    ['18.5-23.9', '体重正常'],
    ['24-27.9', '超重'],
    ['≥28', '肥胖'],
  ];
  @Local genderOption: string[] = ['男', '女']
  @Local isValid: boolean = false;
  @Local bmiRoles: string[][] =
    [['体重过低', '#3DAFFE'], ['体重正常', '#1DD69D'], ['超重', '#FFA73B'], ['肥胖', '#FF5859']];
  @Local bmiInfo: BmiStore = PersistenceV2.connect(BmiStore, 'bmi', () => new BmiStore())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, 'userInfo', () => new UserInfo())!;
  @Local stack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.vm.btnLabel = this.btnLabel;
    this.vm.themeColor = this.themeColor;
    this.vm.confirm = this.confirm;
    this.isValid = this.validateInfo();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 自定义标题
          this.customTitleBuilder()
          if (!(this.bmiInfo.bmiValue > 0)) {
            Row() {
              Text('确认以下身体指标，开始评估您的BMI').width('100%').fontSize(16).lineHeight(22)
            }.width('100%').height(56).padding({ top: 17, bottom: 17 }).margin({ top: 8 })
          } else {
            Column({ space: 13 }) {
              Row({ space: 60 }) {
                Text(`BMI:${this.bmiInfo.bmiValue}`).bmiText()
                Text(this.bmiInfo.physicalState).bmiText()
              }.width('100%')

              Text() {
                Span(this.bmiInfo.healthTips.length > 40 ?
                  this.bmiInfo.healthTips.substring(0, 40) + '...' :
                  this.bmiInfo.healthTips + ' ')
                Span('更多')
                  .fontColor('#FC7A17')
                  .onClick(() => {
                    this.showSheetBMI = true;
                  })
                  .width(20)
              }
              .fontSize(12)
              .width('100%')
              .textAlign(TextAlign.Start)
              .maxLines(2)
              .bindSheet($$this.showSheetBMI, this.BMISheet(), {
                showClose: false,
                height: SheetSize.FIT_CONTENT,
                preferType: SheetType.CENTER
              })

            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .padding(16)
          }

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
    .onReady((context) => {
      this.stack = context.pathStack;
    })
    .padding({ top: 20 })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  customTitleBuilder() {
    Row() {
      Stack() {
        Image($r('app.media.ellipse')).width(40).height(40)
          .backgroundColor('#0d000000').borderRadius('50%')
        Image($r('app.media.arrow_left'))
          .width(24)
          .height(24)
          .draggable(false)
      }
      .onClick(() => {
        this.stack.pop()
      })

      Text('我的BMI').fontSize(20).fontWeight(700).margin({ left: 8 })
      Blank()
    }
    .width('100%')
    .height(56)
  }

  @Builder
  formBuilder() {
    Column() {
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
          preferType: SheetType.CENTER,
          height: SheetSize.FIT_CONTENT,
        })
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
          preferType: SheetType.CENTER,
          showClose: false,
        })
      }
      .formRowItem()

      Row() {
        Text('身高').formLabel()
        Blank()
        Row({ space: 6 }) {
          Text(this.heightFill).fontColor($r('app.color.common_grey'))
          Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
        }
        .onClick(() => {
          this.showSheetHeight = true;
        })
        .bindSheet($$this.showSheetHeight, this.heightSheet(), {
          preferType: SheetType.CENTER,
          showClose: false,
          height: SheetSize.FIT_CONTENT,
        })
      }.formRowItem()

      Row() {
        Text('当前体重').formLabel()
        Blank()
        Row({ space: 6 }) {
          Text(this.weightFill).fontColor($r('app.color.common_grey'))
          Image($r('app.media.ic_public_arrow_right')).width(12).fillColor($r('app.color.common_grey'))
        }
        .onClick(() => {
          this.showSheetWeight = true;
        })
        .bindSheet($$this.showSheetWeight, this.WeightSheet(), {
          showClose: false,
          preferType: SheetType.CENTER,
          height: SheetSize.FIT_CONTENT,
        })
      }.formRowItem()
      .borderWidth(0)
    }
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({
      top: 10,
      bottom: 40,
    })
  }

  @Builder
  agreePrivacyBuilder() {
    Column({ space: 10 }) {
      Button(this.vm?.btnLabel)
        .width('100%')
        .height(40)
        .stateEffect(this.isValid)
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor(this.isValid ? '#FC7A17' : '#999999')
        .onClick(() => {
          if (this.isValid) {
            this.onSubmit()
          }
        })
      Text('BMI计算规则').fontSize(12).fontColor('#80000000')
        .onClick(() => {
          this.showSheetBMIRole = true;
        })
        .bindSheet($$this.showSheetBMIRole, this.bmiRoleSheet(), {
          height: SheetSize.FIT_CONTENT,
          showClose: false,
          preferType: SheetType.CENTER
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
        Text('你的性别').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetGender = false;
        })
      }
      .width('100%')
      .height(56)

      TextPicker({ range: this.genderOption, selected: this.defaultSelectedGender() })
        .onChange((height: string | string[], index: number | number[]) => {
          index = index as number
          this.tempGender = index
        })
        .canLoop(false)
        .selectedTextStyle({
          color: '#000',
          font: {
            size: 20,
            weight: FontWeight.Bold
          }
        })

      Column() {
        Button('保存')
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            this.gender = this.tempGender;
            this.userInfo.gender = GENDER_OPTIONS[this.gender].label
            this.showSheetGender = false;
            this.isValid = this.validateInfo();
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        left: 6,
        right: 6,
        top: 28,
      })
    }

    .padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  weightSheet() {
    Column() {
      Row() {
        Text('你的身高').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetHeight = false;
        })
      }
      .width('100%')
      .height(56)

      TextPicker({ range: this.heightOptions, selected: this.defaultSelctedHeight() })
        .onChange((height: string | string[], index: number | number[]) => {
          // tempUserHeight赋值
          this.tempUserHeight = this.heightOptions[Number(index)]
        })
      Column() {
        Button('保存')
          .height(40)
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (this.tempUserHeight) {
              // 赋值给userheight
              this.userheight = this.tempUserHeight;
            } else {
              this.userheight = this.heightOptions[Math.trunc(this.heightOptions.length / 2)];
            }
            this.isValid = this.validateInfo();
            this.showSheetHeight = false;
            this.userInfo.userheight = this.userheight;
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        left: 6,
        bottom: 12,
        right: 6,
        top: 28
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  heightSheet() {
    Column() {
      Row() {
        Text('你的身高').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetHeight = false;
        })
      }
      .width('100%')
      .height(56)

      TextPicker({ range: this.heightOptions, selected: this.defaultSelctedHeight() })
        .onChange((height: string | string[], index: number | number[]) => {
          this.tempUserHeight = this.heightOptions[Number(index)]
        })
        .selectedTextStyle({
          color: '#000',
          font: {
            weight: FontWeight.Bold,
            size: 20,
          }
        })
        .canLoop( false)
      Column() {
        Button('保存')
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .width('100%')
          .onClick(() => {
            if (this.tempUserHeight) {
              this.userheight = this.tempUserHeight;
            } else {
              // userheight赋值
              this.userheight = this.heightOptions[Math.trunc(this.heightOptions.length / 2)];
            }
            this.showSheetHeight = false;
            this.isValid = this.validateInfo();
            this.userInfo.userheight = this.userheight;
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        right: 6,
        left: 6,
        top: 28
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  WeightSheet() {
    Column() {
      Row() {
        Text($r('app.string.your_weight')).fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetWeight = false;
        })
      }
      .width('100%')
      .height(56)

      Row() {
        Stack({ alignContent: Alignment.End }) {
          TextInput({ placeholder: '请输入', text: $$this.weight })
            .onChange((raw: string) => {
              this.weight = raw
                .replace(/[^0-9.]/g, '')// 1. 先去掉非数字非小数点字符
                .replace(/(\..*)\./g, '$1'); // 2. 只保留第一个小数点，去掉多余的;
              this.isValid = this.validateInfo();
            })
            .maxLength(5)
            .fontColor($r('sys.color.font_primary'))
            .borderRadius(20)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .layoutWeight(1)
            .textOverflow(TextOverflow.Ellipsis)
            .textAlign(TextAlign.Start)
            .maxLines(1)
          Text('kg')
            .fontColor($r('app.color.common_grey'))
            .textAlign(TextAlign.End).margin({ left: 6, right: 16 })
        }

      }
      .padding({ top: 8, bottom: 8 })
      .height(56)
      .margin({ top: 23 })

      Column() {
        Button('保存')
          .fontColor($r('sys.color.font_on_primary'))
          .width('100%')
          .height(40)
          .onClick(() => {
            if (!this.weight) {
              promptAction.showToast({ message: '体重不能为空' })
            }
            this.showSheetWeight = false;
            this.isValid = this.validateInfo();
            this.userInfo.weight = this.weight
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        right: 6,
        bottom: 14,
        left: 6,
        top: 68
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  birthSheet() {
    Column({ space: 16 }) {
      Row() {
        Text('你的出生日期').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetBirth = false;
        })
      }
      .width('100%')
      .height(56)

      DatePicker({ selected: this.defaultSelectedBirth(), start: new Date('1900-1-1'), end: new Date() })
        .onDateChange((date: Date) => {
          this.tempBirth = date;
        })
        .selectedTextStyle({
          font: {
            size: $r('sys.float.Title_S'),
            weight: FontWeight.Bold
          }
        })
      Column() {
        Button('保存')
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .height(40)
          .onClick(() => {
            if (this.tempBirth) {
              this.birthDate = this.tempBirth;
            } else {
              this.birthDate = new Date()
            }
            this.userInfo.birth = this.birthDate?.getTime() || 0
            this.showSheetBirth = false;
            this.isValid = this.validateInfo();
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        top: 28,
        left: 6,
        right: 6,
      })
    }
    .padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  heightRuleSheet() {
    Column() {
      Row() {
        Text('你的身高').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetRoleHeight = false;
        })
      }
      .width('100%')
      .height(56)

      TextPicker({ range: this.heightOptions, selected: this.defaultSelctedHeight() })
        .onChange((height: string | string[], index: number | number[]) => {
          this.ruleUserHeight = this.heightOptions[Number(index)]
        })
        .selectedTextStyle({
          font: {
            size: 20,
            weight: FontWeight.Bold
          },
          color: '#000',
        })
        .canLoop( false)
      Column() {
        Button('保存')
          .height(40)
          .width('100%')
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (!this.ruleUserHeight) {
              this.ruleUserHeight = this.heightOptions[Math.trunc(this.heightOptions.length / 2)];
            }
            this.showSheetRoleHeight = false;
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        right: 6,
        top: 28,
        left: 6,
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  weightRuleSheet() {
    Column() {
      Row() {
        Text($r('app.string.your_weight')).fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetRoleWeight = false;
        })
      }
      .width('100%')
      .height(56)

      Row() {
        Stack({ alignContent: Alignment.End }) {
          TextInput({ placeholder: '请输入', text: $$this.ruleUserWeight })
            .onChange((raw: string) => {
              this.ruleUserWeight = raw
                .replace(/[^0-9.]/g, '')// 1. 先去掉非数字非小数点字符
                .replace(/(\..*)\./g, '$1'); // 2. 只保留第一个小数点，去掉多余的;
            })
            .maxLength(5)
            .maxLines(1)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow(TextOverflow.Ellipsis)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
          Text('kg')
            .fontColor($r('app.color.common_grey'))
            .textAlign(TextAlign.End).margin({ left: 6, right: 16 })
        }
      }
      .padding({ top: 8, bottom: 8 })
      .height(56)
      .margin({ top: 23 })

      Column() {
        Button('保存')
          .width('100%')
          .height(40)
          .onClick(() => {
            if (!this.ruleUserWeight) {
              promptAction.showToast({ message: '体重不能为空' })
            }
            this.showSheetRoleWeight = false;
          })
          .fontColor($r('sys.color.font_on_primary'))
      }
      .justifyContent(FlexAlign.End)
      .padding({
        left: 6,
        bottom: 14,
        right: 6,
        top: 68
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  validateInfo():
    boolean {
    if (!this.userInfo.userheight && !this.weight) {
      return false;
    }

    if (!this.userInfo.gender && this.gender === -1) {
      return false;
    }

    if (!this.userInfo.weight && !this.weight) {
      return false;
    }

    if (!this.userInfo.birth && !this.birthDate) {
      return false;
    }
    return true;
  }

  @Builder
  bmiRoleSheet() {
    Column() {
      Row() {
        Text('BMI计算规则').fontSize(20).fontWeight(700)
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetBMIRole = false;
        })
      }
      .width('100%')
      .height(56)

      Row() {
        Text('请输入你的身高与体重即可算出BMI指数:').width('100%').fontSize(16).lineHeight(22)
      }.width('100%').height(56).padding({ bottom: 17 }).margin({ top: 8 })

      Column({ space: 13 }) {
        Row() {
          Text('身高:').fontWeight(FontWeight.Bold)
          Blank()
          Text(this.userInfo.userheight || this.ruleUserHeight ?
            (`${Number(this.userInfo.userheight === this.ruleUserHeight || !this.ruleUserHeight ?
              this.userInfo.userheight.match(/\d+/)?.[0] :
              this.ruleUserHeight.match(/\d+/)?.[0])}cm/厘米`) : '-- cm/厘米')
            .fontSize(14)
            .fontColor('#80000000')
        }.width('100%')
        .onClick(() => {
          this.showSheetRoleHeight = true
        })
        .bindSheet($$this.showSheetRoleHeight, this.heightRuleSheet(), {
          height: SheetSize.FIT_CONTENT,
          showClose: false,
          preferType: SheetType.CENTER
        })

        Divider().strokeWidth('1px')
        Row() {
          Text('体重:').fontWeight(FontWeight.Bold)
          Blank()
          Text(this.userInfo.weight || this.ruleUserWeight ?
            (`${this.userInfo.weight === this.ruleUserWeight || !this.ruleUserWeight ? this.userInfo.weight :
              this.ruleUserWeight}kg/千克`) :
            '-- kg/千克')
            .fontSize(14)
            .fontColor('#80000000')
        }.width('100%')
        .bindSheet($$this.showSheetRoleWeight, this.weightRuleSheet(), {
          height: SheetSize.FIT_CONTENT,
          showClose: false,
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          this.showSheetRoleWeight = true
        })
      }
      .height(96)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .borderRadius(12)
      .width('100%')
      .padding(16)

      Column() {
        Button(this.isValid ? '重新计算我的BMI' : '确认')
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#FC7A17')
          .onClick(() => {
            this.isValid = this.validateInfo();
            this.userInfo.weight = this.ruleUserWeight
            this.userheight = this.ruleUserHeight;
            this.userInfo.userheight = this.ruleUserHeight;
            this.weight = this.ruleUserWeight;
            this.showSheetBMIRole = false;
            this.onSubmit();
          })
      }
      .height(40)
      .justifyContent(FlexAlign.End)
      .padding({
        left: 6,
        bottom: 12,
        right: 6,
      })
      .margin({
        top: 16
      })

      //你的BMI
      Column() {
        Row() {
          Text(`你的BMI为: ${this.bmiInfo.bmiValue > 0 ? this.bmiInfo.bmiValue : '--'}`)
            .fontSize(17)
            .margin({ left: 8 })
            .fontWeight(700)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center)

        Column() {
          Stack({ alignContent: Alignment.Top }) {
            Row() {
              ForEach(this.bmiRoles, (item: [string, string]) => {
                Column({ space: 9 }) {
                  Row() {
                  }
                  .width('25%')
                  .height(11)
                  .backgroundColor(item[1])
                  .borderRadius({
                    topLeft: item[0] === '体重过低' ? 15 : 0,
                    bottomLeft: item[0] === '体重过低' ? 15 : 0,
                    topRight: item[0] === '肥胖' ? 15 : 0,
                    bottomRight: item[0] === '肥胖' ? 15 : 0
                  })

                  Text(item[0]).width('25%').textAlign(TextAlign.Center).fontSize(12).lineHeight(17)
                }
              }, (v: string) => v)
            }.margin({ top: 26 }).padding({ left: 10, right: 10, })

            Slider({
              style: SliderStyle.OutSet,
              value: bmiToPercent(this.bmiInfo.bmiValue),
              max: 100
            })
              .trackColor($r('sys.color.comp_background_secondary'))
              .enabled(false)
              .blockSize({ width: '60px', height: '60px' })
              .blockColor('#FC7A17')
              .selectedColor($r('sys.color.comp_background_emphasize'))
              .width('100%')
              .margin({ left: -4 })
              .blockStyle({
                type: SliderBlockType.SHAPE,
                shape: new Path({ commands: 'M60 60 M30 45 L15 15 L45 15 Z' })
              })
          }
        }
        .width('100%')
        .borderRadius(12)
        .height(76)
        .backgroundColor('#fff')
      }.width('100%').visibility(this.isValid ? Visibility.Visible : Visibility.None)

      //BMI中国标准划分对照表
      Column() {
        Row() {
          Text('BMI中国标准划分对照表:')
            .fontSize(12)
            .fontColor('#999')
            .margin({ left: 8 })
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .height(37)
        .padding({ top: 10, bottom: 10 })

        Column({ space: 1 }) {
          // 表头
          Row({ space: 1 }) {
            this.headerCell('BMI范围');
            this.headerCell('BMI分类');
          }

          // 数据行
          ForEach(this.data, (item: [string, string]) => {
            Row({ space: 1 }) {
              this.dataCell(item[0]);
              this.dataCell(item[1])
            }
          }, (v: string) => v)
        }
        .borderRadius(12)
        .width('100%')
        .shadow({ radius: 4, color: '#20000000' });
      }.width('100%').visibility(this.isValid ? Visibility.Visible : Visibility.None)

    }.width('100%').padding({ left: 16, right: 16, bottom: 16 })
  }

  @Builder
  BMISheet() {
    Column() {
      Row() {
        Text() {
          Span(`BMI:${this.bmiInfo.bmiValue}`).bmiSpanText().letterSpacing(2)
          Span(this.bmiInfo.physicalState).bmiSpanText()
        }

        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.showSheetBMI = false;
        })
      }.width('100%').height(56)

      Column({ space: 16 }) {
        Row() {
          Text(this.bmiInfo.healthTips) {
          }
        }.padding(16).backgroundColor('#fff').borderRadius(16)

        Row() {
          Text(this.bmiInfo.healthAnalysis) {
          }
        }.padding(16).backgroundColor('#fff').borderRadius(16)
      }

      Column() {
        Button('确认')
          .fontColor($r('sys.color.font_on_primary'))
          .width('100%')
          .height(40)
          .backgroundColor('#FC7A17')
          .onClick(() => {
            this.showSheetBMI = false;
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        left: 6,
        right: 6,
        bottom: 12,
        top: 28
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  onSubmit() {
    const bmiResult =
      calcBMI(this.userInfo.gender, this.userInfo.birth.toString(),
        Number(this.userInfo.userheight.match(/\d+(?:\.\d+)?/)?.[0]),
        Number(this.userInfo.weight)) as BmiParam
    this.bmiInfo.bmiValue = bmiResult.bmi;
    this.bmiInfo.physicalState = bmiResult.level;
    BmiInfomation.bmiAdvice.map((item: BmiAdviceParam) => {
      if (item.physicalState === bmiResult.level) {
        this.bmiInfo.healthAnalysis = item.healthAnalysis;
        this.bmiInfo.healthTips = item.healthTips;
      }
    })
    PersistenceV2.save(this.bmiInfo.toJson());
    PersistenceV2.save(this.userInfo.toJson());
  }

  defaultSelctedHeight(): number {
    if (this.tempUserHeight) {
      return this.heightOptions.findIndex(item => item === this.tempUserHeight)
    } else if (this.userInfo.userheight) {
      return this.heightOptions.findIndex(item => item === this.userInfo.userheight)
    } else {
      return Math.trunc(this.heightOptions.length / 2)
    }
  }

  defaultSelectedBirth() {
    if (this.userInfo.userheight) {
      return new Date(this.userInfo.birth)
    } else {
      return this.birthDate
    }
  }

  defaultSelectedGender() {
    if (this.userInfo.gender) {
      return this.genderOption.findIndex(item => item === this.userInfo.gender)
    } else {
      return 0
    }
  }

  @Computed
  get genderFill() {
    if (!this.userInfo.gender) {
      return '请选择';
    }
    return this.userInfo.gender
  }

  @Computed
  get birthFill() {
    if (!this.userInfo.birth) {
      return '请选择';
    }
    return formatDate(this.userInfo.birth)
  }

  @Computed
  get heightFill() {
    if (!this.userInfo.userheight) {
      return '请选择';
    }
    return this.userInfo.userheight;
  }

  @Computed
  get weightFill() {
    if (!this.userInfo.weight) {
      return '请输入';
    }
    return this.userInfo.weight + 'kg';
  }

  @Builder
  headerCell(title: string) {
    Text(title)
      .fontSize(16)
      .width('50%')
      .fontColor('#80000000')
      .backgroundColor('#FFFFFF')
      .height(48)
      .borderRadius({ topLeft: title === 'BMI范围' ? 12 : 0, topRight: title === 'BMI范围' ? 0 : 12 })
      .textAlign(TextAlign.Center)
  }

  @Builder
  dataCell(content: string) {
    Text(content)
      .fontSize(16)
      .width('50%')
      .textAlign(TextAlign.Center)
      .height(48)
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: content === '≥28' ? 12 : 0, bottomRight: content === '肥胖' ? 12 : 0 })
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
  .borderWidth({ bottom: 0.5 })
  .width('100%')
  .borderColor($r('sys.color.comp_divider'))
}

@Extend(Text)
function bmiText() {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .lineHeight(28)
}

@Extend(Span)
function bmiSpanText() {
  .fontWeight(FontWeight.Bold)
  .fontSize(20)
  .lineHeight(28)
}