import { MinePageVM } from '../viewmodels/MinePageVM';
import { AvatarButton } from '../components/AvatarButton';
import { CommonButton, CommonConstants, CommonHeader, CONTAINER_STYLE_CALC_WIDTH, WindowUtil } from 'common';
import { desensitizePhoneNumber } from '../utils/Utils';

@ComponentV2
export struct ProfileEditPage {
  vm: MinePageVM = MinePageVM.instance;
  @Local newName: string = this.vm.userInfo.nickname;
  controller: TextInputController = new TextInputController();

  build() {
    NavDestination() {
      Column() {
        /** 标题 **/
        CommonHeader({ title: '个人信息' })

        Scroll() {
          Column() {
            /** 修改头像 **/
            this.editAvatarBuilder()

            Column() {
              /** 修改昵称 **/
              this.editNameBuilder()

              Divider().color($r('sys.color.comp_divider')).margin({ top: 20, bottom: 20 })

              /** 关联电话 **/
              this.editPhoneBuilder()
            }
            .attributeModifier(CONTAINER_STYLE_CALC_WIDTH)

            Blank().layoutWeight(1)
          }.padding({ bottom: $r('app.string.padding_6') })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .margin({ bottom: $r('app.string.margin_8') })

        CommonButton({
          title: '保存',
          handleClick: () => {
            this.vm.saveEdit(this.newName);
          },
        })
      }
    }
    .hideTitleBar(true)
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
    .backgroundColor($r('app.color.system_color_background_gray'))
  }

  @Builder
  editAvatarBuilder() {
    Row() {
      Text('头像').titleStyle()
      Blank().layoutWeight(1)
      AvatarButton().margin({ right: 2 })
    }
    .attributeModifier(CONTAINER_STYLE_CALC_WIDTH)
    .margin({ top: $r('app.string.margin_12'), bottom: $r('app.string.margin_12') })
  }

  @Builder
  editNameBuilder() {
    Row() {
      Text('昵称').titleStyle()
      TextInput({ text: $$this.newName, placeholder: '华为用户', controller: this.controller })
        .id('input1')
        .maxLength(8)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({
          weight: FontWeight.Medium,
          size: $r('sys.float.Body_L'),
        })
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_L'))
        .padding({
          left: 0,
          right: 2,
          top: 0,
          bottom: 0,
        })
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
    }
    .width(CommonConstants.FULL_WIDTH)
    .margin({ top: $r('app.string.margin_4') })
  }

  @Builder
  editPhoneBuilder() {
    Row() {
      Text('电话').titleStyle()
      Blank().layoutWeight(1)
      Text(desensitizePhoneNumber(this.vm.userInfo.cellphone)).textStyle().margin({ right: 2 })
    }
    .width(CommonConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: $r('app.string.margin_4') })
  }
}

@Extend(Text)
function titleStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Subtitle_M'))
  .fontColor($r('sys.color.font_primary'))
}

@Extend(Text)
function textStyle() {
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_secondary'))
}

@Builder
export function profileEditPageBuilder() {
  ProfileEditPage()
}