import { CommonConstants, TimeUtils } from 'lib_common';
import { IMineMsgItem } from 'lib_takeaway_api';
import { NavHeaderBar } from 'lib_widget';
import { MessageViewModel } from '../viewmodels/MessageVM';

@Builder
export function MessageInfoPageBuilder() {
  MessageInfoPage()
}

@ComponentV2
export struct MessageInfoPage {
  @Local vm: MessageViewModel = new MessageViewModel();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '消息详情',
        bgColor: $r('app.color.background_color_white')
      })
      Column() {
        this.infoItem()
      }
      .padding({
        left: 10,
        right: 10,
        top: 5,
        bottom: 5
      })
      .backgroundColor(Color.Transparent)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, IMineMsgItem> | undefined
      if (param) {
        this.vm.msgInfo = param.info as IMineMsgItem
      }
    })
  }

  @Builder
  infoItem() {
    Column({ space: CommonConstants.SPACE_S }) {
      if (this.vm.msgInfo) {
        Row({ space: CommonConstants.SPACE_S }) {
          Image(this.vm.getMenuIcon(this.vm.msgInfo.type))
            .width($r('app.float.head_icon_width'))
            .aspectRatio(1)
            .draggable(false)
          Column({ space: CommonConstants.SPACE_XXS }) {
            Text(this.vm.msgInfo.title)
              .fontSize(16 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .lineHeight(21)
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(TimeUtils.handleMsgTime(this.vm.msgInfo.createTime))
              .fontSize(12 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_secondary'))
          }
          .alignItems(HorizontalAlign.Start)
        }

        Divider()
        Text(this.vm.msgInfo.content)
          .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
  }
}