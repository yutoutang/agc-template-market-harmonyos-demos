import { PersistenceV2 } from '@kit.ArkUI';
import { CommonConstants, UserInfoModel } from 'lib_common';
import { MembershipUtils } from 'lib_account';

@Builder
export function membershipOverlayBuilder(rePlay: () => void) {
  MembershipOverlay({
    rePlay: () => {
      rePlay();
    },
  })
}

@ComponentV2
export struct MembershipOverlay {
  @Event rePlay: () => void = () => {
  };
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;

  build() {
    Column({ space: CommonConstants.PADDING_M }) {
      Text('该视频内容为VIP会员专享，查看请先开通会员')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Regular)
      Button(this.userInfoModel.isLogin ? '开通会员' : '登录/开通会员')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('app.color.membership'))
        .height(28)
        .onClick(() => {
          MembershipUtils.openSheet();
        })
      Row({ space: CommonConstants.SPACE_S }) {
        SymbolGlyph($r('sys.symbol.arrow_clockwise'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(16)
        Text('重新试看')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Regular)
      }
      .onClick(() => {
        this.rePlay();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
  }
}