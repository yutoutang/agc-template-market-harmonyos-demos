import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export enum SliderType {
  VOLUME,
  BRIGHT
}

@ObservedV2
export class PlayerSliderModel {
  @Trace volume: number = 0;
  @Trace bright: number = 0.5;
  // 是否显示音量调节进度
  @Trace showVolumeProgress: boolean = false;
  @Trace showBrightProgress: boolean = false;

  onSliderChange(type: SliderType, value: number, mode: SliderChangeMode) {
    switch (mode) {
      case SliderChangeMode.Begin:
        break;
      case SliderChangeMode.Click:
        break;
      case SliderChangeMode.Moving:
        if (type === SliderType.VOLUME) {
          this.handleVolumeChange(value)
        } else if (type === SliderType.BRIGHT) {
          this.handleBrightChange(value)
        }
        break;
      case SliderChangeMode.End:
        break;
      default:
        break;
    }
  }

  handleVolumeChange(value: number) {
    this.volume = value;
    emitter.emit('systemVolumeChange', {
      data: {
        volume: value
      }
    } as emitter.EventData)
  }

  handleBrightChange(value: number) {
    this.bright = value;
    let windowClass = AppStorage.get<window.Window>('windowClass')
    windowClass?.setWindowBrightness(value);
  }
}