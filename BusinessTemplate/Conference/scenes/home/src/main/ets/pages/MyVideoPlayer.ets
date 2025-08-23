import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { MyConfig } from 'commons';

interface paramsObject {
  src: '',
  url: '',
}

// 跳转页面入口函数
@Builder
export function MyVideoPlayerBuilder() {
  MyVideoPlayer()
}

@Component
struct MyVideoPlayer {
  @StorageProp('deviceId') deviceId: string = '';
  @Consume('pageStack') pageStack: NavPathStack
  @State src: string = '';
  @State url: string = '';
  controller: VideoController = new VideoController()
  @State isPlay: boolean = false;
  @State isFull: boolean = false;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State maxValue: number = 0; // Total duration of the bottom time bar.
  @State nowValue: number = 0; // Current seconds of the bottom time bar.
  @State playTime: number = 0; // Playback time transferred from the previous page.
  @State isShowProgressBar: boolean = true; // Playback time transferred from the previous page.
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'

  private changeOrientation(isLandscape: boolean) {
    let context = getContext(this) as common.UIAbilityContext;
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT);
    });
  }

  aboutToAppear(): void {
    let params: paramsObject = this.pageStack.getParamByName('MyVideoPlayer')[0] as paramsObject
    this.src = params.src
    this.url = params.url
  }

  changTime(times: number): string {
    if (times <= 0) {
      return '00:00';
    } else {
      let mm = Math.floor(times / 60);
      let ss = Math.floor(times % 60);
      return (mm < 10 ? '0' + mm : mm) + ':' + (ss < 10 ? '0' + ss : ss);
    }
  }

  setBarHide() {
    setTimeout(() => {
      this.isShowProgressBar = false
    }, 1000 * 3)
  }

  build() {
    NavDestination() {
      Row() {
        Stack() {
          Video({
            src: this.src,
            previewUri: this.url,
            controller: this.controller
          })
            .width(this.currentBreakpoint === 'sm' ? '100%' : 540 )
            .height('100%')
            .autoPlay(false)
            .controls(this.isFull ? true : false)// .controls(true)
            .aspectRatio(1.778)
            .objectFit(ImageFit.Auto)
            .id('fullVideo')
            .onClick(() => {
              this.isShowProgressBar = true
              if (this.isPlay) {
                this.setBarHide()
              }
            })
            .onPause(() => {
              this.isPlay = false;
              this.isShowProgressBar = true
            })
            .onFullscreenChange((event) => {
              if (event.fullscreen) {
                this.changeOrientation(true);
              } else {
                this.isFull = false
                this.changeOrientation(false);
              }
            })
            .onStart(() => {
              this.isPlay = true;
              this.setBarHide()
            })
            .onPrepared((e) => {
              this.controller.setCurrentTime(this.playTime);
              this.maxValue = e.duration;
            })
            .onUpdate((e) => {
              this.nowValue = e.time;
            })
            .border({
              width: 2
            })
          if (this.isShowProgressBar) {
            RelativeContainer() {
              Row() {
                if (!this.isPlay) {
                  Image(MyConfig.URL + 'new_home%2FvideoPlay.svg?token=10048c00-c909-448c-8f71-44122f177535')
                    .width(20)
                    .onClick(() => {
                      this.controller.start();
                    })
                }
                if (this.isPlay) {
                  Image(MyConfig.URL + 'new_home%2FvideoPause.svg?token=6f1c8b8c-e16f-4de1-81e1-2fdc6fce674c')
                    .width(20)
                    .onClick(() => {
                      this.controller.pause();
                    })
                }

                Row() {
                  Text(this.changTime(Number.parseInt(this.nowValue.toFixed(0)))).fontSize(14).fontColor('#99ffffff')
                  Slider({
                    value: this.nowValue,
                    min: 0,
                    max: this.maxValue,
                    style: SliderStyle.OutSet,
                  })
                    .blockBorderWidth(1)
                    .blockColor(Color.White)
                    .trackColor($r('sys.color.comp_background_secondary'))
                    .selectedColor($r('sys.color.comp_background_emphasize'))
                    .showSteps(false)
                    .onChange((value: number, mode: SliderChangeMode) => {
                      this.nowValue = value;
                      this.controller.setCurrentTime(value);
                    })

                    .layoutWeight(1)
                  Text(this.changTime(Number.parseInt(this.maxValue.toFixed(0))))
                    .fontSize(14)
                    .fontColor('#99ffffff')
                }
                .layoutWeight(1)
                .margin({
                  left: 6,
                  right: 6,
                })


                Image(MyConfig.URL + 'new_home%2FvideoFull.svg?token=374802d3-d0bf-42b3-8de3-1ffbe34b7c85')
                  .width(20)
                  .margin({
                    left: 6
                  }).onClick(() => {
                  this.isFull = true
                  this.controller.requestFullscreen(true)
                })
              }
              .padding({
                left: 10,
                right: 10
              })
              .width('100%')
              .alignRules({
                bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              })
            }
            .margin({
              bottom: 14
            })
            .width('100%')
            .height('100%')
            .aspectRatio(1.778)
            .zIndex(3)
          }
        }
      }
      .justifyContent(FlexAlign.Center)
      // .width(this.currentBreakpoint === 'sm' ? '100%' : 360)
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }

    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .padding({ top: px2vp(this.topRectHeight) })
    .height('100%')
    .width('100%')
  }
}