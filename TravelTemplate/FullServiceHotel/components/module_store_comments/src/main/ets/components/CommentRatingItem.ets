import { Constants } from '../commons/Constants';
import { RatingLayoutType } from '../commons/Enums';
import { CommonRating } from './CommonRating';

@ComponentV2
export struct CommentRatingItem {
  @Param rating: number = 1;
  @Param starSize: number = 20;
  @Param layoutType: RatingLayoutType = RatingLayoutType.HORIZONTAL;
  @Param label: string = '';
  @Event $rating: (value: number) => void = (value: number) => {
  };
  @Local starList: boolean[] = [false, false, false, false, false];

  @Computed
  get desc() {
    return Constants.RATING_LABEL[this.rating - 1] ?? '';
  }

  build() {
    Column() {
      if (this.layoutType === RatingLayoutType.VERTICAL) {
        this.verticalRatingBuilder()
      } else {
        this.horizontalRatingBuilder()
      }
    }
    .width('100%');
  }

  @Builder
  verticalRatingBuilder() {
    Column() {
      this.ratingBuilder()

      Text(this.desc + ' ')
        .fontSize($r('app.string.font_size_14'))
        .fontColor($r('app.color.font_color_level1'))
        .margin({ top: $r('app.string.space_s') });
    };
  }

  @Builder
  horizontalRatingBuilder() {
    Flex({
      alignItems: ItemAlign.Center,
    }) {
      if (this.label) {
        Text(this.label)
          .fontColor($r('app.color.font_color_level1'))
          .margin({ right: $r('app.string.space_m') })
          .fontSize($r('app.string.font_size_14'));
      }
      this.ratingBuilder()
      Blank();
      Text(this.desc).fontSize($r('app.string.font_size_14')).fontColor($r('app.color.font_color_level2'));
    }
    .width('100%')
    .margin({
      bottom: $r('app.string.space_s'),
    });
  }

  @Builder
  ratingBuilder() {
    CommonRating({
      rating: this.rating,
      handleChange: (value) => {
        this.$rating(value);
      },
    })
  }
}
