import { VideoModel } from 'lib_video_api';
import { FlexLayoutModel } from '../viewmodels/FlexLayoutModel';
import { BreakpointNameEnum, RouterMap, RouterUtils } from 'lib_common';
import { ConfigTitle } from './ConfigTitle';
import { TwoGridContent } from './TwoGridContent';
import { RecommendGridContent } from './RecommendGridContent';

@ComponentV2
export struct MovieComponent {
  @Local vm: FlexLayoutModel = new FlexLayoutModel();

  aboutToAppear(): void {
    this.vm.init(2)
  }

  build() {
    Column() {
      ConfigTitle({ text: '人气热播', currentIndex: this.vm.currentIndex })
      TwoGridContent({ data: this.vm.hitList.slice(0, 4) })

      ConfigTitle({ text: '经典热搜', currentIndex: this.vm.currentIndex })
      this.popularBuilder()

      ConfigTitle({ text: '推荐必看', currentIndex: this.vm.currentIndex })
      RecommendGridContent({ data: this.vm.mustList.slice(0, 4) })
    }
  }

  @Builder
  popularBuilder() {
    GridRow({
      columns: this.vm.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 2 : 4,
      gutter: 8,
    }) {
      ForEach(this.vm.hotSearchList.slice(0, 4), (item: VideoModel) => {
        GridCol() {
          Column({ space: 5 }) {
            Stack() {
              Image(item.coverUrl)
                .width('100%')
                .aspectRatio(16 / 9)
                .borderRadius(8)

              Row() {
                Text('电影')
                  .fontColor(Color.White)
                  .padding({
                    left: 3,
                    right: 3,
                    top: 1,
                    bottom: 1
                  })
                  .fontSize(8)
                  .lineHeight(9)
                  .backgroundColor('#2A2F43 ')
                  .border({ width: 1, color: '#1AFFFFFF', radius: 3 })

              }.width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding(4)
            }.alignContent(Alignment.Bottom)

            Text(item.title)
              .fontSize('#E6000000')
              .fontSize(14)
              .lineHeight(16)
              .fontWeight(FontWeight.Bold)
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
