import { LoginSheetUtils } from 'lib_account';
import { CommonConstants } from 'lib_common';
import { IMineMsgItem } from 'lib_takeaway_api';
import { NavHeaderBar } from 'lib_widget';
import { MsgMenuItem } from '../components/MessageItem';
import { SetReadIcon } from '../components/SetReadIcon';
import { MessageViewModel } from '../viewmodels/MessageVM';

@Builder
export function MessagePageBuilder() {
  MessagePage()
}

@ComponentV2
struct MessagePage {
  @Local vm: MessageViewModel = new MessageViewModel();

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '消息',
          showBackBtn: false,
          isSubTitle: false,
          bgColor: Color.White,
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
        })
        Column() {
          if (this.vm.userInfoModel.isLogin) {
            List({ space: CommonConstants.SPACE_M }) {
              ForEach(this.vm.list, (v: IMineMsgItem) => {
                ListItem() {
                  MsgMenuItem({
                    vm: this.vm,
                    info: v,
                    fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                  })
                }
              }, (v: IMineMsgItem) => JSON.stringify(v))
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
            .align(Alignment.Top)
            .padding({
              left: CommonConstants.PADDING_S,
              right: CommonConstants.PADDING_S,
            })
          } else {
            Column() {
              Image($r('app.media.empty_status_logo'))
                .width(160)
                .height(160)
                .draggable(false)
                .objectFit(ImageFit.Cover)
                .margin({ bottom: $r('app.float.space_l') })
              Text('登陆后可同步用户信息')
                .fontSize($r('app.float.font_size_14'))
                .fontColor($r('sys.color.mask_secondary'))
              Button('登录')
                .width(100)
                .height(40)
                .backgroundColor($r('app.color.app_theme'))
                .fontColor($r('sys.color.comp_background_list_card'))
                .fontSize($r('sys.float.Body_L'))
                .fontWeight(FontWeight.Medium)
                .borderRadius($r('sys.float.corner_radius_level10'))
                .margin({ top: $r('app.float.space_m') })
                .onClick(() => {
                  LoginSheetUtils.open()
                })
              Blank().height($r('app.float.space_l'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor($r('app.color.background_color_white'))
            .borderRadius(12)
            .margin(10)
            .padding(10)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({ top: CommonConstants.PADDING_PAGE, bottom: CommonConstants.PADDING_PAGE })
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
  }

  @Builder
  rightPartBuilder() {
    SetReadIcon({
      enable: this.vm.allowClean,
      confirm: () => {
        this.vm.setAllRead();
        this.vm.userInfoModel.unReadMsgNum = 0;
      },
    })
  }
}