import { CommonConstants, QuickLoginUtil, StringUtil, rightArrow } from '@ohos_agcit/children_education_utils';
import { User, VipRecord } from '@ohos_agcit/children_education_datasource';

@ComponentV2
export struct LoginState {
  logTag: string = 'LoginState';
  domainId: number = 0x0000;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.VIP_RECORD) vipRecord: VipRecord = new VipRecord();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();

  build() {
    Column() {
      Row() {
        Image(this.user.isLogin && StringUtil.isNotEmpty(this.user.userAvatar) ? this.user.userAvatar :
          $r('app.media.avatar'))
          .width(45)
          .height(45)
          .borderRadius(100)
          .margin({ right: 14 })
          .onClick(() => {
            if (this.user.isLogin) {
              this.appPathStack.pushPathByName('PersonalInformation', undefined);
            } else {
              QuickLoginUtil.getQuickLoginAnonymousPhone(this.getUIContext(), this.appPathStack)
            }
          });

        Column({ space: 5 }) {
          Text(this.user.isLogin ? this.user.userName : '点击登录')
            .fontSize(18)
            .lineHeight(24)
            .fontFamily('鸿蒙黑体')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.black'))
            .maxLines(1)
            .textOverflow({
              overflow: TextOverflow.Ellipsis
            })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Blank()

        rightArrow()
      }
      .height(72)
      .width(CommonConstants.FULL_PERCENT)
      .onClick(() => {
        if (this.user.isLogin) {
          this.appPathStack.pushPathByName('PersonalInformation', undefined);
        } else {
          QuickLoginUtil.getQuickLoginAnonymousPhone(this.getUIContext(), this.appPathStack)
        }
      })
      
      if (this.user.isLogin) {
        Divider()
        
        Row() {
          Text('开通VIP后享受更多服务')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
          Button('会员中心')
            .backgroundColor('#D3B685')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_M'))
            .width('30%')
            .height(28)
            .onClick(() => {
              this.appPathStack.pushPathByName('MemberShipCenterPage', undefined);
            });
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .height(56)
        .width(CommonConstants.FULL_PERCENT)
      }

    }
    .height(this.user.isLogin ? 128 : 72)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({ left: 12, right: 12 })
    .width(CommonConstants.FULL_PERCENT);
  }
}