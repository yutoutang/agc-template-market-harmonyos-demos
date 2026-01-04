import { CommentItem } from '../commons/Types';
import { CommonRating } from './CommonRating';

@ComponentV2
export struct CommentCard {
  @Param
  commentItem?: CommentItem = undefined

  build() {
    Column() {
      if (this.commentItem) {
        Flex({
          alignItems: ItemAlign.Center,
        }) {
          Image(this.commentItem.avatar ? this.commentItem.avatar : $r('app.media.ic_default_avatar_yellow'))
            .width(35)
            .borderRadius(25)
            .margin({ right: 10 })
            .objectFit(ImageFit.Fill);
          Column({ space: 5 }) {
            Row() {
              Text(this.commentItem.userName === '' ? '匿名用户' : this.commentItem.userName)
                .fontSize($r('app.string.font_size_14'))
                .fontColor($r('app.color.font_color_level4'));
              Text(this.commentItem.date)
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.common_color_second'));
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');

            Row() {
              CommonRating({
                isIndicator: true,
                starSize: 16,
                rating: this.commentItem.star
              })

              Blank()

            }
            .width('100%');
          }
          .flexGrow(1);

        };

        Text(this.commentItem.desc)
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level5'))
          .lineHeight(14)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({
            top: $r('app.string.space_m'),
            bottom: $r('app.string.space_m'),
          });
      }
    }
    .borderRadius($r('app.string.border_radius_12'))
    .padding($r('app.string.space_m'))
    .width('100%')
    .backgroundColor($r('app.color.background_color_white'));
  }
}