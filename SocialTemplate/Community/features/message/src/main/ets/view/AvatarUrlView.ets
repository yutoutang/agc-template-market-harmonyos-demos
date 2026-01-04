import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { ChatBreakpoint } from 'chat_window';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import {
  BarVM,
  BreakpointModel,
  CommonHeader,
  FriendUserInfo,
  TempBarHeight,
  TValueType,
  UserInfo
} from 'common';
import { MessageChatModel } from '../viewmodel/MessageChatModel';
import { AvatarUrlModel } from '../viewmodel/AvatarUrlModel';
import { ChatSettingsViewModel } from '../viewmodel/ChatSettingsViewModel';
import { CMChatFactory } from 'instant_messaging';

/**
 * 点击头像展现个人详情页
 */
@ComponentV2
export struct AvatarUrlView {
  @Param @Require valueVM: TValueType;
  @Local avatarUrlVM: AvatarUrlModel = new AvatarUrlModel();
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local friendUserInfo: FriendUserInfo = PersistenceV2.connect(FriendUserInfo, () => new FriendUserInfo())!;
  @Param leftImageMargin: Length = this.chatBreakpoint.pagePadding;
  @Param fontWightParam: FontWeight | number = 700
  @Param isShowLeftImage: boolean = true;
  @Local messageChatVM: MessageChatModel = new MessageChatModel(this.getUIContext());
  @Local isOn: boolean = false
  chatSettingsViewModel: ChatSettingsViewModel = new ChatSettingsViewModel()
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: async () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
      let result = await CMChatFactory.instance.checkFriend([this.avatarUrlVM.userId]);
      for (let index = 0; index < result.length; index++) {
        const element = result[index];
        this.avatarUrlVM.isFriend = element.isFriend;
      }
    },
    onBackPress: () => {
      this.onReturnClick();
      return true;
    }
  })
  @Local onReturnClick: () => void = () => {
    if (this.avatarUrlVM.isFix) {
      phoneRouterControl.popPage({ popData: 'fixContact' });
    } else {
      phoneRouterControl.popPage();
    }
  }

  async aboutToAppear(): Promise<void> {
    try {
      this.avatarUrlVM.userId = this.valueVM as string;
    } catch (err) {
    }

    this.avatarUrlVM.getFriendsInfo()
    this.friendUserInfo.userInfoList.forEach((groupInfo: UserInfo) => {
      if (groupInfo.id === this.avatarUrlVM.userId) {
        this.isOn = true
      }
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }

  @Builder
  render() {
    Blank().height(BarVM.instance.staBarH);

    CommonHeader({
      title: '',
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })


    Column() {
      Row() {
        Image($r('app.media.' + this.avatarUrlVM.contactVM?.avatarUrl))
          .width(50)
          .height(50)
          .borderRadius(16)
          .margin({ right: 20 })
        Text(this.avatarUrlVM.contactVM?.friendRemark?.length > 0 ? this.avatarUrlVM.contactVM.friendRemark :
          this.avatarUrlVM.contactVM?.nickName)
          .size({ height: $r('app.float.vp_16') })
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(this.fontWightParam)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({
            left: this.isShowLeftImage ?
              this.chatBreakpoint.pagePadding / 2 :
            this.leftImageMargin
          })
      }
      .width('100%')
      .borderRadius(16)
      .padding(10)
      .margin({ top: 10 })

      Blank()
        .width('100%')
        .height(1)
        .backgroundColor('#E1E1E1')
        .padding({ left: 10, right: 10 })
        .margin({ top: 5 })
      Text('签名 ： ' + this.avatarUrlVM.contactVM.selfSignature)
        .fontSize(13)
        .fontColor($r('app.color.color_66000000'))
        .margin({ top: 10 })
    }
    .width('92%')
    .padding(10)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })
    .backgroundColor(Color.White)
    .borderRadius(16)

    if (this.avatarUrlVM.userId !== this.userInfo.id && this.avatarUrlVM.isFriend) {
      Row() {
        Text($r('app.string.chat_settings'))
          .fontSize(16)
          .fontWeight(this.fontWightParam)
          .fontColor($r('sys.color.font_primary'))
          .margin({
            left: this.isShowLeftImage ?
              this.chatBreakpoint.pagePadding / 2 :
            this.leftImageMargin
          })
        Blank()
        Image($r('app.media.next_image'))
          .width(30)
          .height(30)
      }
      .width('92%')
      .padding(10)
      .borderRadius(16)
      .backgroundColor(Color.White)
      .onClick(() => {
        //聊天设置点击事件
        this.avatarUrlVM.gotoPrivateChatSetting();
      })
      .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })

      Row() {
        Text($r('app.string.special_concern'))
          .fontSize(16)
          .fontWeight(this.fontWightParam)
          .fontColor($r('sys.color.font_primary'))
          .margin({
            left: this.isShowLeftImage ?
              this.chatBreakpoint.pagePadding / 2 :
            this.leftImageMargin
          })
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: $$this.isOn })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.isOn) {
              //不是特别关心提示音
              this.friendUserInfo.userInfoList.forEach((item: UserInfo, index: number) => {
                if (item.id === this.avatarUrlVM.userId) {
                  this.friendUserInfo.userInfoList.splice(index, 1)
                  return
                }
              })
            } else {
              //是特别关心提示音
              let userInfoId = new UserInfo()
              userInfoId.id = this.avatarUrlVM.userId
              this.friendUserInfo.userInfoList.push(userInfoId)
            }
          })
      }
      .width('92%')
      .borderRadius(16)
      .padding(10)
      .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })
      .backgroundColor(Color.White)

      Button($r('app.string.send_a_message'))
        .width('92%')
        .backgroundColor('#0A59F7')
        .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })
        .borderRadius(10)
        .onClick(() => {
          //发送消息
          this.avatarUrlVM.gotoC2CChatPage(this.avatarUrlVM.userId);
        })

    } else if (this.avatarUrlVM.userId === this.userInfo.id) {
      Button($r('app.string.send_a_message'))
        .width('92%')
        .backgroundColor('#0A59F7')
        .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })
        .borderRadius(10)
        .onClick(() => {
          //发送消息
          this.avatarUrlVM.gotoC2CChatPage(this.avatarUrlVM.userId);
        })
    } else if (!this.avatarUrlVM.isFriend) {
      Button($r('app.string.add_good_friend'))
        .width('92%')
        .backgroundColor('#0A59F7')
        .margin({ left: this.leftImageMargin, right: this.leftImageMargin, top: 20 })
        .borderRadius(10)
        .onClick(async () => {
          let result = await CMChatFactory.instance.addFriend(this.avatarUrlVM.userId, this.userInfo.nickName);
          this.avatarUrlVM.isFriend = (result.resultCode === 0);
          this.avatarUrlVM.isFix = (result.resultCode === 0);
        })
    }
  }
}

@Builder
export function AvatarUrlViewPageBuilder(valueVM: TValueType) {
  AvatarUrlView({ valueVM: valueVM })
}