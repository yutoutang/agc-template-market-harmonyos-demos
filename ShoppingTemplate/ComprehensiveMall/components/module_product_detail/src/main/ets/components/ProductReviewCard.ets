import { Constants } from '../commons/Constants'
import { ReviewMediaType } from '../commons/Enums'
import { ProductReviewItem, ReviewMediaItem } from '../commons/Types'

@ComponentV2
export struct ProductReviewCard {
  @Param
  reviewItem: ProductReviewItem | undefined = undefined
  @Local
  openPreview: boolean = false
  @Local
  previewItem?: ReviewMediaItem = undefined

  @Computed
  get previewSheetTitle() {
    if (this.previewItem) {
      return this.previewItem.type === ReviewMediaType.IMAGE ? '图片预览' : '视频预览'
    }
    return ''
  }

  build() {
    Column() {
      if (this.reviewItem) {
        Row() {
          Image(this.reviewItem.userAvatar)
            .width(24)
            .height(24)
            .borderRadius($r('app.string.border_radius_capsule'))
            .margin({ right: $r('app.string.space_s') })
          Text() {
            Span(this.reviewItem.userName)
              .fontColor(Constants.FONT_COLOR_LEVEL2)
            Span(' ').letterSpacing(8)
            ForEach(this.reviewItem.skuDesc, (desc: string, index: number) => {
              Span(desc)
              if (index < this.reviewItem!.skuDesc.length - 1) {
                Span('; ')
              }
            }, (item: string, index: number) => index + item)
          }
          .fontSize($r('app.string.font_size_12'))
          .fontColor(Constants.FONT_COLOR_LEVEL3)
          .layoutWeight(1)
          .margin({ right: $r('app.string.space_l') })

          Row({ space: 4 }) {
            ForEach([1, 2, 3, 4, 5], (item: number) => {
              Image(this.reviewItem!.rating >= item ? $r('app.media.ic_star_filled') : $r('app.media.ic_star_grey'))
                .width(12)
                .height(12)
            }, (item: number) => item.toString())
          }
        }
        .width($r('app.string.size_percent_full'))
        .margin({ bottom: $r('app.string.space_xs') })

        Column() {
          Text(this.reviewItem.content)
            .fontSize($r('app.string.font_size_14'))
            .fontColor(Constants.FONT_COLOR_LEVEL1)
          if (this.reviewItem.mediaList.length) {
            GridRow({
              columns: {
                xs: 3,
                md: 5,
              },
              gutter: { x: 8, y: 8 },
            }) {
              ForEach(this.reviewItem.mediaList, (item: ReviewMediaItem) => {
                GridCol({
                  offset: 0,
                  order: 0,
                }) {
                  Image(item.uri)
                    .width($r('app.string.size_percent_full'))
                    .aspectRatio(1)
                    .borderRadius($r('app.string.border_radius_8'))
                    .onClick(() => {
                      this.previewItem = item
                      this.openPreview = true
                    })
                }
              }, (item: ReviewMediaItem, index: number) => index + JSON.stringify(item))
            }
            .width($r('app.string.size_percent_full'))
            .margin({
              top: $r('app.string.space_m'),
            })
          }
          Text(this.formatFullDate(new Date(this.reviewItem.date)))
            .fontSize($r('app.string.font_size_12'))
            .fontColor(Constants.FONT_COLOR_LEVEL3)
            .width($r('app.string.size_percent_full'))
            .textAlign(TextAlign.End)
            .margin({ top: $r('app.string.space_m') })
        }
        .margin({ left: 32 })
      }
    }
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .bindContentCover(
      $$this.openPreview,
      this.previewSheet(),
    )
  }

  @Builder
  previewSheet() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .width(40)
          .height(40)
          .aspectRatio(1)
          .draggable(false)
          .margin({ right: $r('app.string.space_s') })
          .borderRadius($r('app.string.border_radius_capsule'))
          .stateStyles({
            normal: {
              .backgroundColor($r('app.color.background_color_transparent'))
            },
            pressed: {
              .backgroundColor($r('sys.color.interactive_pressed'))
            },
          })
          .onClick(() => {
            this.openPreview = false
            this.previewItem = undefined
          })
        Text(this.previewSheetTitle)
          .fontSize($r('app.string.font_size_20'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(FontWeight.Medium);
      }
      .width($r('app.string.size_percent_full'))
      .margin({ top: 36, bottom: $r('app.string.space_l') })
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(Constants.BACKGROUND_COLOR)
      .padding({ left: $r('app.string.space_l') });

      if (this.previewItem?.uri) {
        if (this.previewItem.type === ReviewMediaType.IMAGE) {
          Scroll() {
            Image(this.previewItem.uri)
              .width($r('app.string.size_percent_full'))
              .height($r('app.string.size_percent_full'))
              .objectFit(ImageFit.Contain)
          }
          .padding($r('app.string.space_l'))
          .layoutWeight(1);
        } else if (this.previewItem.type === ReviewMediaType.VIDEO) {
          Row() {
            Video({
              src: this.previewItem.uri,
            })
              .width($r('app.string.size_percent_full'));
          }
          .padding($r('app.string.space_l'))
        }
      }
    }
    .height($r('app.string.size_percent_full'))
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  formatFullDate(date: Date): string {
    const pad = (n: number) => n < 10 ? '0' + n : n.toString();

    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());

    return `${year}年${month}月${day}日 ${hours}:${minutes}`;
  }
}