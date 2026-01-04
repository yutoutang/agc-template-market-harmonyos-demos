import { IMineMsgItem, MineMsgMenuType } from '../../params/response/MessageResponse';

export class MockMessage {
  static allMessageList: IMineMsgItem[] = [
    {
      id: 0,
      type: MineMsgMenuType.System,
      title: '系统消息',
      content: '亲爱的用户您好~2025.10.26 01:00:00-02:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！',
      createTime: new Date('2025-10-24 08:04:00').getTime(),
      isNewMessage: false
    },
    {
      id: 1,
      type: MineMsgMenuType.System,
      title: '系统消息',
      content: '亲爱的用户您好~2025.10.29 01:00:00-02:00:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！',
      createTime: new Date('2025-10-23 09:17:00').getTime(),
      isNewMessage: true
    },
    {
      id: 2,
      type: MineMsgMenuType.Coupon,
      title: '专属优惠',
      content: '亲爱的用户您好,您有一张专属优惠卷快到期，请及时消费',
      createTime: new Date('2025-07-22 15:10:00').getTime(),
      isNewMessage: false
    },
    {
      id: 3,
      type: MineMsgMenuType.Order,
      title: '订单通知',
      content: '亲爱的用户您好~您与2025.07.26 18:00:00购买的商品订单已完成，请及时查看',
      createTime: new Date('2025-07-21 15:24:00').getTime(),
      isNewMessage: false
    },
    {
      id: 4,
      type: MineMsgMenuType.Envelope,
      title: '红包到期通知',
      content: '亲爱的用户您好~您有一张红包到期，请及时查看',
      createTime: new Date('2025-07-20 13:17:00').getTime(),
      isNewMessage: false
    }
  ];
}