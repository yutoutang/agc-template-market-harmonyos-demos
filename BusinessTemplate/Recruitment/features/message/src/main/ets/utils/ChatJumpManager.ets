import { ChatContentSingleModel } from 'chat_base';
import { RouterMap, TValueType } from 'common';
import { CMChatConversation, CMChatConversationType } from 'instant_messaging';
import { phoneRouterControl } from 'oh_router';
import { CheckFullImagePageBuilder } from '../view/CheckFullImagePage';
import { MessageChatPageBuilder } from '../view/MessageChatPage';
import { VideoPageViewBuilder } from '../view/VideoPageView';

export class ChatJumpManager {
  /**
   * 跳转到单聊聊天页面
   */
  static gotoC2CChatPage(userId: string, isBackTop?: boolean) {
    if (userId.length === 0) {
      return;
    }

    let messageVM = new CMChatConversation();
    messageVM.userId = userId;
    messageVM.conversationID = 'c2c_' + userId;
    messageVM.type = CMChatConversationType.CHAT_C2C;
    if (isBackTop === undefined) {
      messageVM.isBackTop = true;
    } else {
      messageVM.isBackTop = isBackTop;
    }
    phoneRouterControl.jumpPage({
      pageName: RouterMap.MESSAGE_CHAT_PAGE,
      builder: wrapBuilder(MessageChatPageBuilder),
      param: messageVM as TValueType
    })
  }

  /**
   * 点击视频消息跳转查看视频页面
   */
  static gotoVideoPage(chatVM: ChatContentSingleModel, videoMutyStatus: boolean = true) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIDEO_PAGE_VIEW,
      param: {
        'videoChatSrc': chatVM.videoChatSrc,
        'videoMutyStatus': videoMutyStatus
      } as Record<string, string | boolean>,
      builder: wrapBuilder(VideoPageViewBuilder)
    })
  }

  /**
   * 点击图片消息跳转查看图片页面
   */
  static gotoFullImagePage(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.FULL_IMAGE_PAGE,
      param: chatVM.imageInfo![0].url,
      builder: wrapBuilder(CheckFullImagePageBuilder)
    })
  }
}