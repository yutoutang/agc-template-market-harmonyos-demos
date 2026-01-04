import { BreakpointModel, BreakpointNameEnum, RouterMap, RouterUtils } from 'lib_common';
import { AppStorageV2 } from '@kit.ArkUI';
import { TabType, VideoModel } from 'lib_video_api';

@ComponentV2
export struct ThreeGridContent {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Param data: VideoModel[] = []

  build() {
    GridRow({
      columns: this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 3 : 5,
      gutter: 8,
    }) {
      ForEach(this.data, (item: VideoModel) => {
        GridCol() {
          Column({ space: 5 }) {
            Stack() {
              Image(item.coverUrl)
                .width('100%')
                .aspectRatio(3 / 4)
                .borderRadius(8)

              Row() {
                Text(item.contentType === 'tv_movie' ? '电视剧' : '电影')
                  .fontColor('#FFFFFFFF')
                  .fontWeight(FontWeight.Bold)
                  .padding({
                    left: 3,
                    right: 3,
                    top: 1,
                    bottom: 1
                  })
                  .fontSize(8)
                  .lineHeight(9)
                  .backgroundColor('#802A2F43 ')
                  .border({ width: 1, color: '#1AFFFFFF', radius: 3 })
                  .position({ left: 4 })
                  .visibility(item.tabType === TabType.Recommend ? Visibility.Visible : Visibility.None)

                Text(`全${item.videoUrl.length}集`)
                  .fontColor('#FFFFFFFF')
                  .fontSize(8)
                  .lineHeight(9)
                  .position({ right: 4, top: 2 })
                  .visibility(item.contentType === 'tv_movie' ? Visibility.Visible : Visibility.None)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .height(18)
            }.alignContent(Alignment.Bottom)

            Text(item.title)
              .fontSize('#E6000000')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .lineHeight(16)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
            Text(item.synopsis)
              .fontColor('#99000000')
              .fontSize(10)
              .lineHeight(11)
              .width('100%')
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .onClick(() => {
            const param: Record<string, Object> = {
              'videoId': item.videoId
            }
            RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
          })
        }
      }, (item: VideoModel) => JSON.stringify(item))
    }
  }
}