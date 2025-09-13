import { iData, routerStack, CallButton, RouterMap, Style } from 'lib_foundation';
import { promptLogin } from 'module_login';
import { AddressManage } from 'module_address_manage';
import { NavTitleBar } from 'lib_widget';

@Builder
export function buildProfilePage() {
  ProfilePage();
}

@ComponentV2
export struct ProfilePage {
  build() {
    Column() {
      NavTitleBar({
        title: '我的',
      })

      Scroll() {
        Column({ space: 12 }) {
          buildUserInfoArea();
          buildOrderInfoArea();
          buildMenuArea();
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
  .containerStyle()
  .onClick(() => {
    if (!iData.global.isLogin) {
      promptLogin();
    } else {
      routerStack.pushPath({ name: RouterMap.USER_PROFILE_EDIT });
    }
  });
}

@Builder
function buildOrderInfoArea() {
  Column() {
    Row() {
      Text('我的订单')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(Style.FONT_COLOR_LEVEL1);
      Blank();
      Text('全部').commonLabelStyle().margin({ right: 4 });
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
      buildOrderTab($r('app.media.ic_order_refund_after_sale'), '退款/售后', 6);
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween);
  }
  .containerStyle();
}

@Builder
function buildMenuArea() {
  Column({ space: 20 }) {
    buildMenuItem($r('app.media.ic_coupon'), '优惠券', () => {
      if (!iData.global.isLogin) {
        promptLogin();
      } else {
        routerStack.pushPath({ name: RouterMap.USER_COUPON_PAGE });
      }
    });

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
      buildMenuItem($r('app.media.ic_address_mgr'), '地址管理');
    };

    CallButton() {
      buildMenuItem($r('app.media.ic_call_center'), '联系客服');
    };

    buildMenuItem($r('app.media.ic_setting'), '设置', () => {
      routerStack.pushPathByName(RouterMap.SETTING, null);
    });
  }
  .containerStyle();
}

@Builder
function buildMenuItem(icon: ResourceStr, label: string, callback?: () => void) {
  Row() {
    Image(icon).commonIconStyle().margin({ right: 8 });
    Text(label).commonLabelStyle();
    Blank();
    Image($r('app.media.ic_arrow_right')).commonIconStyle();
  }
  .width('100%')
  .hitTestBehavior(callback ? HitTestMode.Default : HitTestMode.None)
  .onClick(() => {
    callback?.();
  });
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
      .fontSize(10);
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
  .backgroundColor(Style.BACKGROUND_COLOR)
  .borderRadius(16)
  .padding(12);
}

@Extend(Text)
function commonLabelStyle() {
  .fontSize(12)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontColor(Style.FONT_COLOR_LEVEL2);
}

@Extend(Image)
function commonIconStyle() {
  .draggable(false)
  .height(16)
  .width(16)
  .fillColor(Style.FONT_COLOR_LEVEL2);
}