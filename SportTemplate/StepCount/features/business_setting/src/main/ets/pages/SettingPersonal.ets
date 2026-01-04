import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { CommonConstants, TimeUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingPersonalVM } from '../viewmodels/SettingPersonalVM';
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Builder
export function SettingPersonalBuilder() {
  SettingPersonal()
}

@ComponentV2
struct SettingPersonal {
  @Local vm: SettingPersonalVM = new SettingPersonalVM();
  @Local sexTempValue: string | string[] = this.vm.personalSex
  @Local sexTempIndex: number | number[] = this.vm.personalSexSelect
  @Local birthdayTempDate: string = this.vm.personalBirthday

  aboutToAppear(): void {
    this.vm.registerKeyboard();
    this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
  }

  aboutToDisappear(): void {
    this.vm.unRegisterKeyboard();
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '个人信息',
        onBack: () => {
          this.vm.customBack();
        },
      })
      Scroll() {
        Column({ space: CommonConstants.SPACE_M }) {
          this.userIconBuilder()
          List() {
            ListItem() {
              this.nickNameBuilder()
            }

            ListItem() {
              this.personalDescBuilder()
            }

            ListItem() {
              this.sexBuilder()
            }

            ListItem() {
              this.birthdayBuilder()
            }
          }
          .width(CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.large_radius'))
          .padding(CommonConstants.PADDING_XS)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .divider({
            strokeWidth: 0.5,
            color: $r('sys.color.comp_divider'),
            startMargin: CommonConstants.PADDING_M,
            endMargin: CommonConstants.PADDING_M,
          })

        }
        .padding({
          top: CommonConstants.PADDING_M,
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.vm.customBack();
      return true;
    })
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Builder
  userIconBuilder() {
    Row() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Row() {
          Stack({ alignContent: Alignment.BottomEnd }) {
            Row({ space: CommonConstants.SPACE_XS }) {
              FunctionalButton({
                params: {
                  openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                  label: '',
                  styleOption: {
                    styleConfig: new functionalButtonComponentManager.ButtonConfig()
                      .type(ButtonType.Normal)
                      .backgroundImage(this.vm.userInfoModel.authorIcon ? this.vm.userInfoModel.authorIcon :
                        $r('app.media.ic_user_default'))
                      .backgroundImageSize(ImageSize.Cover)
                      .width(100)
                      .height(100)
                      .borderRadius(50)//居中
                      .align(Alignment.Center)
                      .backgroundColor('#E5E5E5')
                  },
                },
                controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
                  data) => {
                  if (data) {
                    this.vm.saveUserIcon(data.avatarUri!);
                  }
                }),
              })
            }

            Image($r('app.media.ic_edit_user_avatar'))
              .width($r('app.float.vp_24'))
              .draggable(false)
          }
        }
        .innerCard()
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Column() {
          Row() {
            Text('ID').fontSize(10).fontColor('rgba(0,0,0,0.3)').fontFamily('PingFangSC, PingFang SC')
            Text(this.vm?.id)
              .width('60%')
              .margin({ left: 5 })
              .fontSize(10)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .ellipsisMode(EllipsisMode.CENTER)
              .fontColor('#161616')
              .fontFamily('PingFangSC, PingFang SC')
            Column() {
              Image($r('app.media.ic_copy'))
                .width($r('app.float.arrow_right_w'))
                .draggable(false)
                .margin({ left: 4 })
            }
            .width(16)
            .height(16)
            .padding(2)
            .borderRadius(9)
            .onClick(() => {
              // 点击复制
              try {
                let data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.vm?.id)
                pasteboard.getSystemPasteboard().setData(data, (err) => {
                  if (err?.code) {
                    promptAction.showToast({ message: '复制失败' })
                    return
                  }
                  promptAction.showToast({ message: '复制成功' })
                })
              } catch (error) {
                promptAction.showToast({ message: '复制失败' })
              }
            })

          }

        }
        .width('24%')
        .height('90%')
        .margin({ left: 90, top: 10, right: 10 })
        .padding({ bottom: 10 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
    .outerCard(150)
  }

  @Builder
  nickNameBuilder() {
    Row() {
      Row() {
        Text('昵称')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.userInfoModel.authorNickName)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .constraintSize({ maxWidth: '80%' })
          // 图标
          Image($r('app.media.ic_right'))
            .draggable(false)
            .width($r('app.float.arrow_right_w'))
        }
      }
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
      .innerCard()
    }
    .outerCard()
    .onClick(() => {
      this.vm.nickName = this.vm.userInfoModel.authorNickName;
      this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
      this.vm.showNickNameSheet = true;
    }).bindSheet($$this.vm.showNickNameSheet, this.modifyNameSheet(), {
      title: { title: '设置昵称' },
      detents: [this.vm.defaultSheetH, SheetSize.MEDIUM],
      height: this.vm.defaultSheetH,
      showClose: true,
      preferType: SheetType.CENTER,
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
    })
  }

  @Builder
  personalDescBuilder() {
    Row() {
      Row() {
        Text('简介')
          .fontWeight(FontWeight.Medium)
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))

        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.userInfoModel.authorDesc ? this.vm.userInfoModel.authorDesc : '请编辑个人介绍')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
            .ellipsisMode(EllipsisMode.END)
            .constraintSize({ maxWidth: '80%' })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
      }
      .innerCard()
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles,
      })
    }
    .outerCard()
    .onClick(() => {
      this.vm.personalDesc = this.vm.userInfoModel.authorDesc;
      this.vm.showPersonDescSheet = true;
    })
    .bindSheet($$this.vm.showPersonDescSheet, this.modifyPersonalDescSheet(), {
      title: { title: '简介' },
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
      detents: [this.vm.defaultSheetH, SheetSize.MEDIUM],
      height: this.vm.defaultSheetH,
      showClose: true,
      preferType: SheetType.CENTER
    })
  }

  @Builder
  sexBuilder() {
    Row() {
      Row() {
        Text('性别')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.userInfoModel.authorSex ? this.vm.userInfoModel.authorSex : '请填写性别')
            .fontColor($r('sys.color.font_secondary'))
            .constraintSize({ maxWidth: '80%' })
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
      }
      .innerCard()
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
    }
    .outerCard()
    .onClick(() => {
      this.vm.showSexSheet = true
    }).bindSheet($$this.vm.showSexSheet, this.modifySexSheet(), {
      title: { title: '性别' },
      detents: [SheetSize.FIT_CONTENT],
      height: SheetSize.FIT_CONTENT,
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
      showClose: true,
      preferType: SheetType.CENTER
    })
  }

  @Builder
  birthdayBuilder() {
    Row() {
      Row() {
        Text('生日')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.userInfoModel.authorBirthday?.length > 0 ? this.vm.userInfoModel.authorBirthday :
            '请编写生日')
            .constraintSize({ maxWidth: '80%' })
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
      }
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles,
      })
      .innerCard()
    }
    .outerCard()
    .onClick(() => {
      this.vm.showBirthdaySheet = true
    }).bindSheet($$this.vm.showBirthdaySheet, this.modifyBirthdaySheet(), {
      title: { title: '生日' },
      showClose: true,
      detents: [SheetSize.FIT_CONTENT],
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
      height: SheetSize.FIT_CONTENT,
      preferType: SheetType.CENTER
    })
  }

  @Builder
  regionBuilder() {
    Row() {
      Row() {
        Text('地区')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: CommonConstants.SPACE_XS }) {
          Text(this.vm.userInfoModel.authorRegion ?
            this.vm.userInfoModel.authorRegion :
            '设置地区，发现同乡')
            .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
            .constraintSize({ maxWidth: '80%' })
            .fontColor($r('sys.color.font_secondary'))
          Image($r('app.media.ic_right'))
            .draggable(false)
            .width($r('app.float.arrow_right_w'))
        }
      }
      .innerCard()
      .stateStyles({
        pressed: this.pressedStyles,
        normal: this.normalStyles,
      })
    }
    .outerCard()
    .onClick(() => {
      this.vm.personalRegion = this.vm.userInfoModel.authorRegion;
      this.vm.showRegionSheet = true;
    })
    .bindSheet($$this.vm.showRegionSheet, this.modifyRegionSheet(), {
      title: { title: '地区' },
      showClose: true,
      height: this.vm.defaultSheetH,
      preferType: SheetType.CENTER,
      detents: [this.vm.defaultSheetH, SheetSize.MEDIUM],
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
    })
  }

  @Builder
  modifyNameSheet() {
    Column() {
      Column() {
        TextInput({ text: $$this.vm.nickName })
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 16 } })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .showCounter(true)
          .maxLength(20)
          .height(40)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .backgroundColor($r('app.color.app_theme'))
            .onClick(() => {
              this.vm.modifyNickName();
              this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
            })
        }
        .padding({ bottom: this.vm.keyHeight })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      right: CommonConstants.PADDING_PAGE,
      left: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }

  @Builder
  modifyPhoneSheet() {
    Column() {
      Column() {
        TextInput({ text: $$this.vm.contactPhone })
          .type(InputType.PhoneNumber)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .maxLength(20)
          .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 16 } })
          .height(40)
          .showCounter(true)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .backgroundColor($r('app.color.app_theme'))
            .fontColor($r('sys.color.font_on_primary'))
            .width('100%')
            .onClick(() => {
              this.vm.modifyContactPhone();
              this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
            })
        }
        .padding({ bottom: this.vm.keyHeight })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding,
      right: CommonConstants.PADDING_PAGE,
    })
  }

  @Builder
  modifyPersonalDescSheet() {
    Column() {
      Column() {
        TextArea({ text: $$this.vm.personalDesc, placeholder: '简单介绍一下自己吧~~' })
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_tertiary'))
          .placeholderFont({ size: 16 * this.vm.settingInfo.fontSizeRatio })
          .backgroundColor(Color.White)
          .height(156)
          .maxLength(70)
          .showCounter(true)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .backgroundColor($r('app.color.app_theme'))
            .onClick(() => {
              this.vm.modifyPersonalDesc();
              this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
            })
        }
        .padding({ bottom: this.vm.keyHeight })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      right: CommonConstants.PADDING_PAGE,
      left: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }

  @Builder
  modifySexSheet() {
    Column() {
      TextPicker({
        range: this.vm.personalSexList,
        selected: this.vm.personalSexSelect,
      }).defaultPickerItemHeight(40)
        .selectedTextStyle({ color: Color.Black, font: { weight: FontWeight.Bold } })
        .canLoop(false)
        .onChange((value, index) => {
          this.sexTempIndex = index
          this.sexTempValue = value
        })

      Button('确定')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.app_theme'))
        .fontColor($r('sys.color.font_on_primary'))
        .width('100%')
        .onClick(() => {
          if (this.sexTempValue.length <= 0) {
            this.sexTempValue = this.vm.personalSexList[this.sexTempIndex as number]
          }
          // 设置select为按下确定按钮时候的选中项index，这样当弹窗再次弹出时显示选中的是上一次确定的选项
          this.vm.personalSexSelect = this.sexTempIndex;
          // 点击确定后，数据保存到model中
          this.vm.userInfoModel.authorSex = this.sexTempValue as string;
          this.vm.personalSex = this.vm.userInfoModel.authorSex;
          this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
          this.vm.showSexSheet = false
        })
    }
    .padding({
      left: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_L + this.vm.windowModel.windowBottomPadding,
      right: CommonConstants.PADDING_L,
    })
  }

  @Builder
  modifyBirthdaySheet() {
    Column() {
      DatePicker({
        start: new Date('1970-1-1'),
        end: new Date(),
        selected: new Date(this.vm.personalBirthday),
      })
        .selectedTextStyle({ font: { weight: FontWeight.Bold } })
        .onDateChange((date) => {
          this.birthdayTempDate = TimeUtils.formatDate(date, 'YYYY-MM-DD')
        })

      Button('确定')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor($r('app.color.app_theme'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .onClick(() => {
          if (this.birthdayTempDate.length <= 0) {
            this.birthdayTempDate = TimeUtils.formatDate(new Date(), 'YYYY-MM-DD')
          }
          this.vm.personalBirthday = this.birthdayTempDate
          this.vm.userInfoModel.authorBirthday = this.birthdayTempDate;
          this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
          this.vm.showBirthdaySheet = false
        })
        .margin({ top: CommonConstants.PADDING_L })
    }
    .padding({
      right: CommonConstants.PADDING_L,
      left: CommonConstants.PADDING_L,
      bottom: CommonConstants.PADDING_L + this.vm.windowModel.windowBottomPadding
    })
  }

  @Builder
  modifyRegionSheet() {
    Column() {
      Column() {
        TextArea({ text: $$this.vm.personalRegion, placeholder: '设置地区,发现同乡~~' })
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .placeholderColor($r('sys.color.font_tertiary'))
          .showCounter(true)
          .backgroundColor(Color.White)
          .placeholderFont({ size: 16 * this.vm.settingInfo.fontSizeRatio })
          .margin({ top: 12 })
          .maxLength(50)
          .height(156)
        Column() {
          Button('确定')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .width('100%')
            .backgroundColor($r('app.color.app_theme'))
            .onClick(() => {
              this.vm.modifyPersonalRegion();
              this.vm.dataCompleteness = this.vm.getDataCompleteness(this.vm);
            })
        }
        .padding({ bottom: this.vm.keyHeight })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }
}

@Extend(Row)
function innerCard(height: number | string = CommonConstants.FULL_PERCENT) {
  .width(CommonConstants.FULL_PERCENT)
  .padding(CommonConstants.PADDING_S)
  .borderRadius($r('app.float.large_radius'))
  .height(height)
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Row)
function outerCard(height: number = 56) {
  .width(CommonConstants.FULL_PERCENT)
  .borderRadius($r('app.float.large_radius'))
  .height(height)
  .padding(CommonConstants.PADDING_XS)
  .backgroundColor($r('sys.color.comp_background_primary'))
}
