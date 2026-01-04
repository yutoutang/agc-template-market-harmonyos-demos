import { ChatEnum } from '../../constants/Constants';
import { BriefIMInfo, ChatInfoDetail } from '../../database/MessageType';
import { BriefMsgInfo, SystemDetailInfo } from '../../params/response/MessageResponse';

export class MockMessage {
  static briefCommentReplyInfo: BriefMsgInfo = {
    allUnreadCount: 10,
    receiveTime: new Date().getTime(),
    latestNews: '2号选手  评论了你的动态'
  };
  static briefIMInfo: BriefMsgInfo = {
    allUnreadCount: 3,
    receiveTime: new Date().getTime(),
    latestNews: '娱记大杂烩  私信了你'
  };
  static briefNewFansInfo: BriefMsgInfo = {
    allUnreadCount: 3,
    receiveTime: new Date().getTime(),
    latestNews: '1号选手  关注了你'
  };
  static briefSystemInfo: BriefMsgInfo = {
    allUnreadCount: 2,
    receiveTime: new Date().getTime(),
    latestNews: '亲爱的用户您好~2025.07.26 24:00:00-02:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！'
  };
  static allCommentReplyList: string[] = [];
  static chatList1: ChatInfoDetail[] = [
    {
      type: ChatEnum.Time,
      content: '14:14',
      createTime: 0,
    },
    {
      type: ChatEnum.Text,
      content: '好的设计是美的，大佬YYDS',
      createTime: 0,
    },
    {
      type: ChatEnum.Time,
      content: '07-10 14:14',
      createTime: 0,
    },
    {
      type: ChatEnum.Image,
      content: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_2.jpg',
      createTime: 0,
    },
    {
      type: ChatEnum.Text,
      content: '落日的晚霞，落日余晖可以再提亮一些，就是一张很美的壁纸！',
      isMyself: true,
      createTime: 0,
    },
  ];
  static chatList2: ChatInfoDetail[] = [
    {
      type: ChatEnum.Time,
      content: '15:15',
      createTime: 0,
    },
    {
      type: ChatEnum.Text,
      content: '好的设计是美的，大佬YYDS',
      createTime: 0,
    },
    {
      type: ChatEnum.Time,
      content: '07-15 15:15',
      createTime: 0,
    },
    {
      type: ChatEnum.Image,
      content: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/news_tra_3.jpg',
      createTime: 0,
    },
    {
      type: ChatEnum.Text,
      content: '谢谢了你的点赞',
      isMyself: true,
      createTime: 0,
    },
  ];
  static allBriefIMList: BriefIMInfo[] = [
    {
      chatAuthorId: 'author_1',
      allUnreadCount: 1,
      receiveTime: new Date().getTime(),
      latestNews: '谢谢了你的点赞',
      chatList: MockMessage.chatList1,
    },
    {
      chatAuthorId: 'author_2',
      allUnreadCount: 2,
      receiveTime: new Date().getTime(),
      latestNews: '好的设计是美的，大佬YYDS',
      chatList: MockMessage.chatList2,
    },
  ];
  static allSystemInfoList: SystemDetailInfo[] = [
    {
      content: '亲爱的用户您好~2025.07.26 24:00:00-02:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！',
      createTime: new Date('2025-07-24').getTime(),
    },
    {
      content: '亲爱的用户您好~2025.06.26 24:00:00-02:00进行安全升级，部分私信功能将无法使用，给您带来不便万分抱歉！感谢您的理解和支持！',
      createTime: new Date('2025-6-17').getTime(),
    },
  ];
}