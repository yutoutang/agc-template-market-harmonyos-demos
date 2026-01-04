import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, Constants, RouterMap, TValueType } from 'common';
import { MessageNavigationBar } from '../components/MessageNavigationBar';
import { MessageListModel } from '../viewmodel/MessageListModel';
import { MessageSingleRow } from '../components/MessageSingleRow';
import { MessageSwipeRow } from '../components/MessageSwipeRow';
import { phoneRouterControl } from 'oh_router';
import { MessageChatPageBuilder } from './MessageChatPage';
import { CMChatConversation, CMChatFactory } from 'instant_messaging';

/**
 * @usage: 消息列表页面，提供即时通讯会话列表展示和管理功能。包含会话列表展示、未读消息清理、会话删除、会话置顶、进入聊天等功能。
 * 主要数据结构包括CMChatConversation（会话信息）、MessageListModel（消息列表视图模型）。通过事件监听实现会话列表的实时更新和页面显
 * 示隐藏的生命周期管理。
 * @layout: 页面采用Stack+Column布局，顶部为渐变背景Row和MessageNavigationBar导航栏，下方为会话列表List。
 * 会话列表使用Repeat+ListItem实现虚拟滚动，每个ListItem包含MessageSingleRow组件和滑动操作（MessageSwipeRow）。支持左滑显示删除
 * 和置顶按钮。
 * @constraints: 依赖即时通讯模块（instant_messaging）
 * @domain: 招聘求职
 * @isGen: true
 * @fileType: page
 * @zhName: 消息列表页
 * @subPage: MessageChatPage
 * @component: MessageNavigationBar,MessageSingleRow,MessageSwipeRow
 * @image: screenshot/message.jpg
 */

@Builder
export function MessageListPageBuilder() {
  MessageListPage()
}

@ComponentV2
export struct MessageListPage {
  @Local messageListVM: MessageListModel = new MessageListModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local cleanUnreadMessageCount: () => void = async () => {
    // 清理所有会话的未读消息计数
    try {
      const conversationList = this.messageListVM.conversationList;
      for (const conversation of conversationList) {
        if (conversation.unreadCount > 0) {
          await CMChatFactory.instance.cleanConversationUnreadMessageCount(conversation.conversationID);
        }
      }
    } catch (err) {
    }
  }
  @Local onChatClick: (messageVM: CMChatConversation) => void = (messageVM: CMChatConversation) => {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }
  @Local onMessagePageShowChange: () => void = () => {
    this.messageListVM.getConversationListByFilter()
    this.messageListVM.addConversationListener();
  }
  @Local onMessagePageHideChange: () => void = () => {
    this.messageListVM.removeConversationListener();
  }

  aboutToAppear(): void {
    this.getUIContext().getHostContext()?.eventHub.on(Constants.onMessagePageShowChange,
      this.onMessagePageShowChange);
    this.getUIContext().getHostContext()?.eventHub.on(Constants.onMessagePageHideChange,
      this.onMessagePageHideChange);
  }

  aboutToDisappear(): void {
    this.getUIContext().getHostContext()?.eventHub.off(Constants.onMessagePageShowChange,
      this.onMessagePageShowChange);
    this.getUIContext().getHostContext()?.eventHub.off(Constants.onMessagePageHideChange,
      this.onMessagePageHideChange);
  }

  @Builder
  setSwipeBuilder(ri: RepeatItem<CMChatConversation>) {
    MessageSwipeRow({
      messageVM: ri.item,
      onDeleteClick: () => {
        this.messageListVM.deleteConversation(ri);
      },
      onTopClick: () => {
        this.messageListVM.pinConversation(ri);
      }
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row().width('100%').height(104 + BarVM.instance.staBarH)
        .linearGradient({
          angle: 0,
          colors: [['#00b8d1fe', 0.0], ['#ffcfd2ff', 1.0]]
        })
        .hitTestBehavior(HitTestMode.None)

      Column() {
        MessageNavigationBar({
          cleanUnreadMessageCount: this.cleanUnreadMessageCount
        });

        Column() {
          List({ scroller: this.messageListVM.scroller }) {
            Repeat<CMChatConversation>(this.messageListVM.conversationList)
              .each((ri: RepeatItem<CMChatConversation>) => {
                ListItem() {
                  MessageSingleRow({
                    messageVM: ri.item,
                    onChatClick: this.onChatClick
                  });
                }.swipeAction({
                  end: {
                    builder: () => {
                      this.setSwipeBuilder(ri);
                    }
                  }
                })
              })
              .key((item: CMChatConversation): string => item.conversationID)
              .virtualScroll({
                totalCount: this.messageListVM.conversationList.length
              })
              .templateId((_chatVM: CMChatConversation): string => {
                return '';
              })
          }
          .height('100%')
          .width('100%')
          .divider({
            strokeWidth: '1px',
            color: $r('sys.color.comp_divider'),
            startMargin: this.breakPointModel.pagePadding,
            endMargin: this.breakPointModel.pagePadding,
          })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
  }
}