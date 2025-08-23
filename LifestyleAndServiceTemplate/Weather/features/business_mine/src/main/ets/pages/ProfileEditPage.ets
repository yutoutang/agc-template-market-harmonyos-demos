import { CardAttributeUpdater, CommonButton, CommonConstants, CommonHeader, WindowUtil } from 'lib_foundation';
import { BaseTextStyleModifier } from 'lib_foundation/src/main/ets/styles/TextStyleModifier';
import { AvatarButton } from '../components/AvatarButton';
import { MineVM } from '../viewmodels/MineVM';

@ComponentV2
export struct ProfileEditPage {
  cardStyle1: CardAttributeUpdater = new CardAttributeUpdater();
  cardStyle2: CardAttributeUpdater = new CardAttributeUpdater();
  controller: TextInputController = new TextInputController();
  vm: MineVM = MineVM.instance;
  @Local newName: string = this.vm.userInfo.nickname;

  build() {
    NavDestination() {
      CommonHeader({ title: '个人设置', bgColor: $r('sys.color.background_primary') })

      Scroll() {
        Column() {
          this.editAvatarBuilder()

          Column() {
            this.editNameBuilder()

            Divider()
              .color($r('sys.color.comp_divider'))
              .margin({ top: CommonConstants.SPACE_13, bottom: CommonConstants.SPACE_13 })

            this.editPhoneBuilder()
          }
          .attributeModifier(this.cardStyle2)
          .onAttach(() => {
            this.cardStyle2.attribute?.padding({
              left: 12,
              right: 12,
              top: 14,
              bottom: 14,
            })
          })

          Blank().layoutWeight(1)
        }
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .padding({ left: CommonConstants.SPACE_16, right: CommonConstants.SPACE_16 })

      CommonButton({
        title: '保存',
        handleClick: () => {
          this.vm.saveEdit(this.newName);
        },
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ bottom: WindowUtil.getAvoidArea().bottom })
  }

  @Builder
  editAvatarBuilder() {
    Row() {
      Text('头像').attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium')).layoutWeight(1)
      AvatarButton().margin({ right: CommonConstants.SPACE_6 })
      Image($r('app.media.right_arrow')).width(7).fillColor($r('sys.color.icon_secondary'))
    }
    .attributeModifier(this.cardStyle1)
    .margin({ top: CommonConstants.SPACE_16, bottom: CommonConstants.SPACE_16 })
    .onAttach(() => {
      this.cardStyle1.attribute?.padding({
        left: 12,
        right: 12,
        top: 8,
        bottom: 8,
      });
    })
  }

  @Builder
  editNameBuilder() {
    Row() {
      Text('昵称').attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
      TextInput({ text: $$this.newName, placeholder: '', controller: this.controller })
        .id('input1')
        .maxLength(8)
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({
          weight: FontWeight.Regular,
          size: $r('sys.float.Body_M'),
        })
        .padding(0)
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize($r('sys.float.Body_M'))
        .textAlign(TextAlign.End)
        .backgroundColor(Color.Transparent)
        .layoutWeight(1)
      Image($r('app.media.right_arrow'))
        .width(7)
        .margin({ left: CommonConstants.SPACE_6 })
        .fillColor($r('sys.color.icon_secondary'))
    }
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  editPhoneBuilder() {
    Row() {
      Text('电话').attributeModifier(new BaseTextStyleModifier('font_primary/Subtitle_M/Medium'))
      Blank().layoutWeight(1)
      Text(desensitizePhoneNumber(this.vm.userInfo.cellphone))
        .attributeModifier(new BaseTextStyleModifier('font_secondary/Body_M/Regular'))
        .margin({ right: CommonConstants.SPACE_6 })
      Image($r('app.media.right_arrow')).width(7).fillColor($r('sys.color.icon_secondary'))
    }
  }
}

function desensitizePhoneNumber(phoneNum: string) {
  if (phoneNum.length === 11) {
    return phoneNum.slice(0, 3) + '****' + phoneNum.slice(7);
  }
  return phoneNum;
}

@Builder
export function profileEditPageBuilder() {
  ProfileEditPage()
}