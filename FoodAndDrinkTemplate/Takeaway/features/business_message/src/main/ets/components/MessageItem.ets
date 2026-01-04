import { CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common';
import { IMineMsgItem } from 'lib_takeaway_api';
import { CustomBadge } from 'lib_widget';
import { MessageViewModel } from '../viewmodels/MessageVM';

@ComponentV2
export struct MsgMenuItem {
  @Require @Param info: IMineMsgItem;
  @Param fontSizeRatio: number = 1;
  @Require @Param vm: MessageViewModel

  build() {
    Row({ space: CommonConstants.SPACE_M }) {
      CustomBadge({
        isNewMessage: this.info.isNewMessage,
        maxCount: 99,
        bodyBuilder: () => {
          this.bodyBuilder()
        },
      })

      Column({ space: CommonConstants.SPACE_S }) {
        Row() {
          Text(this.info.title)
            .fontSize(16 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)

          Text(TimeUtils.formatDate(this.info.createTime, 'YYYY/MM/DD'))
            .fontSize($r('sys.float.Caption_L'))
            .fontColor($r('sys.color.font_tertiary'))
        }

        Text(this.info.content)
          .fontSize(12 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.MESSAGE_HEIGHT)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
    .borderRadius(CommonConstants.BORDER_RADIUS_16)
    .padding({
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
      left: CommonConstants.PADDING_M,
      right: CommonConstants.PADDING_M,
    })
    .onClick(() => {
      let routerParams = {
        'info': this.info
      } as Record<string, IMineMsgItem>
      RouterUtils.pushPathByName(RouterMap.MESSAGEINFO_PAGE, routerParams);
      if (!this.info.isNewMessage) {
        this.vm.userInfoModel.unReadMsgNum = this.vm.userInfoModel.unReadMsgNum as number - 1
      }
      this.vm.readMsgInfo(this.info)

    })
  }

  @Builder
  bodyBuilder() {
    Image(this.vm.getMenuIcon(this.info.type))
      .width($r('app.float.menu_icon_width'))
      .aspectRatio(1)
      .draggable(false)
  }
}