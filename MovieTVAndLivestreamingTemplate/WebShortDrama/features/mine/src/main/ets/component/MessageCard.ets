import { getMedia } from '@agctemplate/resources'
import { CommentData, Reply } from '../models/messageData'

@Preview
@ComponentV2
export struct MessageCard {

  @Param @Require myMessage: CommentData
  @Param @Require reply: Reply
  @Local cardHeight: number = 0

  build() {
    Row() {
      Row() {
        Column() {
          Image(getMedia(this.reply.replyAvatar))
            .width(16)
            .aspectRatio(1)
            .borderRadius(8)
        }
        .justifyContent(FlexAlign.Start)
        .height('100%')
        .margin({ right: 8 })

        Column({ space: 8 }) {
          Row() {
            Text(this.reply.replyName)
              .fontSize(12)
              .lineHeight(16)
              .fontColor($r('sys.color.font_secondary'))
            Blank()
            Text(this.reply.replyTimeAgo < 1 ? '刚刚' : (this.reply.replyTimeAgo >= 60 ?
              `${Math.floor(this.reply.replyTimeAgo / 60)}小时前` : `${this.reply.replyTimeAgo}分钟前`))
              .fontSize(10)
              .lineHeight(13)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')

          Text('回复你：' + this.reply.replyContent)
            .fontSize(14)
            .lineHeight(19)
            .fontColor($r('sys.color.font_primary'))
            .onAreaChange((oldValue: Area, newValue: Area) => {
              this.cardHeight = (Math.ceil(Number(newValue.height) / 19) - 1) * 19 + 115
            })

          Row({ space: 8 }) {
            Image(this.myMessage.coverUrl)
              .width(36)
              .height(48)

            Text(this.myMessage.commentContent)
              .fontSize(12)
              .lineHeight(16)
              .fontColor($r('sys.color.font_secondary'))
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .borderRadius(8)
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .alignItems(VerticalAlign.Top)
          .padding(8)
        }
        .height('100%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .layoutWeight(1)
      }
    }
    .height(this.cardHeight)
    .width('100%')
  }
}