/**
 * @usage: 单聊/群聊聊天页面（输入、消息列表、弹窗）
 * @layout: OHPage + ChatWindowComponent + ChatInputComponent + 背景图层
 * @constraints: 键盘高度监听；IM监听注册与释放；页面返回栈处理；提示菜单桥接
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 消息聊天页
 * @subPage:
 * @component: AvatarUrlView
 * @image:
 */
import { AppStorageV2, KeyboardAvoidMode, window } from '@kit.ArkUI';
import { ChatInputComponent, ChatInputSendMessageModel } from 'chat_input';
import { ChatWindowComponent, POP_MENU_TYPE, PromptActionClass } from 'chat_window';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { MessageChatModel } from '../viewmodel/MessageChatModel';
import {
  BarVM,
  getPositionByHR,
  JobApplicationData,
  PositionInfo,
  TempBarHeight,
  TValueType
} from 'common';
import { ChatHistoryCollectionPageBuilder } from './ChatHistoryCollectionPage';
import { CMChatConversation, CMChatGroupInfo } from 'instant_messaging';
import { ChatBreakpoint, ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { ResumeEntity, ResumeSheetComponent } from 'file_management';
import { common } from '@kit.AbilityKit';

@Builder
export function MessageChatPageBuilder(valueVM: TValueType) {
  MessageChatPage({ valueVM: valueVM })
}

@ComponentV2
export struct MessageChatPage {
  @Param @Require valueVM: TValueType;
  @Local messageChatVM: MessageChatModel = new MessageChatModel(this.getUIContext());
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local showResumeSheet: boolean = false;
  @Local positionData?: PositionInfo;
  @Local jobAppData: JobApplicationData = AppStorageV2.connect(JobApplicationData, () => new JobApplicationData())!;
  @Local onceLoad: boolean = false;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local keyboardHeight: number = 0
  private currentWindow?: window.Window
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
      if (!this.onceLoad) {
        this.onceLoadData();
      }

      // 关闭键盘避让，监听键盘高度
      this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE);
      try {
        window.getLastWindow(getContext()).then((currentWindow) => {
          this.currentWindow = currentWindow
          this.currentWindow.on('keyboardHeightChange', (height: number) => {
            this.keyboardHeight = Math.max(0, px2vp(height) - this.chatBreakpoint.bottomValue);
            if (height > 0) {
              this.messageChatVM.scroller.scrollToIndex(this.messageChatVM.chatContentList.length - 1, true);
            }
          })
        })
      } catch (error) {
      }
    },
    onPageHide: () => {
      this.currentWindow?.off('keyboardHeightChange')
    },
    onBackPress: () => {
      this.onReturnClick();
      return true;
    }
  })
  @Local onReturnClick: () => void = () => {
    if (this.messageChatVM.conversationVM.isBackTop) {
      phoneRouterControl.popMulPage(phoneRouterControl.getNavPageInfoList().length)
    } else {
      phoneRouterControl.popPage();
    }
  }
  // 消息点击回调
  @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      this.messageChatVM.chatBubbleClick(chatVM);
    }
  // 头像点击回调
  @Local onChatAvatarClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
    }
  @Local cmChatGroupInfo: CMChatGroupInfo = new CMChatGroupInfo()
  // 输入组件数据回调
  @Local sendMessageAction: (content: ChatInputSendMessageModel) => void =
    (content: ChatInputSendMessageModel) => {
      this.messageChatVM.sendMessageAction(content);
    }
  //气泡菜单点击事件
  @Local onPopMenuClick: (chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) => void =
    (chatVM: ChatContentSingleModel, type: POP_MENU_TYPE) => {
      this.messageChatVM.onPopMenuClick(chatVM, type)
      PromptActionClass.closeDialog()
    }

  aboutToAppear(): void {
    try {
      this.messageChatVM.conversationVM = this.valueVM as CMChatConversation;
      this.positionData = getPositionByHR(this.messageChatVM.conversationVM.userId)
    } catch (err) {
    }
  }

  onceLoadData() {
    this.onceLoad = true;
    this.messageChatVM.getHistoryMessageList();
    this.messageChatVM.getFriendsInfo();
    this.messageChatVM.checkFriend();
    this.messageChatVM.addAdvancedMsgListener();
    setTimeout(() => {
      PromptActionClass.menuClick = this.onPopMenuClick
      PromptActionClass.getDeviceType = () => {
        return this.messageChatVM.deviceType
      }

      this.messageChatVM.audioRendererUtil.setPlayStatusCallBack(this.messageChatVM.soundStatusCallBack)
      this.messageChatVM.audioRendererUtil.init()
    }, 300)
  }

  aboutToDisappear(): void {
    this.messageChatVM.audioRendererUtil.release()
    this.messageChatVM.removeAdvancedMsgListener();
  }

  @Builder
  render() {
    Stack() {
      Column() {
        Stack() {
          ChatWindowComponent({
            onReturnClick: this.onReturnClick,
            title: this.messageChatVM.pageTitle,
            companyName: this.messageChatVM.companyName,
            positionInfo: this.messageChatVM.positionInfo,
            chatContentList: this.messageChatVM.chatContentList,
            scroller: this.messageChatVM.scroller,
            onChatBubbleClick: this.onChatBubbleClick,
            onChatAvatarClick: this.onChatAvatarClick,
          })
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .layoutWeight(1)

        ChatInputComponent({
          sendMessageAction: this.sendMessageAction,
          openResumeSheet: () => {
            this.showResumeSheet = true;
          },
        })
          .width('100%')
          .backgroundColor(Color.White)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: this.keyboardHeight
      })
      .animation({ duration: 250 })
      .bindSheet($$this.showResumeSheet, this.ResumeSheetBuilder(), {
        height: 400,
        showClose: false,
        dragBar: true,
        backgroundColor: '#FFFFFF',
        onDisappear: () => {
          this.showResumeSheet = false;
        }
      })
    }
  }

  @Builder
  ResumeSheetBuilder() {
    ResumeSheetComponent({
      positionData: this.positionData,
      onClose: () => {
        this.showResumeSheet = false;
      },
      onUpdateJobData: (resume?: ResumeEntity) => {
        this.jobAppData.updateData();
        if (resume !== undefined) {
          this.messageChatVM.copyFileToCache(this.getUIContext().getHostContext() as common.UIAbilityContext, resume)
        } else {
          // 发送自定义消息
          const sendContent: ChatInputSendMessageModel = new ChatInputSendMessageModel(ChatTypeEnum.CHAT_TYPE_CUSTOM)
          sendContent.content = '在线简历'
          this.sendMessageAction(sendContent)
        }
      }
    })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}
