import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ChatNavigationBar } from './ChatNavigationBar';
import { ChatTextRow } from './ChatTextRow';
import { ChatBreakpoint, ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { ChatUtil } from '../utils/ChatUtil';
import { ChatVideo } from './ChatVideo';
import { ChatImageRow } from './ChatImageRow';
import { ChatVoiceRow } from './ChatVoiceRow';
import { ChatFileRow } from './ChatFileRow';
import { PositionCard, PositionInfo } from 'common';

@ComponentV2
export struct ChatWindowComponent {
  @Param @Require chatContentList: ChatContentSingleModel[];
  @Param @Require onReturnClick: () => void
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Param onChatAvatarClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }
  @Param isShowRightImage: boolean = false
  @Param @Require title: string
  @Param companyName: string = ''
  @Param @Require positionInfo: PositionInfo
  @Param menuList: MenuElement[] = [];
  @Param scroller: ListScroller = new ListScroller();
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;

  aboutToAppear() {
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    ChatUtil.requestLocationPermissionsFromUser(context);
  }

  build() {
    Column() {
      ChatNavigationBar({
        title: this.title,
        companyName: this.companyName,
        onReturnClick: this.onReturnClick,
        isShowRightImage: this.isShowRightImage,
        rightImageRes: $r('app.media.chat_more'),
        fontWightParam: 700,
      })

      Column() {
        List({ space: 12, scroller: this.scroller }) {
          if (this.positionInfo) {
            ListItem() {
              PositionCard({ positionInfoData: this.positionInfo, isHideHR: true })
            }
          }

          Repeat<ChatContentSingleModel>(this.chatContentList)
            .each((_ri: RepeatItem<ChatContentSingleModel>) => {
              // 默认模板

            })
            .key((item: ChatContentSingleModel): string => item.keyId)
            .virtualScroll({
              totalCount: this.chatContentList.length
            })
            .templateId((chatVM: ChatContentSingleModel): string => {
              return chatVM.chatType.toString();
            })
            .template(ChatTypeEnum.CHAT_TYPE_CUSTOM.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 自定义消息（纯文本、表情、超链接等）
              ListItem() {
                ChatTextRow({
                  chatVM: ri.item,
                  keyId: ri.item.keyId,
                  onChatAvatarClick: this.onChatAvatarClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_IMAGE.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 图片消息
              ListItem() {
                ChatImageRow({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_File.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 文件消息
              ListItem() {
                ChatFileRow({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_SOUND.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              // 语音消息
              ListItem() {
                ChatVoiceRow({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_TYPE_VIDEO.toString(), (ri: RepeatItem<ChatContentSingleModel>) => {
              //视频展示
              ListItem() {
                ChatVideo({
                  chatVM: ri.item,
                  onChatAvatarClick: this.onChatAvatarClick,
                  onChatBubbleClick: this.onChatBubbleClick
                })
              }
            })
            .template(ChatTypeEnum.CHAT_GROUP_TIPS.toString(), (_ri: RepeatItem<ChatContentSingleModel>) => {
              // 群消息提醒
              ListItem() {
                Text('群消息提醒')
              }.height('24vp').width('100%')
            })
          ListItem().height('1vp')
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: this.chatBreakpoint.pagePadding,
        right: this.chatBreakpoint.pagePadding
      })
    }
    .width('100%')
    .height('100%')
  }
}