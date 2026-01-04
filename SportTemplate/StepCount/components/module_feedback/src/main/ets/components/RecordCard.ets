import { ImagePreview, PreviewVerticalAlign } from 'module_imagepreview';
import { CommonUtils } from '../common/CommonUtils';
import { FeedbackConstants } from '../common/FeedbackConstants';
import { FeedbackResponseParams } from '../services/ResponseModel'

@ComponentV2
export struct RecordCard {
  @Require @Param record: FeedbackResponseParams;
  @Param fontSizeRatio: number = 1;

  build() {
    Column() {
      Text(CommonUtils.handleDateTime(this.record.createTime))
        .fontSize(12 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
      Text('问题描述')
        .fontSize(16 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: 12,
        })
      Text(this.record.problemDesc)
        .fontSize(12 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_secondary'))
        .margin({
          top: 8,
        })
      Text('问题截图')
        .fontSize(16 * this.fontSizeRatio)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: 12,
          bottom: 8,
        })
      Grid() {
        if (this.record?.screenShots?.length) {
          ForEach(this.record.screenShots, (item: string, index: number) => {
            GridItem() {
              Image(item)
                .width(FeedbackConstants.FULL_PERCENT)
                .aspectRatio(1)
                .borderRadius(16)
                .clip(true)
                .onClick(() => {
                  ImagePreview.show(this.record.screenShots, {
                    startIndex: index,
                    showIndex: true,
                    loop: false,
                    isBasicMode: true,
                    indexPosition: PreviewVerticalAlign.Top,
                  })
                })
            }
          }, (v: string, index: number) => v)
        } else {
          GridItem() {
            Column({ space: 4 }) {
              Image($r('app.media.ic_plus2'))
                .width(FeedbackConstants.ICON_WIDTH)
                .aspectRatio(1)
                .draggable(false)
                .fillColor($r('sys.color.icon_secondary'))
            }
            .width(FeedbackConstants.FULL_PERCENT)
            .aspectRatio(1)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_tertiary'))
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(8)
      .maxCount(FeedbackConstants.MAX_IMG_COUNT)
      .scrollBar(BarState.Off)
    }
    .width(FeedbackConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(FeedbackConstants.RADIUS_16)
    .padding(FeedbackConstants.PADDING_M)
    .alignItems(HorizontalAlign.Start)
  }
}