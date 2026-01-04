import { AppStorageV2 } from '@kit.ArkUI';
import { ChatBreakpoint, ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { MsgCollectItem } from './MsgCollectItem';
import { MsgCollectLocationItem } from './MsgCollectLocationItem';
import { ChatMsgCollectModel } from '../viewmodel/ChatMsgCollectModel';
import { MsgCollectUtil } from '../../../../Index';

@ComponentV2
export struct ChatHistoryCollectionComponent {
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void = (_chatVM: ChatContentSingleModel) => {};
  @Local msgCollectList: ChatMsgCollectModel[] = [];
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;

  aboutToAppear(): void {
    this.msgCollectList = MsgCollectUtil.getInstance().getCollectMsgList();
  }

  build() {
    List() {
      Repeat<ChatMsgCollectModel>(this.msgCollectList)
        .each((ri: RepeatItem<ChatMsgCollectModel>) => {
          ListItem() {
            if (ChatTypeEnum.CHAT_TYPE_LOCATION === ri.item.chatType) {
              MsgCollectLocationItem({ collectMsg: ri.item, onChatBubbleClick: this.onChatBubbleClick });
            } else {
              MsgCollectItem({ collectMsg: ri.item, onChatBubbleClick: this.onChatBubbleClick });
            }
          }
        })
        .key((item: ChatMsgCollectModel): string => item.chatId)
        .virtualScroll()
    }
    .cachedCount(2)
    .layoutWeight(1)
    .width('100%')
    .padding({
      left: this.chatBreakpoint.pagePadding,
      right: this.chatBreakpoint.pagePadding,
      bottom: this.chatBreakpoint.bottomValue,
      top: $r('app.float.vp_12')
    })
  }
}
