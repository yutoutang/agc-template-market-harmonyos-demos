import { PlayerAnimation } from './animation/PlayerAnimation'
import { MediaViewModel } from './viewmodel/MediaViewModel'
import { ControlAreaComponent } from './components/ControlAreaComponent'
import { AudioItem, AudioPlayerState } from './model/AudioData'

@ComponentV2
export struct AudioPlayer {
  /*
   * 封面宽度
   * */
  @Param coverWidth: number = 104
  /*
   * 封面高度
   * */
  @Param coverHeight: number = 104
  /*
   * 音频组索引
   * */
  @Param audioGroupIndex: number = 0
  /*
   * 音频组单个音频索引
   * */
  @Param audioIndex: number = -1
  /*
   * 是否需要底部操作栏
   * */
  @Param hasOperation: boolean = true
  /*
   * 是否需要跳转详情页
   * */
  @Param canRedirect: boolean = true
  @Param fontSizeRatio: number = 1
  @Event checkPlayPrevious: (currentIndex: number) => boolean = () => true;
  @Event checkPlayNext: (currentIndex: number, isAutoNext: boolean) => boolean = () => true;
  @Event onAudioTitle: (audioInfo: AudioItem) => void = () => {
  }
  @Event onAudioStateChange: (state: AudioPlayerState) => void = () => {
  }
  // 播放前置动作
  @Event preAction: () => Promise<void> = () => Promise.resolve();
  @Local start: boolean = true;
  private step: number = 5;
  private loop: number = Number.POSITIVE_INFINITY;
  private fromStart: boolean = true;
  @Local mediaService: MediaViewModel = MediaViewModel.getInstance()
  @Local playerAnimation: PlayerAnimation = new PlayerAnimation()

  @Monitor('audioGroupIndex')
  async audioGroupIndexChange() {
    this.mediaService.isFirst = true
    this.mediaService.loadAssent(0);
  }

  @Monitor('mediaService.state')
  audioStateChange() {
    this.onAudioStateChange(this.mediaService.state)
  }

  aboutToAppear(): void {
    MediaViewModel.getInstance().checkPlayPrevious = (currentIndex) => {
      return this.checkPlayPrevious(currentIndex);
    }

    MediaViewModel.getInstance().checkPlayNext = (currentIndex, isAutoNext) => {
      return this.checkPlayNext(currentIndex, isAutoNext);
    };
  }

  build() {
    Column() {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Image(this.mediaService.audioList[this.mediaService.audioIndex]?.mark)
            .objectFit(ImageFit.Fill)
            .rotate({ angle: this.playerAnimation.imageRotate })
            .onAppear(() => {
              this.playerAnimation.playerCoverRotate()
            })
          SymbolGlyph(this.mediaService.isPlaying ? $r('sys.symbol.pause_circle_fill') :
            $r('sys.symbol.play_circle_fill'))
            .fontSize(36)
            .fontColor([$r('sys.color.font_on_secondary')])
            .visibility(this.mediaService.loadAudio ? Visibility.None : Visibility.Visible)
          LoadingProgress()
            .color($r('sys.color.icon_on_primary'))
            .width(40)
            .height(40)
            .visibility(this.mediaService.loadAudio ? Visibility.Visible : Visibility.None)
        }
        .width(this.coverWidth)
        .height(this.coverHeight)
        .clip(true)
        .borderRadius('50%')
      }
      .borderRadius('50%')
      .onClick(() => {
        this.preAction().then(() => {
          if (this.mediaService.getFirst()) {
            this.mediaService.loadAssent(0);
          } else {
            this.mediaService.isPlaying ? this.mediaService.pause() : this.mediaService.play();
          }
        })
      })
      .border({
        width: 4,
        color: $r('sys.color.comp_background_secondary'),
      })
      .visibility(this.hasOperation ? Visibility.None : Visibility.Visible)

      Image(this.mediaService.audioList[this.mediaService.audioIndex]?.mark)
        .objectFit(ImageFit.Fill)
        .width(104)
        .height(104)
        .borderRadius(8)
        .clip(true)
        .visibility(this.hasOperation ? Visibility.Visible : Visibility.None)

      Row({ space: 4 }) {
        Text('正在直播：')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize(16 * this.fontSizeRatio)
        Marquee({
          start: this.mediaService.isPlaying,
          step: this.step,
          loop: this.loop,
          fromStart: this.fromStart,
          src: this.mediaService.audioList[this.mediaService.audioIndex]?.title,
        })
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .width('30%')
      }
      .margin({ top: 16 })
      .width('100%')
      .justifyContent(FlexAlign.Center)

      Row({ space: 4 }) {
        Text(this.mediaService.audioList[this.mediaService.audioIndex]?.mainTitle)
          .fontSize(14 * this.fontSizeRatio)
          .fontColor($r('sys.color.font_secondary'))
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(14)
          .fontColor([$r('sys.color.icon_secondary')])
          .visibility(this.canRedirect ? Visibility.Visible : Visibility.None)
      }
      .margin({ top: 8 })
      .onClick(() => {
        this.onAudioTitle(this.mediaService.audioList[this.mediaService.audioIndex])
      })

      ControlAreaComponent()
        .visibility(this.hasOperation ? Visibility.Visible : Visibility.None)
    }
  }
}