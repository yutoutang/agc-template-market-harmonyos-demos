import {
  iData,
  routerStack,
  RouterMap,
  Style,
  BreakpointSystem,
  BreakpointTypeEnum,
} from 'lib_foundation';
import { promptLogin } from 'module_login';
import { AddressManage } from 'module_address_manage';
import { ContainerColumn, NavTitleBar } from 'lib_widget';
import { MainMenuItem, SubMenuItem } from '../commons/Types';
import { ProfileUtil } from '../utils/ProfileUtil';
import { MainMenuOption } from '../commons/Enums';
import { LengthMetrics, router } from '@kit.ArkUI';

@Builder
export function buildProfilePage() {
  ProfilePage();
}

@Entry
@ComponentV2
export struct ProfilePage {
  build() {
    Column() {
      NavTitleBar({
        title: '我的',
      })

      Scroll() {
        Column({ space: 12 }) {
          if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG) {
            Flex({ space: { main: LengthMetrics.vp(16) } }) {
              Row() {
                buildUserInfoArea()
              }
              .tabletContainerStyle(iData.global.isLogin)

              Row() {
                buildMainMenuArea()
              }
              .tabletContainerStyle(iData.global.isLogin)
            }
          } else {
            buildUserInfoArea()
            buildMainMenuArea()
          }

          buildOrderInfoArea()
          buildSubMenuArea()
        };
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .padding({ left: $r('app.string.space_l'), right: $r('app.string.space_l') })
    }
    .height('100%')
    .width('100%')
    .linearGradient({
      colors: [['#33e64566', 0], ['#00E64566', 0.4]],
    })
    .backgroundColor(Style.BACKGROUND_COLOR_GREY)
    .alignItems(HorizontalAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP]);
  }
}

@Builder
function buildUserInfoArea() {
  ContainerColumn({ bottomGap: false }) {
    Row() {
      Image(iData.global.userInfo.avatar ? iData.global.userInfo.avatar : $r('app.media.default_avatar'))
        .width(48)
        .height(48)
        .borderRadius(48)
        .draggable(false)
        .margin({ right: 16 });
      Column() {
        Text(iData.global.isLogin ?
          iData.global.userInfo.nickname ? iData.global.userInfo.nickname : '华为用户' :
          '未登录',
        )
          .fontWeight(FontWeight.Medium)
          .fontSize(18)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .fontColor(Style.FONT_COLOR_LEVEL1);
        Row() {
          if (iData.global.isLogin) {
            Image($r('app.media.ic_mobile_phone'))
              .commonIconStyle()
              .margin({ right: 8 });
            Text(iData.global.userInfo.anonymousPhone).commonLabelStyle();
          } else {
            Text('登录后享受更多服务')
              .commonLabelStyle()
              .fontColor(Style.FONT_COLOR_LEVEL1);
          }
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center);
      }
      .layoutWeight(1)
      .height(48)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround);

      if (!iData.global.isLogin) {
        Image($r('app.media.ic_arrow_right')).commonIconStyle();
      }
    }
    .onClick(() => {
      if (!iData.global.isLogin) {
        promptLogin();
      } else {
        routerStack.pushPath({ name: RouterMap.USER_PROFILE_EDIT });
      }
    })

    if (iData.global.isLogin) {
      Divider().margin({ top: $r('app.float.space_m'), bottom: $r('app.float.space_m') })
      Row() {
        Text('签到可领取积分兑换好物').fontSize(14).fontColor($r('app.color.font_color_level1'))
        Button('前往签到')
          .controlSize(ControlSize.SMALL)
          .backgroundColor($r('app.color.theme_color'))
          .onClick(() => {
            routerStack.pushPath({ name: RouterMap.USER_MEMBER_BENEFITS })
          })
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}

@Builder
function buildMainMenuArea() {
  Row() {
    ForEach(ProfileUtil.MAIN_MENU_LIST, (item: MainMenuItem) => {
      if (item.type === MainMenuOption.ADDRESS) {
        AddressManage({
          navPathStack: routerStack,
          onBeforeNavigate: () => {
            if (!iData.global.isLogin) {
              promptLogin();
              return false;
            }
            return true;
          },
        }) {
          Column() {
            Image(item.icon)
              .width(40)
              .height(40)
            Text(item.label).commonLabelStyle()
          }
        };
      } else {
        Column() {
          Image(item.icon)
            .width(40)
            .height(40)
          Text(item.label).commonLabelStyle()
        }
        .onClick(() => {
          ProfileUtil.handleMainMenuClick(item.type)
        })
      }
    }, (item: MainMenuItem) => item.label)
  }
  .containerStyle()
  .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
    FlexAlign.SpaceBetween :
    FlexAlign.SpaceAround)
}

@Builder
function buildOrderInfoArea() {
  Column() {
    Row() {
      Text('我的订单')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Style.FONT_COLOR_LEVEL1);
      Blank();
      Text('全部').commonLabelStyle().margin({ right: 4 }).fontColor($r('app.color.font_color_level2'))
      Image($r('app.media.ic_arrow_right')).commonIconStyle();
    }
    .onClick(() => {
      if (!iData.global.isLogin) {
        promptLogin();
        return;
      }
      routerStack.pushPathByName(RouterMap.ORDER_LIST, 0);
    })
    .width('100%')
    .margin({ bottom: 16 });

    Row() {
      buildOrderTab($r('app.media.ic_order_pending_payment'), '待付款', 1);
      buildOrderTab($r('app.media.ic_order_pending_shipment'), '待发货', 2);
      buildOrderTab($r('app.media.ic_order_pending_receipt'), '待收货', 3);
      buildOrderTab($r('app.media.ic_order_pending_review'), '待评价', 4);
      buildOrderTab($r('app.media.ic_order_refund_after_sale'), '退款/售后', 5);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM ?
      FlexAlign.SpaceBetween :
      FlexAlign.SpaceAround);
  }
  .containerStyle();
}

