import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { CommonConstants } from 'foundation';
import { EditPersonalInfoVM } from '../viewmodels/EditPersonalInfoVM';

@Builder
export function EditPersonalInfoBuilder() {
  EditPersonalInfo()
}

@ComponentV2
struct EditPersonalInfo {
  @Local vm: EditPersonalInfoVM = new EditPersonalInfoVM();

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          this.userIconBuilder()
          this.nickNameBuilder()
        }
        .padding({
          top: 12,
          left: 16,
          right: 16,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('个人信息', { backgroundColor: Color.White })
    .onBackPressed(() => {
      return this.vm.customBack();
    })
  }

  @Builder
  userIconBuilder() {
    Row() {
      Row() {
        Text('头像')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: 4 }) {
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.vm.userInfo.avatar ? this.vm.userInfo.avatar :
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
              if (err) {
                this.vm.handleAvatarError(err);
                return;
              }
              if (data) {
                this.vm.saveUserIcon(data.avatarUri!);
              }
            }),
          })
          Image($r('app.media.ic_public_arrow_right'))
            .width(12)
            .fillColor($r('app.color.common_grey'))
            .draggable(false)
        }
      }
      .innerCard()
    }
    .outerCard()
  }

  @Builder
  nickNameBuilder() {
    Row() {
      Row() {
        Text('昵称')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
        Row({ space: 4 }) {
          Text(this.vm.userInfo.nickName)
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .constraintSize({ maxWidth: '80%' })
          Image($r('app.media.ic_public_arrow_right'))
            .width(12)
            .fillColor($r('app.color.common_grey'))
            .draggable(false)
        }
      }
      .innerCard()
    }
    .outerCard()
    .onClick(() => {
      this.vm.nickName = this.vm.userInfo.nickName;
      this.vm.showNickNameSheet = true;
    })
    .bindSheet($$this.vm.showNickNameSheet, this.modifyNameSheet(), {
      title: { title: '设置昵称' },
      height: SheetSize.MEDIUM,
      showClose: true,
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      preferType: SheetType.CENTER,
    })
  }

  @Builder
  modifyNameSheet() {
    Column() {
      Column() {
        TextInput({ text: $$this.vm.nickName })
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .cancelButton({ style: CancelButtonStyle.INPUT, icon: { size: 16 } })
          .maxLength(20)
          .showCounter(true)
          .height(40)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('app.color.common_theme_color'))
            .width('100%')
            .onClick(() => {
              this.vm.modifyNickName();
            })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: 16,
      right: 16,
      bottom: 30,
    })
  }
}

@Extend(Row)
function innerCard(height: number | string = CommonConstants.FULL_PERCENT) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(8)
  .borderRadius(16)
  .justifyContent(FlexAlign.SpaceBetween)
}

@Extend(Row)
function outerCard(height: number = 56) {
  .width(CommonConstants.FULL_PERCENT)
  .height(height)
  .padding(4)
  .borderRadius(16)
  .backgroundColor($r('sys.color.comp_background_primary'))
}