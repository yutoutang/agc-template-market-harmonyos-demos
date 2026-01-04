import { BusinessError } from '@kit.BasicServicesKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { GlobalContext, UserInfo } from 'common';
import {
  CMChatConversation,
  CMChatConversationOperationResult,
  CMChatConversationResult,
  CMChatConversationType,
  CMChatFactory
} from 'instant_messaging';
import { DeleteMsgModel, dialogDeleteMsgBuilder } from '../components/DeleteMsgDialog';
import { MessageUtil } from '../utils/MessageUtil';

@ObservedV2
export class MessageListModel extends CMChatConversationResult {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace topCount: number = 0;
  scroller: ListScroller = new ListScroller();
  timerId: number = 0;
  clickCount: number = 0;

  /**
   * 获取会话列表
   */
  async getConversationListByFilter() {
    clearTimeout(this.timerId);
    this.clickCount++;
    if (this.clickCount >= 2) {
      this.clickCount = 0;
      return;
    } else {
      this.timerId = setTimeout(() => {
        this.clickCount = 0;
      }, 1000);
    }

    let result = await CMChatFactory.instance.getConversationListByFilter(0);
    this.nextSeq = result.nextSeq;
    this.isFinished = result.isFinished;
    for (let index = 0; index < result.conversationList.length; index++) {
      const element = result.conversationList[index];
      if (element.type === CMChatConversationType.CHAT_GROUP) {
        try {
          element.memberAvatarList = MessageUtil.parseGroupAvatar(element.memberInfoList);
        } catch (err) {
          element.memberInfoList = [];
          element.memberAvatarList = [];
        }
      }
    }
    this.conversationList = result.conversationList;
  }

  /**
   * 添加会话监听器
   */
  addConversationListener() {
    CMChatFactory.instance.addConversationListener({
      onNewConversation: () => {
        this.getConversationListByFilter();
      },
      onConversationChanged: () => {
        this.getConversationListByFilter();
      }
    })
  }

  /**
   * 移除会话监听器
   */
  removeConversationListener() {
    CMChatFactory.instance.removeConversationListener()
  }

  /**
   * 会话置顶
   */
  pinConversation(ri: RepeatItem<CMChatConversation>) {
    CMChatFactory.instance.pinConversation(ri.item.conversationID, !ri.item.isPinned).then(() => {
      this.scroller.closeAllSwipeActions();
    }).catch((err: BusinessError) => {
    });
  }

  /**
   * 删除会话
   */
  deleteConversation(ri: RepeatItem<CMChatConversation>) {
    let dialogVM = new DeleteMsgModel();
    dialogVM.onValueConfirmClick = (model: Object) => {
      let msgModel: DeleteMsgModel | undefined;
      try {
        msgModel = model as DeleteMsgModel;
      } catch (err) {
      }
      CMChatFactory.instance.deleteConversationList([ri.item.conversationID], msgModel?.isDelete ?? false)
        .then((result: CMChatConversationOperationResult[]) => {
          if (result[0].resultCode === 0) {
            this.getConversationListByFilter();
          } else {
            GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
          }
        }).catch((err: BusinessError) => {
        GlobalContext.getUIContext().getPromptAction().showToast({ message: '删除失败' })
      });

    };
    dialogVM.childBuilder = dialogDeleteMsgBuilder;
    dialogVM.showPopup(dialogVM);
  }
}