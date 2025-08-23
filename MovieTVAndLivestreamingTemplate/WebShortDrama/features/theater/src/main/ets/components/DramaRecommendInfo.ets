import { getMedia } from '@agctemplate/resources'
import { DramaCoverVM } from '../viewmodels/DramaCoverVM'
import { getCoverEpisodeShowText } from './DramaCover'

@ComponentV2
export struct DramaRecommendInfo {
  @Param @Require drama: DramaCoverVM
  @Param @Require onItemClick: Function
  @Param inPage: string = ''

  @Builder
  episodeInfoBuilder(latestUpdate: number, episodes: number) {
    Column() {
      Text(getCoverEpisodeShowText(latestUpdate === episodes, episodes, latestUpdate))
        .padding({
          top: 1,
          right: 8,
          bottom: 1,
          left: 8
        })
        .borderRadius(14)
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor($r('sys.color.mask_tertiary'))
        .height(16)
    }
    .padding({
      right: 2, bottom: 2,
    })
    .height(18)
    .alignItems(HorizontalAlign.End)
  }

  build() {
    Column() {
      Stack() {
        Image(this.drama.imagePath)
          .height(140)
          .width(104)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .overlay(this.episodeInfoBuilder(this.drama.episodes, this.drama.latestUpdate),
            { align: Alignment.BottomEnd })

        if (this.inPage === 'new') {
          Image(getMedia('app.media.new'))
            .width(28)
            .height(16)
            .position({ left: 76 })
        } else if (this.drama.isVip === true) {
          Image(getMedia('app.media.vip'))
            .width(28)
            .height(16)
            .position({ left: 76 })
        }
      }

      Text(this.drama.title)
        .width(104)
        .maxLines(1)
        .fontSize(14)
        .margin({ top: 8, bottom: 2 })
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text() {
        ForEach(this.drama.tags, (tag: string, index: number) => {
          if (index === 0) {
            Span(tag)
          } else {
            Span('·'+tag)
          }
        },(tag: string) => tag)
      }
      .width(104)
      .height(16)
      .fontWeight(400)
      .fontColor($r('sys.color.mask_tertiary'))
      .maxLines(1)
      .fontSize(12)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      this.onItemClick(this.drama)
    })
  }
}