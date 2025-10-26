import { Constants as Const } from '../constant/Contants'
import { AvPlayer } from '../controller/AvPlayer';
import { PlaySession } from '../controller/PlaySession';
import { secondToTime } from '../utils/CommonUtils';
import { ProcessController } from './ProcessController';

/**
 * 功能描述：进度条默认实现，通过play session感知播放变化并控制播放进度
 */
@ComponentV2
export struct ProcessBar {
  @Param @Require avPlayer: AvPlayer
  @Local processController: ProcessController | undefined = undefined

  aboutToAppear(): void {
    this.processController = new ProcessController(this.avPlayer)
  }

  build() {
    this.playControlBar()
  }

  @Builder
  playControlBar() {
    // 控制条
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Row() {
          Text(this.processController?.currentStringTime)
            .fontSize(20)
            .fontColor(Color.White)
            .margin({ left: 2 })
            .width('45%')
            .textAlign(TextAlign.End)

          Divider()
            .vertical(true)
            .height(14)
            .width(2)
            .backgroundBlurStyle(BlurStyle.Regular, { colorMode: ThemeColorMode.LIGHT })
            .color(Color.White)
            .opacity(0.5)
            .margin({ left: 8, right: 8 })
            .rotate({
              x: 0,
              y: 0,
              z: 1,
              centerX: '50%',
              centerY: '50%',
              angle: 30
            })

          Text(this.processController?.durationStringTime)
            .fontSize(20)
            .fontColor(Color.White)
            .margin({ left: 2 })
            .width('45%')
            .textAlign(TextAlign.Start)
            .opacity(0.5)
        }
        .width('50%')
        .visibility(this.processController?.isSliderMoving ? Visibility.Visible : Visibility.Hidden)

        Slider({
          value: this.avPlayer?.currentTime,
          step: 0.1,
          min: 0,
          max: this.avPlayer?.durationTime,
          style: SliderStyle.NONE
        })
          .width('100%')
          .height(15)
          .padding({ top: 12 })
          .selectedColor(Color.White)
          .trackColor('#3fff')
          .showSteps(false)
          .showTips(false)
          .animation({ duration: 100, curve: Curve.Smooth })
          .trackThickness(this.processController?.trackThicknessSize)
          .trackBorderRadius(2)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.processController?.sliderOnChange(value, mode);
          })
          .zIndex(3)
      }
    }
  }
}