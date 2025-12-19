import { getColor, getMedia, getString, NAV_PAGE_NAME } from '@agctemplate/resources'
import { appRouter, Logger } from '@agctemplate/utils'
import { RowModifier } from '../../AttributeModifiers'
import { AssociateUtil } from '../../../util/Utils'
import { MinePageVM } from '../../viewmodel/MinePageVM'
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit'


@Extend(Image)
function profileImageStyles() {
  .width(48)
  .height(48)
  .borderRadius(24)
  .draggable(false)
  .autoResize(false)
  .objectFit(ImageFit.Cover)
  .interpolation(ImageInterpolation.High)
}

@Extend(Text)
function userNameStyles() {
  .fontColor($r('sys.color.font_primary'))
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Subtitle_L'))
  .textOverflow({
    overflow: TextOverflow.Ellipsis
  })
  .maxLines(1)
}

const TAG = 'UserLogin';

@ComponentV2
export struct UserLogin {
  @Local vm: MinePageVM = MinePageVM.instance;
  @Param userInfoHandler?: Function = undefined
  rowModifier: RowModifier = new RowModifier();
  @Local isVip: boolean = false

  build() {
    Column() {
      Row({ space: 16 }) {
        Row({ space: 16 }) {
          this.profileImage()
          this.userName()
        }
        .height(64)
        .padding(8)
        .layoutWeight(1)
        .borderRadius(12)
        .attributeModifier(this.rowModifier)
        .onClick(() => {
          if (this.userInfoHandler && this.vm.userInfo.isPhoneAssociated) {
            this.userInfoHandler();
          } else {
            appRouter.push({builderName:NAV_PAGE_NAME.LoginPage.name})
          }
        })
      }

      if (this.vm.userInfo.isPhoneAssociated) {
        Divider().height(0.5).padding({ left: 12, right: 12 })
        Row() {
          Text(this.vm.userInfo.isVip ? getString('app.string.VIP_information') : getString('app.string.Non_VIP_information'))
            .fontSize(14)
            .lineHeight(19)
            .fontColor($r('sys.color.font_primary'))

          Blank()
          Button(this.vm.userInfo.isVip ? getString('app.string.VIP_button') : getString('app.string.Non_VIP_button'))
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .height(28)
            .backgroundColor('#F1D1A5')
            .onClick(()=>{
              appRouter.push({builderName:NAV_PAGE_NAME.VIPCenterPage.name})
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .height(56)
      }
    }
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(4)

  }

  // 头像
  @Builder
  profileImage() {
    Image((this.vm.userInfo.isPhoneAssociated) ?
      this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
      this.vm.userInfo.avatar : getMedia('app.media.user_login_img'))
      .profileImageStyles()
      .onError((error: ImageError) => {
        Logger.warn(TAG, 'image error')
      })
  }

  // 昵称
  @Builder
  userName() {
    Column() {
      if (this.vm.userInfo.isPhoneAssociated) {
        Text(this.vm.localInfo.nickname ? this.vm.localInfo.nickname : this.vm.userInfo.nickname)
          .userNameStyles()
      } else {
        Text('点击登录')
          .userNameStyles()
      }
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height(48)
    .layoutWeight(1)
  }

  @Builder
  accountLink() {
    if (this.vm.userInfo.isPhoneAssociated) {
      Row({ space: 4 }) {
        Image(getMedia('app.media.linked'))
          .height(16)
          .width(16)
        Text(getString('app.string.unlink'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .margin({ right: 8 })
      .height(28)
      .borderRadius(14)
      .onClick(async () => {
        await AssociateUtil.disassociateAccount(getContext(this)); //  container.resolve(LoginAPI).logout();
      })
    } else {
      Stack() {
        FunctionalButton({
          params: {
            openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
            label: '',
            styleOption: {
              plain: true,
              styleConfig: new functionalButtonComponentManager
                .ButtonConfig()
                .height(28)
                .width(92)
                .backgroundColor($r('sys.color.comp_background_tertiary')),
            },
          },
          controller: new functionalButtonComponentManager.FunctionalButtonController()
            .onGetPhoneNumber((err, data) => {
            }),
        })
          .zIndex(1)

        Row({ space: 4 }) {
          Image(getMedia('app.media.to_link'))
            .height(16)
            .width(16)
          Text(getString('app.string.to_link'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(getColor('app.color.orange'))
        }
      }
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius(14)
    }
  }
}

