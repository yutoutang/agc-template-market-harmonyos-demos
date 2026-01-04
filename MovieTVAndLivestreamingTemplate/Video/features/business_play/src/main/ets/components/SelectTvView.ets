import { VideoModel } from 'lib_video_api';

@ComponentV2
export struct SelectTvView {
  private listScroller: Scroller = new Scroller();
  @Param currentIndex: number = 0
  @Local downloadShowSheet: boolean = false
  @Require @Param video: VideoModel
  @Event playVideo?: (index: number) => void

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('选集').fontSize(16).lineHeight(19).fontColor(Color.White).fontWeight(FontWeight.Medium)
        Row() {
          Text(`${this.video.videoUrl.length} 集全`)
            .fontSize(12)
            .lineHeight(14)
            .fontColor('#80FFFFFF')
            .fontWeight(FontWeight.Medium)
          Image($r('app.media.icon_right')).width(12).height(12)
        }
        .bindSheet(this.downloadShowSheet, this.downloadSheet(), {
          height: SheetSize.MEDIUM,
          dragBar: false,
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          this.downloadShowSheet = !this.downloadShowSheet;
        })
      }.width('100%')
      .padding({ left: 12, right: 12 })
      .justifyContent(FlexAlign.SpaceBetween)

      List({ space: 8, initialIndex: 0, scroller: this.listScroller }) {
        ForEach(this.video.videoUrl, (item: ResourceStr, index: number) => {
          ListItem() {
            Stack() {
              Text((index + 1).toString())
                .fontSize(14)
                .lineHeight(20)
                .fontColor(this.currentIndex === index ? '#FF0B9FFB' : Color.White)
                .fontWeight(this.currentIndex === index ? '#FF0B9FFB' : FontWeight.Bold)
              Image($r('app.media.icon_now_playing'))
                .width(12)
                .height(12)
                .position({ bottom: 2, left: 2 })
                .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
            }
            .height('100%')
            .aspectRatio(1)
            .backgroundColor(this.currentIndex === index ? '#1A098592' : '#1AFFFFFF')
            .borderRadius(4)
            .onClick(() => {
              this.playVideo?.(index)
            })
          }
          .margin({ left: index === 0 ? 12 : 0, right: index === this.video.videoUrl.length - 1 ? 12 : 0 })
        }, (item: ResourceStr, index: number) => JSON.stringify(item) + index)
      }
      .height(45)
      .width('100%')
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
  }

  @Builder
  downloadSheet() {
    Column({ space: 20 }) {
      Text('选集')
        .fontColor('#E6000000')
        .fontSize(20)
        .lineHeight(24)
        .fontWeight(FontWeight.Bold)

      Grid() {
        ForEach(this.video.videoUrl, (item: ResourceStr, index: number) => {
          GridItem() {
            Stack() {
              Text((index + 1).toString())
                .fontSize(14)
                .lineHeight(20)
                .fontColor(this.currentIndex === index ? '#80FD603E' : '#E6000000')
              Image($r('app.media.icon_now_playing'))
                .width(12)
                .height(12)
                .position({ bottom: 3, left: 3 })
                .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
            }
            .width('100%')
            .aspectRatio(1)
            .backgroundColor(this.currentIndex === index ? Color.White : '#0D000000')
            .border({ width: 1, color: this.currentIndex === index ? '#80FD603E' : '#0D000000', radius: 4 })
            .onClick(() => {
              this.listScroller.scrollToIndex(index)
              this.playVideo?.(index)
              this.downloadShowSheet = false
            })
          }
        }, (item: ResourceStr, index: number) => JSON.stringify(item) + index)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
    .padding({
      top: 20,
      bottom: 32,
      left: 16,
      right: 16
    })
  }
}