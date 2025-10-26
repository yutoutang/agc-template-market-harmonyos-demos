import { AvPlayer } from '../controller/AvPlayer';
import { secondToTime } from '../utils/CommonUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[ProgressController]'
const DOMAIN = 0x0000
@ObservedV2
export class ProcessController {
  avPlayerController: AvPlayer
  @Trace isSliderMoving: boolean = false;
  @Trace progressWidth: number = 0;
  @Trace currentTime: number = 0;
  @Trace currentStringTime: string = '00:00';
  @Trace durationTime: number = 0;
  @Trace durationStringTime: string = '00:00';
  @Trace trackThicknessSize: number = 2;
  @Trace sliderStyle: SliderStyle = SliderStyle.NONE;

  constructor(avPlayerController: AvPlayer) {
    this.avPlayerController = avPlayerController
    this.durationTime = this.avPlayerController.durationTime
    this.durationStringTime = this.avPlayerController.durationStringTime
    hilog.info(DOMAIN, TAG, `durationTime:${this.durationTime}`)
  }

  sliderOnChange(seconds: number, mode: SliderChangeMode) {
    let seekTime: number = seconds * this.avPlayerController.duration / this.avPlayerController.durationTime;
    this.currentStringTime = secondToTime(Math.floor(seekTime / 1000));
    this.currentTime = Math.floor(seekTime / 1000)
    this.durationTime = this.avPlayerController.durationTime
    this.durationStringTime = this.avPlayerController.durationStringTime
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        this.isSliderMoving = true;
        this.trackThicknessSize = 4;
        this.sliderStyle = SliderStyle.OutSet;
        break;
      case SliderChangeMode.End:
        this.avPlayerController.seek(seekTime);
        this.trackThicknessSize = 2;
        this.sliderStyle = SliderStyle.NONE;
        this.isSliderMoving = false;
        break;
      default:
        break;
    }
  }
}