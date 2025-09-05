import { CircleShape } from '@kit.ArkUI';
import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from 'business_setting';
import { mineGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';

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
        })
        Scroll() {
          Column({ space: CommonConstants.SPACE_M }) {
            this.loginCard()
            this.gridCard()
            this.listCard()
          }
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: CommonConstants.SPACE_M,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.vm.pagePaddingBottom,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  loginCard() {
    Column() {
      if (this.vm.userInfoModel.isLogin) {
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
            Row({ space: CommonConstants.SPACE_XS }) {
              Image($r('app.media.ic_phone'))
                .width($r('app.float.medium_img_width'))
                .draggable(false)
                .fillColor($r('sys.color.icon_secondary'))
              Text(this.vm.userInfoModel.authorPhone)
                .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))
            }
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
          this.vm.jumpProfile();
        })
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
        ForEach(mineGridList, (v: MineGridItem) => {
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
            this.vm.gridClick(v);
          })
        }, (v: MineGridItem) => v.label as string)
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
  listCard() {
    Column({ space: CommonConstants.SPACE_M }) {
      Text('常用服务')
        .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      SettingCard({
        list: this.vm.serviceList,
        enableLaneSetting: true,
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
}