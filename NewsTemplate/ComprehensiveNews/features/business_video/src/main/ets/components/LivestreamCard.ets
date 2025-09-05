import { CommonConstants, RouterMap, RouterUtils } from 'lib_common'
import { VideoNewsData } from '../models/VideoModel'

@ComponentV2
export struct LivestreamCard {
  @Param @Require cardData: VideoNewsData
  @Param showLiveTag: boolean = false;
  @Param imgBorderRadius: number = 8;
  @Param titleFontSize: number = 14;
  @Local prefixText: string = ''

  aboutToAppear(): void {
    if (this.showLiveTag) {
      this.prefixText = '【正在直播】'
    }
  }

  build() {
    Column({ space: CommonConstants.SPACE_S }) {
      Stack({alignContent: Alignment.TopEnd}) {
        Image(this.cardData.coverUrl)
          .width(CommonConstants.FULL_PERCENT)
          .borderRadius(this.imgBorderRadius)
          .aspectRatio(16/9)
          .draggable(false)

        if (this.showLiveTag) {
          Row({space:2 }) {
            Image($r('app.media.ic_live'))
              .width(12)
              .height(12)
            Text('直播中')
              .fontSize(10)
              .fontColor(Color.White)
              .lineHeight(13)
          }
          .padding({ left: 8, top: 3, right:8, bottom: 3 })
          .borderRadius({
            topLeft: 2,
            bottomLeft: 14,
            topRight: 14,
            bottomRight: 2
          })
          .backgroundColor($r('sys.color.warning'))
          .offset({ top: 2, right: 2 })
        }
      }

      Row() {
        Text(this.prefixText + this.cardData.title)
          .fontSize(this.titleFontSize)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(500)
          .lineHeight(21)
          .maxLines(2)
          .textOverflow({overflow: TextOverflow.Ellipsis})
      }
      .height(42)
      .alignItems(VerticalAlign.Top)
    }
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      let param: Record<string, boolean | VideoNewsData> = {
        'detailData': this.cardData,
        'isLivestream': this.showLiveTag
      }
      RouterUtils.pushPathByName(RouterMap.LIVESTREAM_DETAIL_PAGE, param)
    })
  }
}