/**
 * @usage: 展示收藏消息列表，支持位置/视频/图片/语音打开
 * @layout: OHPage + CommonHeader + ChatHistoryCollectionComponent
 * @constraints: 语音播放设备设置；播放状态判断；返回导航
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 聊天收藏页
 * @subPage: ChatHistoryCollectionComponent
 * @component: ViewLocationPage,VideoPageView,FullImagePage
 * @image:
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TempBarHeight, TValueType } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { ChatHistoryCollectionComponent } from 'chat_history_collection';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_window';
import { ViewLocationPageBuilder } from './ViewLocationPage';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { AudioRendererUtil } from '../utils/AudioRendererUtil';

@Builder
export function ChatHistoryCollectionPageBuilder() {
  ChatHistoryCollectionPage()
}

@ComponentV2
export struct ChatHistoryCollectionPage {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  audioRendererUtil: AudioRendererUtil = AudioRendererUtil.getInstance()
  @Local soundStatus: boolean = false //语音播放状态（停止/暂停/播放中）
  @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
        ChatJumpManager.gotoViewLocation(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_VIDEO) {
        ChatJumpManager.gotoVideoPage(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_IMAGE) {
        ChatJumpManager.gotoFullImagePage(chatVM);
      } else if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_SOUND) {
        if (this.soundStatus && this.audioRendererUtil.url === chatVM.soundInfo?.url) {
          this.audioRendererUtil.stop()
        } else {
          this.soundStart(chatVM)
        }
      }
    };

  /*
  * 语音开始播放
  */
  async soundStart(chatVM: ChatContentSingleModel) {
    await this.audioRendererUtil.readySoundFile(chatVM.soundInfo?.url, this.getUIContext())
    this.audioRendererUtil.setOutDevice(audio.DeviceType.EARPIECE)
    this.audioRendererUtil.start(chatVM.soundInfo?.url || '')
  }

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH);

      CommonHeader({
        title: '收藏',
        onReturnClick: this.onReturnClick
      })
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })
      ChatHistoryCollectionComponent({
        onChatBubbleClick: this.onChatBubbleClick,
      })
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  gotoViewLocation(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIEW_LOCATION_PAGE,
      builder: wrapBuilder(ViewLocationPageBuilder),
      param: chatVM as TValueType
    })
  }
}
