import { PostImgList, FeedCardInfoModel } from '../model/RecommendModel';
import { FeedImageModifier } from '../utils/FeedImageModifier';

/*
 * 单张图片的展示
 * */

const TAG = '[FeedSingleImageSize]';

@ComponentV2
export struct FeedSingleImageSize {
  @Require @Param componentId: string = ''
  @Require @Param curFeedCardInfo: FeedCardInfoModel
  @Require @Param postImgListItem: PostImgList
  @Param isLast: boolean = false
  @Param truncatedCount: number = 0
  @Event onVideo: () => void = () => {}
  @Event onImageClick: () => void = () => {}
  @Local modifier: FeedImageModifier | undefined = undefined;

  aboutToAppear(): void {
    this.modifier = new FeedImageModifier(this.curFeedCardInfo)
  }

  @Computed
  get getImageRestPosition() {
    return this.truncatedCount > 0 && this.isLast
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Image(this.postImgListItem.picVideoUrl)
            .attributeModifier(this.modifier)
            .objectFit(ImageFit.Cover)
            .visibility(this.postImgListItem.surfaceUrl ? Visibility.None : Visibility.Visible)
            .borderRadius(12)
            .clip(true)
            .geometryTransition(this.curFeedCardInfo.id + this.postImgListItem.picVideoUrl + this.componentId)
            .transition(TransitionEffect.opacity(0.99))
            .onClick(() => {
              this.onImageClick()
            })
          Column() {
            Text(`+ ${this.truncatedCount}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }
          .margin({ right: 8, bottom: 8 })
          .visibility(this.getImageRestPosition ? Visibility.Visible : Visibility.None)
        }

        Stack() {
          Image(this.postImgListItem.surfaceUrl).objectFit(ImageFit.Cover)
            .borderRadius(12)
            .clip(true)
            .attributeModifier(this.modifier)
          Image($r('app.media.playBtn')).width(36)
            .height(36)
        }
        .visibility(this.postImgListItem.surfaceUrl ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.onVideo()
        })
      }
    }
    .clipShape(new Rect({ width: '100%', height: '100%', radius: 12 }))
    .margin({ top: 8 })
  }
}