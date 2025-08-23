@ComponentV2
export struct CommonRating {
  @Param
  isIndicator: boolean = false
  @Param
  rating: number = 0
  @Param
  starSize: number = 20
  @Event
  handleChange: (star: number) => void

  build() {
    Row() {
      Rating({ rating: this.rating, indicator: this.isIndicator })
        .contentModifier(new MyRatingStyle(this.starSize))
        .onChange((value) => {
          this.handleChange?.(value)
        })
    }
  }
}

class MyRatingStyle implements ContentModifier<RatingConfiguration> {
  size: number = 20

  constructor(size: number) {
    this.size = size
  }

  applyContent(): WrappedBuilder<[RatingConfiguration]> {
    return wrapBuilder(buildRating);
  }
}

@Builder
function buildRating(config: RatingConfiguration) {
  Row() {
    ForEach([1, 2, 3, 4, 5], (item: number) => {
      Image(config.rating >= item ? $r('app.media.ic_star_filled') : $r('app.media.ic_star_grey'))
        .height((config.contentModifier as MyRatingStyle).size)
        .margin({ right: 4 })
        .onClick(() => {
          if (!config.indicator) {
            config.triggerChange(item)
          }
        })
    }, (item: number) => JSON.stringify(item))
  }
}