import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { CommonButton } from 'componentlib';
import { ProfileEditPageVM } from '../viewmodels/ProfileEditPageVM';

@ComponentV2
struct ProfileEditPage {
  vm: ProfileEditPageVM = ProfileEditPageVM.instance;

  aboutToAppear(): void {
    this.vm.cloneUserInfo();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          this.avatarEditingBuilder();
          this.nicknameEditingBuilder();
          this.realNameEditingBuilder();
          this.phoneNumberEditingBuilder();
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
        bottom: $r('app.string.padding_l'),
      })

      CommonButton({
        title: '保存',
        isLoading: this.vm.loading,
        handleClick: () => {
          this.vm.updateUserInfo();
        },
      });
    }
    .title('个人信息')
    .backgroundColor($r('app.color.background_color_grey'))
    .onBackPressed(() => {
      return this.vm.loading;
    })
  }

  @Builder
  avatarEditingBuilder() {
    Row() {
      Text('头像')
        .commonLabelStyle();
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Circle)
              .backgroundImage(this.vm.newUserInfo.avatar ? this.vm.newUserInfo.avatar :
                $r('app.media.ic_default_avatar'))
              .backgroundImageSize(ImageSize.Cover)
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.background_color_grey')),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error, data) => {
          this.vm.getAvatar(error, data)
        }),
      });
    }
    .commonContainerStyle();
  }

  @Builder
  nicknameEditingBuilder() {
    Row() {
      Text('昵称').commonLabelStyle();
      TextInput({ text: this.vm.newUserInfo.nickname, placeholder: '请输入昵称' })
        .textInputStyle()
        .maxLength(8)
        .onChange((value) => {
          this.vm.newUserInfo.nickname = value;
        });
      Image($r('app.media.ic_edit')).commonIconStyle()
    }
    .commonContainerStyle();
  }

  @Builder
  realNameEditingBuilder() {
    Row() {
      Text('姓名')
        .commonLabelStyle();

      TextInput({ text: this.vm.newUserInfo.name, placeholder: '请输入姓名' })
        .textInputStyle()
        .maxLength(8)
        .onChange((value) => {
          this.vm.newUserInfo.name = value;
        });
      Image($r('app.media.ic_edit')).commonIconStyle()
    }
    .commonContainerStyle();
  }

  @Builder
  phoneNumberEditingBuilder() {
    Row() {
      Text('手机号')
        .commonLabelStyle();

      Text(this.vm.newUserInfo.cellphone)
        .fontColor($r('app.color.font_color_level3'))
        .fontSize($r('app.string.font_size_14'))
    }
    .commonContainerStyle();
  }
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize($r('app.string.font_size_16'))
  .fontColor($r('app.color.font_color_level1'))
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
  .textAlign(TextAlign.Start)
}

@Extend(Row)
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
  .alignItems(VerticalAlign.Center)
}

@Extend(TextInput)
function textInputStyle() {
  .placeholderColor($r('app.color.font_color_level3'))
  .placeholderFont({ size: $r('app.string.font_size_14') })
  .backgroundColor($r('app.color.background_color_white'))
  .width(150)
  .textAlign(TextAlign.End)
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level2'))
  .padding({ right: $r('app.string.padding_xs') })
  .margin(0);
}

@Extend(Image)
function commonIconStyle() {
  .width(16)
  .height(16)
  .margin({ left: $r('app.string.margin_xs') })
}

@Builder
export function profileEditPageBuilder() {
  ProfileEditPage();
}