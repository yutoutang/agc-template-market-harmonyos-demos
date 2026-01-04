import { AppStorageV2, CircleShape } from '@kit.ArkUI';
import { BreakpointNameEnum, CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { SettingCard } from 'business_setting';
import { mineGridList } from '../constants/Constants';
import { MineGridItem } from '../types/Types';
import { MineViewModel } from '../viewmodels/MineVM';
import { SaveAllClass, SaveOneClass } from 'module_map_detail';

@Builder
export function MinePageBuilder() {
  MinePage()
}

// 初始化数据
AppStorageV2.connect(SaveAllClass, () => new SaveAllClass())!;
AppStorageV2.connect(SaveOneClass, () => new SaveOneClass())!;

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
            this.userAndFavoriteCards()
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
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
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
              Row() {
                Text(this.vm.userInfoModel.userNickName)
                  .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .constraintSize({ maxWidth: '70%' })
                Image(this.vm.userInfoModel.isVip ? $r('app.media.select_vip') : $r('app.media.vip'))
                  .width(15)
                  .aspectRatio(1)
                  .margin({ left: 5, right: 5 })
                Text(this.vm.userInfoModel.isVip ? '已开通' : '未开通')
                  .fontSize(12)
                  .fontColor(this.vm.userInfoModel.isVip ? '#205cba' : '#2f291b')
              }

              Row({ space: CommonConstants.SPACE_XS }) {
                Image($r('app.media.ic_phone'))
                  .width($r('app.float.medium_img_width'))
                  .draggable(false)
                  .fillColor($r('sys.color.icon_secondary'))
                Text(this.vm.userInfoModel.userPhone)
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
            RouterUtils.pushPathByName(RouterMap.SETTING_PERSONAL)
          })


          Divider().width(CommonConstants.FULL_PERCENT)
          Row({ space: CommonConstants.SPACE_L }) {
            Text('海量专属服务任享！')
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .layoutWeight(1)

            //会员中心按钮
            Button('会员中心')
              .height(28)
              .backgroundColor($r('app.color.app_theme'))
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .onClick(() => {
                RouterUtils.pushPathByName(RouterMap.VIPCENTER_PAGE);
              })
          }
          .padding(CommonConstants.PADDING_S)
        }.height(110)

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
        .height(80)
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
  userAndFavoriteCards() {
    if (this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM) {
      // 手机端,垂直排列
      Column({ space: CommonConstants.SPACE_M }) {
        this.loginCard()
        this.gridCard()
      }
      .width(CommonConstants.FULL_PERCENT)
    } else {
      // 折叠屏水平排列,两个卡片并排显示
      Row({ space: CommonConstants.SPACE_M }) {
        Column() {
          this.loginCard()
        }
        .layoutWeight(1)

        Column() {
          this.gridCard()
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(VerticalAlign.Top)
    }
  }

  @Builder
  gridCard() {
    Column() {
      if (this.vm.breakPointModel.currentBreakpoint !== BreakpointNameEnum.SM) {
        // 折叠屏
        if (mineGridList.length > 0) {
          Column() {
            Image(mineGridList[0].icon)
              .width(27)
              .aspectRatio(1)
              .draggable(false)
              .margin({ bottom: 10 })
            Text(mineGridList[0].label)
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
          }
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Center)
          .height(this.vm.userInfoModel.isLogin ? 110 : 80)
        }
      } else {
        // 手机端
        Grid() {
          ForEach(mineGridList, (v: MineGridItem) => {
            GridItem() {
              Column() {
                Image(v.icon)
                  .width(27)
                  .aspectRatio(1)
                  .draggable(false)
                  .margin({ bottom: 10 })
                Text(v.label)
                  .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
                  .fontColor($r('sys.color.font_primary'))
              }
              .height(CommonConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.vm.gridClick(v);
              })
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
          }, (v: MineGridItem) => v.label as string)
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(80)
        .columnsTemplate('1fr')
      }
    }
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
    })
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.large_radius'))
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      // 折叠屏时，整个卡片可点击
      if (this.vm.breakPointModel.currentBreakpoint !== BreakpointNameEnum.SM && mineGridList.length > 0) {
        this.vm.gridClick(mineGridList[0]);
      }
    })
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