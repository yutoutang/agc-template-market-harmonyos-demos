import { AccountUtil, RouterMap, RouterModule, UserInfoModel } from 'commonlib';

@ComponentV2
export struct VIPCard {
  @Param
  totalCount: number = 5000
  @Local userInfo: UserInfoModel = AccountUtil.getUserInfo();

  build() {
    if (AccountUtil.isLogin) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_vip_card'))
          .height(50)
          .position({ right: 0, top: 0 })
        this.cardInfoBuilder();
      }
      .height(100)
      .cardBgStyle()
    } else {
      Row() {
        Text('登录后查看会员等级')
          .fontSize($r('app.string.font_size_14'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_color_level1_invert'))
        Blank()
        Image($r('app.media.ic_right_arrow'))
          .height(16)
          .fillColor($r('app.color.background_color_white'))
      }
      .cardBgStyle()
      .onClick(() => {
        RouterModule.push({ url: RouterMap.MINE_LOGIN })
      })
    }

  }

  @Builder
  cardInfoBuilder() {
    Column() {
      if (this.userInfo.memberInfo) {
        Row() {
          Text(`${this.userInfo.nickname ? this.userInfo.nickname : '华为用户'}，您好`)
            .fontColor(Color.White)
            .fontSize($r('app.string.font_size_16'))
            .fontWeight(700)
            .margin({ right: $r('app.string.margin_s') })

          Row() {
            Image($r('app.media.icon_vip'))
              .width(12)
              .margin({ right: 2 })
            Text(this.userInfo.memberInfo.memberClassTName)
              .fontColor($r('app.color.font_color_level1_invert'))
              .fontSize($r('app.string.font_size_12'));
          }
          .borderRadius($r('app.string.border_radius_capsule'))
          .backgroundColor('#34ffffff')
          .padding($r('app.string.padding_xs'));
        }
        .alignItems(VerticalAlign.Bottom)

        Blank();

        Row() {
          Text(`${this.userInfo.memberInfo.pointBalance ?? 0} `)
            .fontColor(Color.White)
            .fontSize($r('app.string.font_size_16'))
            .fontWeight(500)
            .fontStyle(FontStyle.Italic)

          Text(`/ ${this.totalCount}`)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.icon_color_level2_invert'))
            .margin({ left: $r('app.string.margin_xs'), right: $r('app.string.margin_m') });

          Text(`距黄金级还需${this.totalCount - Number(this.userInfo.memberInfo.pointBalance)}积分`)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.icon_color_level1_invert'));
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ bottom: $r('app.string.margin_s') });

        Progress({
          value: Number(this.userInfo.memberInfo.pointBalance),
          total: this.totalCount,
          type: ProgressType.Linear,
        })
          .color('#FEF4DF')
          .style({
            strokeWidth: 8,
          })
          .width('100%')
          .backgroundColor($r('app.color.icon_color_level3_invert'));
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start);
  }
}

@Styles
function cardBgStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundImage($r('app.media.ic_vip_card_bg'))
  .backgroundImageSize(ImageSize.FILL)
  .padding($r('app.string.padding_m'))
  .borderRadius($r('app.string.border_radius_16'))
}