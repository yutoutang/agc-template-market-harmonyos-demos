import { Style } from 'lib_foundation';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { EditProfileVM } from '../viewmodels/EditProfileVM';
import { NavTitleBar } from 'lib_widget';

@ComponentV2
export struct EditProfilePage {
  @Local
  showNicknameDialog: boolean = false;
  vm: EditProfileVM = new EditProfileVM();

  aboutToAppear(): void {
    this.vm.initData();
  }

  build() {
    NavDestination() {
      NavTitleBar({ title: '我的信息' })

      Column() {
        this.editAvatarBuilder();
        this.editNicknameBuilder();
        Blank();
        Button('保存')
          .backgroundColor(Style.THEME_COLOR)
          .width('100%')
          .onClick(() => {
            this.vm.handleSave();
          });
      }
      .layoutWeight(1)
      .padding(16);
    }
    .hideTitleBar(true)
    .backgroundColor(Style.BACKGROUND_COLOR_GREY);

  }

  @Builder
  editAvatarBuilder() {
    Row() {
      Text('头像').titleStyle();
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .type(ButtonType.Circle)
              .backgroundImage(this.vm.avatar && this.vm.avatar !== '' ? this.vm.avatar :
              $r('app.media.default_avatar'))
              .backgroundImageSize(ImageSize.Cover)
              .width(28)
              .height(28)
              .borderRadius(Style.BORDER_RADIUS_CAPSULE)
              .backgroundColor(Style.BACKGROUND_COLOR_GREY),

          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((error, data) => {
          this.vm.getAvatarSrc(error, data);
        }),
      });
      Image($r('app.media.ic_arrow_right')).rightIconStyle();
    }.formContainerStyle();
  }

  @Builder
  editNicknameBuilder() {
    Row() {
      Text('昵称').titleStyle();
      Row() {
        Text(this.vm.nickname.length ? this.vm.nickname : '请输入昵称')
          .fontSize(14)
          .fontColor(Style.FONT_COLOR_LEVEL2);
        Image($r('app.media.ic_info_edit')).rightIconStyle();
      }
      .onClick(() => {
        this.showNicknameDialog = true;
      });

    }
    .formContainerStyle()
    .bindSheet($$this.showNicknameDialog, this.nicknameDialogBuilder(), {
      detents: [SheetSize.MEDIUM],
      title: { title: '设置昵称' },
      onWillDismiss: (action) => {
        this.vm.tempNickname = '';
        action.dismiss();
      },
    });
  }

  @Builder
  nicknameDialogBuilder() {
    Column() {
      TextInput({ text: this.vm.nickname, placeholder: '请输入昵称' })
        .maxLength(7)
        .backgroundColor(Style.BACKGROUND_COLOR)
        .borderRadius(16)
        .cancelButton({
          icon: {
            src: $r('app.media.ic_close'),
            color: Style.FONT_COLOR_LEVEL1,
            size: 16,
          },
        })
        .onChange((value) => {
          this.vm.tempNickname = value;
        });

      Blank();
      Button('确定')
        .width('100%')
        .backgroundColor(Style.THEME_COLOR)
        .onClick(() => {
          this.vm.nickname = this.vm.tempNickname;
          this.showNicknameDialog = false;
        });
    }
    .height('100%')
    .padding(16)
    .backgroundColor(Style.BACKGROUND_COLOR_GREY);

  }
}

@Builder
export function buildEditProfilePage() {
  EditProfilePage();
}


@Extend(Row)
function formContainerStyle() {
  .width('100%')
  .alignItems(VerticalAlign.Center)
  .backgroundColor(Style.BACKGROUND_COLOR)
  .height(64)
  .borderRadius(16)
  .padding(12)
  .margin({
    bottom: 12,
  });
}

@Extend(Text)
function titleStyle() {
  .fontColor(Style.FONT_COLOR_LEVEL1)
  .fontWeight(FontWeight.Medium)
  .layoutWeight(1)
  .margin({
    top: 4,
    bottom: 4,
  });
}

@Extend(Image)
function rightIconStyle() {
  .width(24)
  .height(24)
  .margin({ left: 4 })
  .fillColor(Style.FONT_COLOR_LEVEL2);
}