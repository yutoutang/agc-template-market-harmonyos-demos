import { ChatBreakpoint, ChatContentSingleModel } from 'chat_base';
import { ChatBaseRow } from './ChatBaseRow';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * 文件消息
 */
@ComponentV2
export struct ChatFileRow {
  @Param @Require chatVM: ChatContentSingleModel;
  @Param @Require onChatAvatarClick: (chatVM: ChatContentSingleModel) => void;
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Param onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (_chatVM: ChatContentSingleModel) => {
    }

  @Computed
  get isPdf() {
    const lowerCasePath: string = this.chatVM.fileChatUrl.toLowerCase()
    return lowerCasePath.includes('pdf')
  }

  @Builder
  render() {
    Column() {
      Row() {
        Image($r('app.media.' + (this.isPdf ? 'pdf_icon' : 'docxResume_icon')))
          .size({width: 38, height: 38})
          .objectFit(ImageFit.Contain)
          .draggable(false)

        Text(this.chatVM.fileName)
          .margin({left: 8, right: 8})
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)
          .fontSize(12)
          .fontColor('#E6000000')
      }
      .width('100%')
      .height(38)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)

      Text($r('app.string.check_online_file'))
        .width('100%')
        .height(36)
        .textAlign(TextAlign.Center)
        .fontSize(12)
        .fontColor('#99000000')
        .backgroundColor('#1A564AF7')
        .borderRadius(8)
        .onClick(() => {
          this.onChatBubbleClick(this.chatVM)
        })
    }
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['rgba(86, 74, 247, 0.10)', 0.0], ['rgba(86, 74, 247, 0.0)', 1.0]]
    })
    .size({ width: 232, height: 118 })
    .borderWidth(1)
    .borderColor('#80564AF7')
    .borderRadius({
      topLeft: this.chatVM.isOwner ? $r('app.float.vp_12') : $r('app.float.vp_4'),
      topRight: this.chatVM.isOwner ? $r('app.float.vp_4') : $r('app.float.vp_12'),
      bottomLeft: $r('app.float.vp_12'),
      bottomRight: $r('app.float.vp_12')
    })
    .padding({
      top: 16,
      bottom: 16,
      right: 16,
      left: 16
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    ChatBaseRow({
      childBuilder: () => {
        this.render();
      },
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