import { getMedia } from '@agctemplate/resources'

@ComponentV2
export struct MineMessageCard {
  @Param @Require replyAvatar: string
  @Param @Require replyName: string
  @Param @Require replyTimeAgo: number
  @Param @Require replyContent: string
  @Param @Require coverUrl: string
  @Param @Require commentContent: string
  @Local cardHeight: number = 0

  build() {
    Row() {
      Column() {
        Image(this.replyAvatar)
          .width(16)
          .aspectRatio(1)
          .borderRadius(8)
      }
      .justifyContent(FlexAlign.Start)
      .height('100%')
      .margin({ right: 8 })

      Column({ space: 8 }) {
        Row() {
          Text(this.replyName)
            .fontSize(12)
            .lineHeight(16)
            .fontColor($r('sys.color.font_secondary'))
          Blank()
          Text(this.replyTimeAgo < 1 ? '刚刚' : (this.replyTimeAgo >= 60 ?
            `${Math.floor(this.replyTimeAgo / 60)}小时前` : `${this.replyTimeAgo}分钟前`))
            .fontSize(10)
            .lineHeight(13)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .width('100%')

        Text('回复你：' + this.replyContent)
          .fontSize(14)
          .lineHeight(19)
          .fontColor($r('sys.color.font_primary'))
          .onAreaChange((oldValue: Area, newValue: Area) => {
            this.cardHeight = (Math.ceil(Number(newValue.height) / 19) - 1) * 19 + 115
          })

        Row({ space: 8 }) {
          Image(this.coverUrl)
            .width(36)
            .height(48)

          Text(this.commentContent)
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
    .width('100 %')
    .height(this.cardHeight)
  }
}

//调试预览使用
@Preview
@ComponentV2
export struct MineMessageCardPreview {
  build() {
    MineMessageCard({
      replyAvatar: '',
      replyName: '米雪秉承',
      replyTimeAgo: 60,
      replyContent: '英雄所见略同',
      coverUrl: '',
      commentContent: '回复@米雪秉承：同感同感！'
    })
  }
}