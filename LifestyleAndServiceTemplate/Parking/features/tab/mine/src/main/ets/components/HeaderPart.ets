import { CONTAINER_STYLE, RouterMap, RouterModule } from 'common';
import { desensitizePhoneNumber } from '../utils/Utils';
import { MinePageVM } from '../viewmodels/MinePageVM';
import { ButtonStyle } from '../constants/Constants';
import { AssociateUtil } from 'network';
import { FunctionalButton, functionalButtonComponentManager } from '@hms.core.atomicserviceComponent.atomicserviceUi';

@ComponentV2
export struct HeadPart {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Row() {
      Row({ space: 12 }) {
        Image(!this.vm.userInfo.isPhoneAssociated || this.vm.userInfo.avatar === '' ?
          $r('app.media.ic_avatar_outer') : this.vm.userInfo.avatar)
          .width(64)
          .borderRadius('50%')
          .clip(true)
        Column({ space: 8 }) {
          Text(!this.vm.userInfo.isPhoneAssociated || this.vm.userInfo.nickname === '' ?
            '华为用户' : this.vm.userInfo.nickname)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontColor($r('sys.color.font_secondary'))

          if (this.vm.userInfo.isPhoneAssociated) {
            Row({ space: 4 }) {
              Image($r('app.media.ic_phone')).width(16)
              Text(desensitizePhoneNumber(this.vm.userInfo.cellphone))
                .fontSize($r('sys.float.Caption_L'))
                .fontColor($r('sys.color.font_secondary'))
            }
          }
        }.alignItems(HorizontalAlign.Start)
      }.onClick(() => {
        AssociateUtil.checkBindPhone(() => {
          RouterModule.push({ url: RouterMap.PROFILE_EDIT });
        });
      })

      if (this.vm.userInfo.isPhoneAssociated) {
        Button('取消关联')
          .onClick(() => {
            AssociateUtil.disassociateAccount(getContext(this));
          })
          .width(ButtonStyle.buttonWidth)
          .height(ButtonStyle.buttonHeight)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_emphasize'))
          .backgroundColor(ButtonStyle.buttonBgColorBound)
      } else {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
            label: '账号关联',
            styleOption: {
              plain: true,
              styleConfig: new functionalButtonComponentManager
                .ButtonConfig()
                .width(ButtonStyle.buttonWidth)
                .height(ButtonStyle.buttonHeight)
                .fontSize(ButtonStyle.buttonTextSize)
                .fontColor(ButtonStyle.buttonTextColorUnbound)
                .backgroundColor(ButtonStyle.buttonBgColorUnbound),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController()
            .onGetPhoneNumber((err, data) => {
              AssociateUtil.associateAccount(err, data?.code);
            }),
        })
      }
    }
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
    .attributeModifier(CONTAINER_STYLE)
  }
}