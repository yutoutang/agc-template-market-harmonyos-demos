import { BreakpointModel, BreakpointNameEnum, RouterMap, RouterUtils } from 'lib_common';
import { VideoResponse } from 'lib_video_api';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MoreRecommendView {
  @Param recommendVideoList: VideoResponse[] = []
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column({ space: 16 }) {
      Text('相关推荐').fontSize(16).lineHeight(19).fontColor(Color.White).fontWeight(FontWeight.Bold)
      GridRow({
        columns: this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 2 : 3,
        gutter: 10,
      }) {
        ForEach(this.recommendVideoList, (item: VideoResponse) => {
          GridCol() {
            Column({ space: 5 }) {
              Image(item.coverUrl).width('100%').aspectRatio(0.8).borderRadius(8)
              Text(item.title).fontColor(Color.White).fontSize(14).lineHeight(20).fontWeight(FontWeight.Medium)
              Text(item.subTitle)
                .fontColor('#80FFFFFF')
                .fontSize(12)
                .lineHeight(17)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              const param: Record<string, Object> = {
                'videoId': item.videoId,
              }
              RouterUtils.replacePathByName(RouterMap.PLAY_PAGE, param, false);
            })
          }
        }, (item: VideoResponse) => JSON.stringify(item))
      }.width('100%')
    }.alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 12 })
  }
}