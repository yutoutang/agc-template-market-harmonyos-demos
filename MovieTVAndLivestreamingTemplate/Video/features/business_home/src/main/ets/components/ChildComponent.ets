import { VideoModel } from 'lib_video_api';
import { MorePageParams } from '../model/TabInfoModel';
import { FlexLayoutModel } from '../viewmodels/FlexLayoutModel';
import { BreakpointModel, BreakpointNameEnum, CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigTitle } from './ConfigTitle';

@ComponentV2
export struct ChildComponent {
  @Local vm: FlexLayoutModel = new FlexLayoutModel();
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.vm.init(3)
  }

  build() {
    Column() {
      ConfigTitle({ text: '人气热播', currentIndex: this.vm.currentIndex }).padding({ left: 12, right: 12 })
      this.hotBuilder()
      ConfigTitle({ text: '小朋友爱看', currentIndex: this.vm.currentIndex }).padding({ left: 12, right: 12 })
      this.popularBuilder()
      ConfigTitle({ text: '亲子互动', currentIndex: this.vm.currentIndex }).padding({ left: 12, right: 12 })
      this.childBuilder()
      ConfigTitle({ text: '推荐必看', currentIndex: this.vm.currentIndex }).padding({ left: 12, right: 12 })
      this.recommendBuilder()
    }
  }

  @Builder
  hotBuilder() {
    List({ space: 8 }) {
      ForEach(this.vm.hitList, (item: VideoModel, index: number) => {
        ListItem() {
          Column({ space: 5 }) {
            Stack() {
              Image(item.coverUrl).aspectRatio(3 / 4).borderRadius(8).width(160)
              Row() {
                Text(`全${item.videoUrl.length}集`)
                  .visibility(item.contentType === 'tv_movie' ? Visibility.Visible : Visibility.None)
                  .fontColor('#FFFFFFFF')
                  .fontSize(8)
                  .lineHeight(9)
              }
              .justifyContent(FlexAlign.End)
              .padding({ left: 4, right: 4, bottom: 7 })
              .width(160)
            }.alignContent(Alignment.Bottom)

            Text(item.title)
              .lineHeight(16)
              .maxLines(1)
              .width(160)
              .fontSize('#E6000000')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(item.synopsis)
              .fontColor('#99000000')
              .fontSize(10)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(11)
              .width(160)
              .textAlign(TextAlign.Start)
          }
          .onClick(() => {
            const param: Record<string, Object> = {
              'videoId': item.videoId
            }
            RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
          })
        }
        .margin({ left: index === 0 ? 16 : 0, right: index === this.vm.hitList.length - 1 ? 16 : 0 })
      }, (item: VideoModel) => JSON.stringify(item))
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // 热搜
  @Builder
  popularBuilder() {
    GridRow({
      columns: this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 2 : 4,
      gutter: 8,
    }) {
      ForEach(this.vm.childList.slice(0, 4), (item: VideoModel) => {
        GridCol() {
          Column({ space: 5 }) {
            Stack() {
              Image(item.coverUrl)
                .width('100%')
                .borderRadius(8)
                .aspectRatio(16 / 9)
              Row() {
                Text(`全${item.videoUrl.length}集`).fontColor('#FFFFFFFF').fontSize(8).lineHeight(9)
                  .visibility(item.contentType === 'tv_movie' ? Visibility.Visible : Visibility.None)
              }
              .justifyContent(FlexAlign.End)
              .padding({ left: 4, right: 4, bottom: 7 }).width('100%')
            }.alignContent(Alignment.Bottom)

            Text(item.title)
              .fontWeight(FontWeight.Bold)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .fontSize('#E6000000')
              .fontSize(14)
              .lineHeight(16)
            Text(item.synopsis)
              .width('100%')
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor('#99000000')
              .fontSize(10)
              .lineHeight(11)

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
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
  }

  @Builder
  recommendBuilder() {
    GridRow({
      columns: this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 2 : 4,
      gutter: 8,
    }) {
      ForEach(this.vm.mustList.slice(0, 4), (item: VideoModel) => {
        GridCol() {
          Column({ space: 6 }) {

            Stack() {
              Image(item.coverUrl)
                .width('100%')
                .aspectRatio(0.8)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
              Row() {
                Text(`全${item.videoUrl.length}集`).fontColor('#FFFFFFFF').fontSize(8).lineHeight(9)
                  .visibility(item.contentType === 'tv_movie' ? Visibility.Visible : Visibility.None)
              }.width('100%')
              .justifyContent(FlexAlign.End)
              .padding({ left: 4, right: 4, bottom: 7 })
            }.alignContent(Alignment.Bottom)


            Text(item.title)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize('#E6000000')
              .fontSize(14)
              .width('100%')
              .maxLines(1)
              .fontWeight(FontWeight.Bold)
              .lineHeight(16)
            Text(item.synopsis)
              .lineHeight(11)
              .fontColor('#99000000')
              .width('100%')
              .textAlign(TextAlign.Start)
              .fontSize(10)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
          }
          .onClick(() => {
            const param: Record<string, Object> = {
              'videoId': item.videoId
            }
            RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
          })
        }
      }, (item: VideoModel) => JSON.stringify(item))
    }.padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
  }

  @Builder
  childBuilder() {
    GridRow({
      columns: this.breakpointModel.currentBreakpoint === BreakpointNameEnum.SM ? 3 : 5,
      gutter: 8,
    }) {
      ForEach(this.vm.parentList.slice(0, 6), (item: VideoModel) => {
        GridCol() {
          Column({ space: 5 }) {
            Stack() {
              Image(item.coverUrl)
                .width('100%')
                .borderRadius(8)
                .aspectRatio(3 / 4)
              Row() {
                Text(`全${item.videoUrl.length}集`)
                  .lineHeight(9)
                  .fontColor('#FFFFFFFF')
                  .fontSize(8)
                  .visibility(item.contentType === 'tv_movie' ? Visibility.Visible : Visibility.None)
              }.width('100%')
              .padding({ left: 4, right: 4, bottom: 7 })
              .justifyContent(FlexAlign.End)
            }.alignContent(Alignment.Bottom)

            Text(item.title)
              .width('100%')
              .fontSize('#E6000000')
              .lineHeight(16)
              .fontSize(14)
              .maxLines(1)
              .fontWeight(FontWeight.Bold)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(item.synopsis)
              .lineHeight(11)
              .fontColor('#99000000')
              .fontSize(10)
              .textAlign(TextAlign.Start)
              .width('100%')
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
          }
          .onClick(() => {
            const param: Record<string, Object> = {
              'videoId': item.videoId
            }
            RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
          })
        }
      }, (item: VideoModel) => JSON.stringify(item))
    }.padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
  }
}
