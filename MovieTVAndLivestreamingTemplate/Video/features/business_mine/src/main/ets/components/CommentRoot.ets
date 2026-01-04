import { CircleShape } from '@kit.ArkUI';
import { CommonConstants, RouterMap, RouterUtils, TimeUtils } from 'lib_common'
import { AggregateNewsCommentModel } from '../common/ObservedModel'

@ComponentV2
export struct CommentRoot {
  @Param fontSizeRatio: number = 1;
  @Require @Param data: AggregateNewsCommentModel;
  @Event onReply: () => void = () => {
  };

  build() {
    Column({ space: CommonConstants.PADDING_S }) {
      Row({ space: CommonConstants.SPACE_S }) {
        Image(this.data.author.authorIcon)
          .width($r('app.float.medium_img_width'))
          .aspectRatio(1)
          .clipShape(new CircleShape({ width: 16, height: 16 }))
        Text(this.data.author.authorNickName)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(12 * this.fontSizeRatio)
      }
      .onClick(() => {
        RouterUtils.pushPathByName(RouterMap.PROFILE_HOME, this.data.author.authorId);
      })

      // 评论内容
      Row() {
        Text(this.data.commentBody)
          .fontSize(14 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
      .padding({ left: CommonConstants.PADDING_XXL })
      .width(CommonConstants.FULL_PERCENT)

      // 评论时间
      Row({ space: CommonConstants.SPACE_S }) {
        Text(TimeUtils.getDateDiff(this.data.createTime))
          .fontSize(10 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })

      Row() {
        Row() {
        }
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius($r('app.float.small_radius'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .padding(CommonConstants.PADDING_S)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({ left: CommonConstants.PADDING_XXL })
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      top: CommonConstants.PADDING_M,
      right: CommonConstants.PADDING_PAGE,
      bottom: CommonConstants.PADDING_M,
    })
    .alignItems(HorizontalAlign.Start)
  }
}