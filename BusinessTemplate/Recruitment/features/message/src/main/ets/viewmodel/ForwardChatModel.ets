import { PersistenceV2 } from '@kit.ArkUI';
import { ChatContentSingleModel } from 'chat_base';
import { GlobalContext, UserInfo } from 'common';
import { CMChatFactory } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { SearchContactModel } from './AddFriendModel';


@ObservedV2
export class ForwardChatModel {
  @Trace pageTitle: string = '选择聊天';
  @Trace chatModel: ChatContentSingleModel = new ChatContentSingleModel();
  @Trace contactList: SearchContactModel[] = [];
  scroller: ListScroller = new ListScroller();
  @Trace isShowBottom: boolean = false;
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  constructor() {
    this.getFriendList();
  }

  selectGroupOrContact(groupId?: string, userId?: string) {
    // todo: 弹框
    this.createForwardMessage(userId, groupId);
  }

  /**
   * 创建转发消息
   */
  async createForwardMessage(userId?: string, groupId?: string) {
    let result = await CMChatFactory.instance.createForwardMessage(this.chatModel.forwardMessage, userId, groupId);
    if (result && result.msgID.length > 0) {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '转发成功' });
      phoneRouterControl.popPage()
    } else {
      GlobalContext.getUIContext().getPromptAction().showToast({ message: '转发失败' });
    }
  }

  /**
   * 获取好友列表
   */
  async getFriendList() {
    let result = await CMChatFactory.instance.getFriendList();
    this.contactList = [];
    for (let index = 0; index < result.length; index++) {
      const element = result[index];
      let contactVM = new SearchContactModel();
      contactVM.userId = element.userId;
      if (element.friendRemark !== undefined && element.friendRemark.length > 0) {
        contactVM.nickName = element.friendRemark;
      } else {
        contactVM.nickName = element.nickName;
      }
      contactVM.normalArr.push(contactVM.nickName);
      contactVM.avatarUrl = element.avatarUrl;
      this.contactList.push(contactVM);
    }
  }
}