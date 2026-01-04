import { BaseViewModel } from 'lib_common';
import { IMineMsgItem, MessageServiceApi, MineMsgMenuType } from 'lib_takeaway_api';

@ObservedV2
export class MessageViewModel extends BaseViewModel {
  @Trace list: IMineMsgItem[] = [];
  @Trace msgInfo: IMineMsgItem | undefined = undefined;

  constructor() {
    super();
    this.getMessageMenuList();
  }

  @Monitor('userInfoModel.isLogin')
  changeIsLogin() {
    this.getMessageMenuList();
  }

  @Monitor('userInfoModel.unReadMsgNum')
  changeUnReadMsgNum() {
    this.getMessageMenuList();
  }

  setAllRead() {
    let messageList: IMineMsgItem[] = this.list.filter(item => {
      return item.isNewMessage = true;
    })
    this.list = messageList;
  }

  getMessageMenuList() {
    MessageServiceApi.queryAllSystemInfoList().then((resp) => {
      let messageList: IMineMsgItem[] = resp.filter(item => {
        if (this.isLogin) {
          return true;
        }
        return item.type === MineMsgMenuType.System;
      })
      this.list = messageList;
    })
  }

  getMenuIcon(type: MineMsgMenuType): ResourceStr {
    switch (type) {
      case MineMsgMenuType.System:
        return $r('app.media.ic_message_system');
      case MineMsgMenuType.Order:
        return $r('app.media.ic_message_order');
      case MineMsgMenuType.Coupon:
        return $r('app.media.ic_message_youhui');
      case MineMsgMenuType.Envelope:
        return $r('app.media.ic_message_hongbao');
      default:
        return '';
    }
  }

  @Computed
  get isLogin() {
    return this.userInfoModel.isLogin;
  }

  @Computed
  get allowClean() {
    // 判断是否有未读消息
    return this.list.some(v => v.isNewMessage === false);
  }

  readMsgInfo(info: IMineMsgItem) {
    let messageList: IMineMsgItem[] = this.list.filter(item => {
      if (info.id === item.id) {
        return item.isNewMessage = true;
      }
      return item;
    })
    this.list = messageList;
  }
}