@Builder
function buildSubMenuArea() {
  List({ space: 24 }) {
    ForEach(ProfileUtil.SUB_MENU_LIST, (item: SubMenuItem) => {
      ListItem() {
        Row() {
          SymbolGlyph(item.icon)
            .fontSize(24)
            .width(24)
            .height(24)
            .fontColor([$r('app.color.font_color_level1')])
            .margin({ right: 8 });

          Text(item.label).formLabelStyle();
          Blank();
          Image($r('app.media.ic_arrow_right')).commonIconStyle();
        }
        .width('100%')
        .onClick(() => {
          ProfileUtil.handleSubMenuClick(item.type)
        });
      }
    }, (item: SubMenuItem) => item.label)
  }
  .containerStyle()
  .divider({
    strokeWidth: 1,
    startMargin: 32,
  })
  .lanes(BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG ? 2 : 1, 16)
}

@Builder
function buildOrderTab(icon: ResourceStr, label: string, type: number) {
  Column() {
    Image(icon)
      .commonIconStyle()
      .width(24)
      .height(24)
      .margin({ bottom: 4 });
    Text(label)
      .commonLabelStyle()
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Start)
  .onClick(() => {
    if (!iData.global.isLogin) {
      promptLogin();
    } else {
      routerStack.pushPathByName(RouterMap.ORDER_LIST, type);
    }
  });
}

@Styles
function containerStyle() {
  .width('100%')
  .backgroundColor(Style.BACKGROUND_COLOR)
  .borderRadius(16)
  .padding(12);
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize(12)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontColor(Style.FONT_COLOR_LEVEL1);
}

@Extend(Text)
function formLabelStyle() {
  .fontWeight(FontWeight.Medium)
  .fontColor($r('app.color.font_color_level1'))
}

@Extend(Image)
function commonIconStyle() {
  .draggable(false)
  .height(16)
  .width(16)
  .fillColor(Style.FONT_COLOR_LEVEL2);
}

@Extend(Row)
function tabletContainerStyle(isLogin: boolean) {
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius(16)
  .height(isLogin ? 128 : 78)
  .alignItems(VerticalAlign.Center)
}