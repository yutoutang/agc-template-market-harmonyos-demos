import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from 'business_setting';
import { mineGridList, orderGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';
import { MemberGrade } from 'lib_takeaway_api/src/main/ets/database/AuthorType';
import { LoginSheetUtils } from 'lib_account';

@Builder
export function MinePageBuilder() {
  MinePage()
}

@ComponentV2
struct MinePage {
  @Local vm: MineViewModel = new MineViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '我的',
          isSubTitle: false,
          rightPartBuilder: () => {
            this.contactUsBuilder()
          },
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.loginCard()
            this.gridCard()
            this.orderCard()
            this.listCard()
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: CommonConstants.PADDING_PAGE,
          right: CommonConstants.PADDING_PAGE,
          top: CommonConstants.SPACE_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor(Color.Transparent)
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
  }

  @Builder
  loginCard() {
    Column() {
      if (this.vm.userInfoModel.isLogin) {
        Column() {
          Row({ space: CommonConstants.SPACE_L }) {
            Image(this.vm.userIcon)
              .width($r('app.float.user_icon_width'))
              .clipShape(new CircleShape({ width: 48, height: 48 }))
              .draggable(false)
            Column({ space: CommonConstants.SPACE_XXS }) {
              Text(this.vm.userInfoModel.authorNickName)
                .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Image($r('app.media.ic_right'))
              .width($r('app.float.arrow_right_w'))
              .draggable(false)
          }
          .borderRadius($r('app.float.large_radius'))
          .padding(CommonConstants.PADDING_S)
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .onClick(() => {
            this.vm.jumpMine();
          })

          Divider().width(CommonConstants.FULL_PERCENT)
          Row({ space: CommonConstants.SPACE_L }) {
            Text('多种会员特权任享！')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)

            // 会员中心按钮
            Button(this.vm.userInfoModel.authorMemberGrade)
              .height(28)
              .backgroundColor(this.getMemberGradeBackGroundColor(this.vm.userInfoModel.authorMemberGrade))
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
          }
          .padding(CommonConstants.PADDING_S)
          .onClick(() => {
            this.vm.jumpMemberCenter();
          })
        }

      } else {
        Row({ space: CommonConstants.SPACE_L }) {
          Image($r('app.media.ic_user_unlogin'))
            .width($r('app.float.user_icon_width'))
            .draggable(false)
          Column({ space: CommonConstants.SPACE_XXS }) {
            Text('点击登录')
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)

            Text('登录后享受更多服务')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Image($r('app.media.ic_right'))
            .width($r('app.float.arrow_right_w'))
            .draggable(false)
        }
        .borderRadius($r('app.float.large_radius'))
        .padding(CommonConstants.PADDING_S)
        .stateStyles({
          normal: this.normalStyles,
          pressed: this.pressedStyles,
        })
        .onClick(() => {
          this.vm.jumpLogin();
        })
      }

    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .width(CommonConstants.FULL_PERCENT)
    .padding(CommonConstants.PADDING_XS)
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  gridCard() {
    Column() {
      Grid() {
        ForEach(mineGridList, (v: MineGridItem, index: number) => {
          GridItem() {
            Column() {
              Image(v.icon)
                .width($r('app.float.grid_icon_width'))
                .draggable(false)
              Text(v.label)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
            left: CommonConstants.PADDING_XS,
            right: CommonConstants.PADDING_XS,
          })
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              LoginSheetUtils.open()
              return
            }
            this.vm.gridClick(v, index);
          })
        }, (v: MineGridItem, index: number) => JSON.stringify(v))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(76)
      .columnsTemplate('1fr 1fr 1fr 1fr')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
  }

  @Builder
  orderCard() {
    Column() {
      Text('订单')
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, left: 10 })

      Grid() {
        ForEach(orderGridList, (v: MineGridItem, index: number) => {
          GridItem() {
            Column() {
              Image(v.icon)
                .width($r('app.float.grid_icon_width'))
                .draggable(false)
              Text(v.label)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(CommonConstants.FULL_PERCENT)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .borderRadius($r('app.float.large_radius'))
          .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles,
          })
          .padding({
            top: CommonConstants.PADDING_S,
            bottom: CommonConstants.PADDING_S,
            left: CommonConstants.PADDING_XXS,
            right: CommonConstants.PADDING_XXS,
          })
          .onClick(() => {
            this.vm.gridClick(v, index);
          })
        }, (v: MineGridItem, index: number) => JSON.stringify(v))
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(76)
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  listCard() {
    Column({ space: CommonConstants.SPACE_M }) {
      Text('常用服务')
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      SettingCard({
        list: this.vm.serviceList,
        isLogin: this.vm.userInfoModel.isLogin,
        canSlide: false
      })
    }
    .margin({ top: CommonConstants.PADDING_XS })
    .alignItems(HorizontalAlign.Start)
  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }

  // 客服问答
  @Builder
  contactUsBuilder() {
    Row({ space: CommonConstants.SPACE_S }) {
      Row() {
        Image($r('app.media.contactUs')).width($r('app.float.head_icon_width')).fillColor($r('sys.color.font_primary'))
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              LoginSheetUtils.open()
              return
            }
            RouterUtils.pushPathByName(RouterMap.MINE_CUSTOMER_SERVICE)
          })
      }
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius('50%')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)

  }

  getMemberGradeBackGroundColor(grade: string): string | Resource {
    if (grade === MemberGrade.LV1) {
      return '#FF6B6B6B'
    } else if (grade === MemberGrade.LV2) {
      return '#FFB17015'
    }
    return $r('app.color.app_theme');
  }
}