import { AppStorageV2, CircleShape, PersistenceV2 } from '@kit.ArkUI';
import { LoginSheetUtils } from 'lib_account';
import { CommonConstants, TabModel, UserInfoModel, WindowModel } from 'lib_common';
import { MessageServiceApi } from 'lib_takeaway_api';
import { TabBarItem, TabBarType, TABS_INFO } from '../common/Constants';

@ComponentV2
export struct CustomTabBar {
  @Param fontSizeRatio: number = 0;
  @Consumer() selectedIndex: number = TabBarType.HOME;
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  tabModel: TabModel = AppStorageV2.connect(TabModel, () => new TabModel())!;
  @Param maxCount: number = 99;
  @Param badgeH: number = 8;

  aboutToAppear(): void {
    MessageServiceApi.getUnReadMessageNum().then((num) => {
      this.userInfoModel.unReadMsgNum = num;
    });
  }

  getTabImage(item: TabBarItem): ResourceStr {
    if (this.selectedIndex === item.id) {
      return item.selectActiveIcon
    }
    return item.activeIcon
  }

  getTabColor(id: number): ResourceColor {
    if (this.selectedIndex === id) {
      return $r('app.color.app_theme')
    }
    return $r('sys.color.font_tertiary')
  }

  getBgColor(): ResourceColor {
    return $r('sys.color.background_primary');
  }

  build() {
    Row() {
      ForEach(TABS_INFO, (item: TabBarItem) => {
        Column({ space: CommonConstants.SPACE_XS }) {
          if (item.id === TabBarType.MESSGE) {
            RelativeContainer() {
              Row() {
                Image(this.getTabImage(item))
                  .width($r('app.float.normal_img_size'))
                  .draggable(false)
                  .objectFit(ImageFit.Contain)
              }.id('message_dot')

              Row() {
                Text('')
                  .width(this.badgeH)
                  .height(this.badgeH)
                  .clipShape(new CircleShape({ width: this.badgeH, height: this.badgeH }))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .backgroundColor($r('sys.color.warning'))
                  .textAlign(TextAlign.Center)
              }
              .alignRules({
                right: { anchor: 'message_dot', align: HorizontalAlign.End },
                top: { anchor: 'message_dot', align: VerticalAlign.Top }
              })
              .visibility(this.userInfoModel.unReadMsgNum <= 0 ? Visibility.None : Visibility.Visible)
            }.width('auto')
            .height('auto')
          } else {
            Image(this.getTabImage(item))
              .width($r('app.float.normal_img_size'))
              .draggable(false)
              .objectFit(ImageFit.Contain)
          }
          Text(item.title)
            .fontSize(10 * this.fontSizeRatio)
            .fontColor(this.getTabColor(item.id))
        }
        .layoutWeight(1)
        .padding({ top: CommonConstants.PADDING_XS, bottom: CommonConstants.PADDING_XS })
        .onClick(() => {
          if (!this.userInfoModel.isLogin && (item.id === TabBarType.MESSGE || item.id === TabBarType.CART)) {
            LoginSheetUtils.open()
            return
          }
          this.selectedIndex = item.id;
        })
      }, (v: TabBarItem) => v.id.toString())
    }
    .backgroundColor(this.getBgColor())
    .width(CommonConstants.FULL_PERCENT)
    .padding({ bottom: this.windowModel.windowBottomPadding })
  }
}