import { saveAlbumTool, SaveAlbumTool } from '../utils/SaveAlbumTool';
import { ChatBreakpoint } from '../utils/ChatBreakpoint';
import { AppStorageV2 } from '@kit.ArkUI';
import { RcpDownloader } from '../utils/RcpDownloader';
import { rcp } from '@kit.RemoteCommunicationKit';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct VideoPage {
  @Param @Require videoChatSrc: string
  @Param @Require videoStatus: boolean
  @Local mutedBoolean: boolean = true
  controller: VideoController = new VideoController()
  @Local chatBreakpoint: ChatBreakpoint = AppStorageV2.connect(ChatBreakpoint, () => new ChatBreakpoint())!;
  @Local isVideoStop: boolean = false
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private uiCtx = this.getUIContext()
  saveAlbumTool: SaveAlbumTool = new SaveAlbumTool()
  @Event onReturnClick: () => void = () => {
  }
  downloader: RcpDownloader = new RcpDownloader(this.context)

  aboutToAppear(): void {
    this.mutedBoolean = !this.videoStatus
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back_white'))
          .width(40)
          .height(40)
          .position({ left: 16, top: 4 + this.chatBreakpoint.topValue })
          .onClick(() => {
            this.onReturnClick()
          })
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height(85)
      .margin({ bottom: 10 })

      Stack({ alignContent: Alignment.BottomEnd }) {
        Stack({ alignContent: Alignment.Center }) {
          Video({
            src: this.videoChatSrc,
            controller: this.controller
          })
            .muted(this.mutedBoolean)// 设置是否静音
            .controls(false)// 设置是否显示默认控制条
            .autoPlay(true)// 设置是否自动播放
            .loop(false)// 设置是否循环播放
            .width('100%')
            .onStop(() => { // 停止事件回调
              this.isVideoStop = true
            })
            .onStart(() => {
              this.isVideoStop = false;
            })
            .onPause(() => {
              this.isVideoStop = true;
            })
            .onClick(() => {
              if (this.isVideoStop) {
                this.isVideoStop = false
                this.controller.start();
              } else {
                this.isVideoStop = true
                this.controller.pause();
              }

            })
          if (this.isVideoStop) {
            Image($r('app.media.video_image_stop'))
              .width(100)
              .height(100)
              .onClick(() => {
                this.isVideoStop = false
                this.controller.start();
              })
          }
        }

        Row() {
          Image(this.mutedBoolean ? $r('app.media.mutetrue') : $r('app.media.mutedfalse'))
            .width(40)
            .height(40)
            .margin({ right: 10 })
            .onClick(() => {
              if (this.mutedBoolean) {
                this.mutedBoolean = false
              } else {
                this.mutedBoolean = true
              }
            })
          Image($r('app.media.download'))
            .width(40)
            .height(40)
            .onClick(() => {
              let videoName: string = this.videoChatSrc.split('/').pop() as string
              videoName = videoName.split('?')[0]
              let videoFilePath = `${this.context.cacheDir}/downloads/` + videoName
              this.downloader.startDownload(this.videoChatSrc, videoName).then((result: rcp.Response) => {
                if (result.statusCode === 200) {
                  saveAlbumTool.saveHttpVideo(videoFilePath, this.getUIContext())
                } else {
                  this.getUIContext().getPromptAction().showToast({ message: '视频下载成功' })
                }
              }).catch(() => {
                this.getUIContext().getPromptAction().showToast({ message: '视频下载失败' })
              })
            })
        }
        .margin({ right: 20, bottom: 10 })
      }
      .height('87%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}
