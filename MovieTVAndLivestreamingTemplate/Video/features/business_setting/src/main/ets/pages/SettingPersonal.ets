import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingPersonalVM } from '../viewmodels/SettingPersonalVM';

@Builder
export function SettingPersonalBuilder() {
  SettingPersonal()
}

@ComponentV2
struct SettingPersonal {
  @Local vm: SettingPersonalVM = new SettingPersonalVM();
  @Local selectUris: string[] = [];
  @Local currentUri: string = '';

  aboutToAppear(): void {
    this.vm.registerKeyboard();
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
              this.phoneBuilder()
            }
          }
          .listStyle()
        }
        .padding({
          top: CommonConstants.PADDING_M,
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .padding(17)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.vm.customBack();
      return true;
    })
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  @Builder
  userIconBuilder() {
    Row() {
      Row() {
        Text('头像')
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
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
                  .width(40)
                  .height(40)
                  .borderRadius(50)
                  .backgroundColor('#E5E5E5'),
              },
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (data) {
                this.vm.saveUserIcon(data.avatarUri!);
              }
            }),
          })
          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
        .accessibilityLevel('yes')
        .accessibilityText('切换头像')
      }
      .innerCard()
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
    }
    .outerCard()
  }

  @Builder
  nickNameBuilder() {
    Row() {
      Text('昵称')
        .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Row({ space: CommonConstants.SPACE_XS }) {
        Text(this.vm.userInfoModel.authorNickName)
          .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
          .constraintSize({ maxWidth: '80%' })
        Image($r('app.media.ic_right'))
          .width($r('app.float.arrow_right_w'))
          .draggable(false)
      }
    }
    .innerCard(48)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      this.vm.nickName = this.vm.userInfoModel.authorNickName;
      this.vm.showNickNameSheet = true;
    })
    .bindSheet($$this.vm.showNickNameSheet, this.modifyNameSheet(), {
      title: { title: '设置昵称' },
      height: this.vm.defaultSheetH,
      detents: [this.vm.defaultSheetH, SheetSize.MEDIUM],
      showClose: true,
      keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
      preferType: SheetType.CENTER
    })
  }

  @Builder
  phoneBuilder() {
    Row() {
      Text('uid')
        .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Row({ space: CommonConstants.SPACE_XS }) {
        Text(this.vm.userInfoModel.authorUid)
          .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
    .innerCard(48)
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
  }

  @Builder
  modifyNameSheet() {
    Column() {
      Column() {
        TextInput({ text: $$this.vm.nickName })
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 16 } })
          .maxLength(20)
          .showCounter(true)
          .height(40)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .onClick(() => {
              this.vm.modifyNickName();
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
      right: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }

  @Builder
  modifyPhoneSheet() {
    Column() {
      Column() {
        TextInput({ text: $$this.vm.contactPhone })
          .type(InputType.PhoneNumber)
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 16 } })
          .maxLength(11)
          .showCounter(true)
          .height(40)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .onClick(() => {
              this.vm.modifyContactPhone();
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
      right: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }

  @Builder
  modifyPersonalDescSheet() {
    Column() {
      Column() {
        TextArea({ text: $$this.vm.personalDesc, placeholder: '简单介绍一下自己吧~~' })
          .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: 16 * this.vm.settingInfo.fontSizeRatio })
          .maxLength(70)
          .showCounter(true)
          .height(156)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .onClick(() => {
              this.vm.modifyPersonalDesc();
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
      right: CommonConstants.PADDING_PAGE,
      bottom: this.vm.windowModel.windowBottomPadding
    })
  }
}

@Extend(Row)
function innerCard(height: number | string = CommonConstants.FULL_PERCENT) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_S)
  .borderRadius($r('app.float.large_radius'))
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(List)
function listStyle() {
  .width(CommonConstants.FULL_PERCENT)
  .borderRadius($r('app.float.large_radius'))
  .padding(CommonConstants.PADDING_XS)
  .backgroundColor($r('sys.color.comp_background_primary'))
  .divider({
    strokeWidth: 0.5,
    color: $r('sys.color.comp_divider'),
    startMargin: CommonConstants.PADDING_M,
    endMargin: CommonConstants.PADDING_M,
  })
}

@Extend(Row)
function outerCard(height: number = 56) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(CommonConstants.PADDING_XS)
  .borderRadius($r('app.float.large_radius'))
  .backgroundColor($r('sys.color.comp_background_primary'))
}