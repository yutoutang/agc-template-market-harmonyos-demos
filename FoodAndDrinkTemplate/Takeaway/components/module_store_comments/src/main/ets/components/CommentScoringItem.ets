import { RatingLayoutType } from '../commons/Enums';
import { CommonRating } from './CommonRating';

@ComponentV2
export struct CommentScoringItem {
  @Param desc: string = '';
  @Param count: number = 0;
  @Param layoutType: RatingLayoutType = RatingLayoutType.HORIZONTAL;

  build() {
    Row() {
      if (this.layoutType === RatingLayoutType.HORIZONTAL) {
        Text(this.count + '')
          .fontSize($r('app.string.font_size_24'))
          .fontColor($r('app.color.theme_color_third'))
          .margin({
            top: $r('app.string.space_l'),
            bottom: $r('app.string.space_l'),
            right: $r('app.string.space_xs')
          })
          .fontWeight(500)
      }

      Column() {
        Text(this.desc)
          .fontColor($r('app.color.common_color_second'))
          .fontSize($r('app.string.font_size_8'))
          .fontWeight(400)
        if (this.layoutType === RatingLayoutType.HORIZONTAL) {
          CommonRating({
            isIndicator: true,
            starSize: 14,
            rating: this.count
          })
        } else {
          Text(this.count + '')
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level1'))
        }
      }
      .margin({
        right: this.layoutType === RatingLayoutType.HORIZONTAL ? 80 : 20
      })
      .alignItems(this.layoutType === RatingLayoutType.HORIZONTAL ? HorizontalAlign.Start : HorizontalAlign.Center)
    }
    .alignItems(VerticalAlign.Center)
  }
}