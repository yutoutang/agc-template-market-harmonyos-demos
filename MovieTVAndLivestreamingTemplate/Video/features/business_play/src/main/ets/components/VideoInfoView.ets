import { VideoResponse } from 'lib_video_api'

@ComponentV2
export struct VideoInfoView {
  @Local infoShowSheet: boolean = false
  @Require @Param video: VideoResponse

  build() {
    Column({ space: 4 }) {
      Row() {
        Text(this.video.title).fontSize(20).lineHeight(24).fontWeight(FontWeight.Bold).fontColor(Color.White)
        Row() {
          Text('简介').fontSize(12).lineHeight(14).fontColor('#80FFFFFF').fontWeight(FontWeight.Medium)
          Image($r('app.media.icon_right')).width(12).height(12)
        }
        .bindSheet(this.infoShowSheet, this.infoSheet(), {
          height: SheetSize.MEDIUM,
          dragBar: false,
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          this.infoShowSheet = !this.infoShowSheet;
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 4 }) {
        Image($r('app.media.icon_play_small')).width(14).height(14)
        Text(`已播放${this.video.playCount}次`).fontSize(12).lineHeight(17).fontColor('#80FFFFFF')
      }
      .width('100%')
    }.alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 12 })
  }

  @Builder
  infoSheet() {
    Column({ space: 20 }) {
      Text('简介').fontSize(20).fontColor('#E6000000').lineHeight(24).fontWeight(FontWeight.Bold)
      Column({ space: 5 }) {
        Row({ space: 12 }) {
          Image(this.video.coverUrl).width(78).height(104).borderRadius(6)
          Column({ space: 4 }) {
            Text(this.video.title)
              .fontColor('#E6000000')
              .fontSize(16)
              .lineHeight(19)
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Clip })
              .wordBreak(WordBreak.BREAK_ALL)
            Text(`${this.video.country} | ${this.video.releaseDate}`)
              .fontColor('#E6000000')
              .fontSize(12)
              .lineHeight(17)
            Text('导演：未知')
              .fontColor('#99000000')
              .fontSize(12)
              .lineHeight(17)
            Blank()
            Text(this.video.videoType)
              .fontColor('#99000000')
              .fontSize(12)
              .lineHeight(14)
              .padding({
                top: 2,
                bottom: 3,
                right: 8,
                left: 8
              })
              .backgroundColor('#0D000000')
              .borderRadius(14)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .height(104)
        }

        Scroll() {
          Column() {
            Text(this.video.synopsis).fontColor('#80111111').fontSize(14).lineHeight(20)
          }
          .padding({ top: 5, bottom: 5 })
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
      .layoutWeight(1)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .padding({
      top: 20,
      bottom: 32,
      left: 16,
      right: 16
    })
  }
}