import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatUtil } from '../utils/ChatUtil';
import { ChatBaseRow } from './ChatBaseRow';
import { phoneRouterControl } from 'oh_router';
import { RouterMap } from 'common';
import { ResumePreviewPageBuilder } from 'resume';

/**
 * 自定义消息（纯文本、表情、超链接等）
 */
@ComponentV2
export struct ChatTextRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require keyId: string;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local strArr: string[] = [];
  @Local urlArr: string[] = [];
  @Local bubbleColor: string = '#0A59F7';

  aboutToAppear(): void {
    this.resetKeyId();
  }

  @Monitor('keyId')
  resetKeyId() {
    let content = ChatUtil.arrayBufferToString(this.chatVM.customChat);
    ChatUtil.splitUrls(content, (array: string[][]) => {
      this.strArr = array[0];
      this.urlArr = array[1];
    });
    if (this.strArr[0] === '在线简历') {
      this.bubbleColor = 'transparent'
    }
  }

  @Builder
  render() {
    Column() {
      if (this.strArr[0] === '在线简历') {
        Column() {
          Row() {
            Image($r('app.media.onlineResume_icon')).width(38)
            Text(this.strArr[0]).margin({ left: 8 }).fontSize(12).fontColor('rgba(0, 0, 0, 0.90)')
          }.width('100%')

          Row() {
            Text('查看简历').fontSize(12).fontColor('rgba(0, 0, 0, 0.60)')
          }
          .width('100%')
          .height(36)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(86, 74, 247, 0.1)')
          .borderRadius(8)
          .onClick(() => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.RESUME_PREVIEW_PAGE,
              builder: wrapBuilder(ResumePreviewPageBuilder)
            })
          })
        }
        .width(232)
        .height(118)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
        .borderRadius({
          topLeft: this.chatVM.isOwner ? $r('app.float.vp_12') : $r('app.float.vp_4'),
          topRight: this.chatVM.isOwner ? $r('app.float.vp_4') : $r('app.float.vp_12'),
          bottomLeft: $r('app.float.vp_12'),
          bottomRight: $r('app.float.vp_12')
        })
        .border({ width: 1, color: 'rgba(86,74,247,0.5)', style: BorderStyle.Solid })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['rgba(86, 74, 247, 0.10)', 0.0], ['rgba(86, 74, 247, 0.0)', 1.0]]
        })
      } else {
        Text() {
          ForEach(this.strArr, (str: string, index: number) => {
            Span(str);
            if (this.urlArr.length > index) {
              Span(this.urlArr[index])
                .fontColor(this.chatVM.isOwner ? Color.White : '#0A59F7')
                .decoration({
                  type: TextDecorationType.Underline,
                  color: this.chatVM.isOwner ? Color.White : '#0A59F7'
                })
                .onClick(() => {
                  let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  ChatUtil.openUrlToWeb(context, this.urlArr[index]);
                })
            }
          }, (item: string, index: number) => `${JSON.stringify(item)}_${index}}`);
        }
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor(this.chatVM.isOwner ? Color.White : Color.Black)
        .lineHeight($r('app.float.vp_20'))
        .maxLines(-1)
        .constraintSize({
          minWidth: $r('app.float.vp_14'),
          maxWidth: this.chatMaxWidth,
          minHeight: $r('app.float.vp_20'),
          maxHeight: Infinity
        })
        .padding({
          top: $r('app.float.vp_10'),
          left: $r('app.float.vp_12'),
          bottom: $r('app.float.vp_10'),
          right: $r('app.float.vp_12')
        })
      }
    }
  }

  build() {
    ChatBaseRow({
      childBuilder: () => {
        this.render();
      },
      bubbleColor: this.bubbleColor,
      chatVM: this.chatVM,
      onChatAvatarClick: this.onChatAvatarClick
    })
  }

  @Computed
  get chatMaxWidth() {
    let tempTotal = this.chatBreakpoint.currentScreenWidth - this.chatBreakpoint.pagePadding * 2;
    return tempTotal * 0.75 - 68;
  }
}