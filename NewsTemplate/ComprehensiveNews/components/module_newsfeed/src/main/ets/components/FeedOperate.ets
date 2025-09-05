import { FeedCardInfoModel } from '../model/RecommendModel';
import { formatToK } from '../utils/Index';

/*
 * 动态操作
 * 点赞，评论，分享
 * */

const TAG = '[FeedOperate]';

@ComponentV2
export struct FeedOperate {
  @Require @Param curFeedCardInfo: FeedCardInfoModel
  @Param isNeedOperation: boolean = false
  @Param isDark: boolean = false
  @Param fontSizeRatio: number = 1
  @BuilderParam shareBuilder: () => void
  @Event onArticle: () => void = () => {
  }
  @Event onLike: () => void = () => {
  }

  @Computed
  get getDarkLike() {
    return this.isDark ? $r('app.media.like_dark') : $r('app.media.like')
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        if (this.shareBuilder && this.isNeedOperation) {
          Row() {
            this.shareBuilder()
          }
        } else {
          Row({ space: 5 }) {
            Image($r('app.media.op_forward')).width(16 * this.fontSizeRatio).height(16 * this.fontSizeRatio)
              .fillColor($r('sys.color.font_primary'))
            Text(formatToK(this.curFeedCardInfo.shareCount))
              .fontSize(12 * this.fontSizeRatio)
              .fontColor($r('sys.color.font_secondary'))
          }
          .accessibilityGroup(true)
          .accessibilityText('分享按钮' + formatToK(this.curFeedCardInfo.shareCount))
        }
        Row({ space: 5 }) {
          Image($r('app.media.op_comment')).width(17 * this.fontSizeRatio).height(16 * this.fontSizeRatio)
            .fillColor($r('sys.color.font_primary'))
          Text(formatToK(this.curFeedCardInfo.commentCount))
            .fontSize(12 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .accessibilityText('评论按钮' + formatToK(this.curFeedCardInfo.commentCount))
        .onClick(() => {
          this.onArticle()
        })

        Row({ space: 5 }) {
          Image(this.curFeedCardInfo.isLiked ? $r('app.media.like_active') : this.getDarkLike)
            .width(17 * this.fontSizeRatio)
            .height(15 * this.fontSizeRatio)
          Text(formatToK(this.curFeedCardInfo.likeCount))
            .fontSize(12 * this.fontSizeRatio)
            .fontColor($r('sys.color.font_secondary'))
        }
        .accessibilityText(this.curFeedCardInfo.isLiked ? '取消点赞按钮' + formatToK(this.curFeedCardInfo.likeCount) :
          '点赞按钮' + formatToK(this.curFeedCardInfo.likeCount))
        .onClick(() => {
          this.onLike()
        }).justifyContent(FlexAlign.End)
      }
      .width('100%').margin({ top: 16 })
    }
  }
}