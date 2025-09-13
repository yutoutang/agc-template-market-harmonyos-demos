@Builder
export function VideoPreviewBuilder() {
  VideoPreview()
}

@ComponentV2
export struct VideoPreview {
  @Local videoSrc: ResourceStr = ''
  @Local previewUri: string = 'common/videoIcon.png'
  @Local curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @Local currentTime: number = 0
  @Local durationTime: number = 0
  controller: VideoController = new VideoController()

  build() {
    NavDestination() {
      Column() {
        Column() {
          Video({
            src: this.videoSrc,
            previewUri: this.previewUri,
            currentProgressRate: this.curRate,
            controller: this.controller,
          })
            .controls(true)
            .autoPlay(true)
            .onPrepared((event) => {
              if (event) {
                this.durationTime = event.duration
              }
            })
            .onUpdate((event) => {
              if (event) {
                this.currentTime = event.time
              }
            })
        }
        .width('100%')
      }
      .height('90%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title('')
    .padding({ top: 48 })
    .onReady((ctx) => {
      this.videoSrc = ctx.pathInfo.param as string
    })
  }
}