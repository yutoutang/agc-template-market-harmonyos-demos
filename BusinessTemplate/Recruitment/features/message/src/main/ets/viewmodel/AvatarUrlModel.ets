import { CMChatFactory, CMChatFriendInfo } from 'instant_messaging';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { PrivateChatSettingEnum } from './PrivateChatSettingModel';

@ObservedV2
export class AvatarUrlModel {
  @Trace userId: string = '';
  @Trace contactVM: CMChatFriendInfo = new CMChatFriendInfo();

  /**
   * 获取指定好友资料
   */
  async getFriendsInfo() {
    let result = await CMChatFactory.instance.getFriendsInfo([this.userId]);
    this.contactVM = result[0];
  }

  /**
   * 跳转到好友或陌生人的聊天设置
   */
  gotoPrivateChatSetting() {
    const friendRemark = this.contactVM.friendRemark;
    let nickName = this.contactVM.nickName;
    if (friendRemark !== undefined && friendRemark.length > 0) {
      nickName = friendRemark;
    }
    // todo: 需要区分是否是好友
    let type = PrivateChatSettingEnum.FRIEND;
    ChatJumpManager.gotoPrivateChatSettingPage(type, '', this.userId, nickName, () => {
      // 在聊天设置中修改相应资料
      this.getFriendsInfo();
    })
  }
}