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
          Image(this.commentItem.avatar ? this.commentItem.avatar : $r('app.media.ic_default_avatar'))
            .width(50)
            .borderRadius(25)
            .margin({ right: 10 })
            .objectFit(ImageFit.Fill);
          Column({ space: 5 }) {
            Row() {
              Text('匿名用户')
                .fontSize($r('app.string.font_size_14'))
                .fontColor($r('app.color.font_color_level1'));
              Text(this.commentItem.date)
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.font_color_level2'));
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .width('100%');

            Row() {
              CommonRating({
                isIndicator:true,
                starSize:16,
                rating:this.commentItem.star
              })

              Blank()
              Image($r('app.media.ic_location2')).width(12).margin({ right: 5 });
              Text(this.commentItem.location)
                .fontSize($r('app.string.font_size_10'))
                .fontColor($r('app.color.font_color_level2'));
            }
            .width('100%');
          }
          .flexGrow(1);

        };

        Text(this.commentItem.desc)
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level1'))
          .lineHeight('42lpx')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({
            top: $r('app.string.space_m'),
            bottom: $r('app.string.space_m'),
          });
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.background_color_white'));
  }
}