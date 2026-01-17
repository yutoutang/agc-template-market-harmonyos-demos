import { audio } from '@kit.AudioKit'
import settings from '@ohos.settings';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PlayerSliderModel } from '../models/PlayerSliderModel'
import { Logger } from './Logger';

const TAG = '[VolumeAndBright]';

export class VolumeAndBright {
  audioManager: audio.AudioManager | undefined = undefined
  audioVolumeManager: audio.AudioVolumeManager | undefined = undefined
  audioVolumeGroupManager: audio.AudioVolumeGroupManager | undefined = undefined
  private hideTimer: number | null = null
  playerSliderModel: PlayerSliderModel = new PlayerSliderModel()

  init() {
    this.audioManager = audio.getAudioManager();
    this.audioVolumeManager = this.audioManager?.getVolumeManager();
    // 获取当前系统音量
    this.getCurrentVolume();
    // 监听系统音量变化
    this.onVolumeChangeListen()

  }

  // 获取当前系统音量
  async getCurrentVolume() {
    try {
      this.audioVolumeGroupManager =
        await this.audioVolumeManager?.getVolumeGroupManager(audio.DEFAULT_VOLUME_GROUP_ID);
      let volume: number | undefined = 0;
      if (deviceInfo.sdkApiVersion >= 20) {
        volume = this.audioVolumeManager?.getVolumeByStream(audio.StreamUsage.STREAM_USAGE_MUSIC);
      } else {
        volume = this.audioVolumeGroupManager?.getVolumeSync(audio.AudioVolumeType.MEDIA)
      }
      if (volume) {
        this.playerSliderModel.volume = volume / 15
      }
    } catch (e) {
      Logger.error(TAG, 'getCurrentVolume fail, error: ' + JSON.stringify(e));
    }
  }

  // 音量进度条的显隐
  handleVolumeProgressChange() {
    // 清除之前的计时器
    if (this.hideTimer) {
      clearTimeout(this.hideTimer)
    }
    this.playerSliderModel.showVolumeProgress = true;

    this.hideTimer = setTimeout(() => {
      this.playerSliderModel.showVolumeProgress = false;
      // 清除计时器
      if (this.hideTimer) {
        clearTimeout(this.hideTimer)
      }
    }, 3000);
  }

  // 监听系统音量变化
  onVolumeChangeListen() {
    try {
      if (deviceInfo.sdkApiVersion >= 20) {
        this.audioVolumeManager?.on('streamVolumeChange', audio.StreamUsage.STREAM_USAGE_MUSIC,
          (streamVolumeEvent: audio.StreamVolumeEvent) => {
            this.handleVolumeProgressChange()
            this.playerSliderModel.volume = streamVolumeEvent.volume / 15
          });
      } else {
        this.audioVolumeManager?.on('volumeChange', (volumeEvent: audio.VolumeEvent) => {
          this.handleVolumeProgressChange()
          this.playerSliderModel.volume = volumeEvent.volume / 15
        });
      }
    } catch (e) {
      Logger.error(TAG, 'onVolumeChangeListen fail, error: ' + JSON.stringify(e));
    }
  }

  // 取消监听系统音量变化
  offVolumeChangeListen() {
    try {
      if (deviceInfo.sdkApiVersion >= 20) {
        this.audioVolumeManager?.off('streamVolumeChange');
      } else {
        this.audioVolumeManager?.off('volumeChange');
      }
    } catch (e) {
      Logger.error(TAG, 'offVolumeChangeListen fail, error: ' + JSON.stringify(e));
    }
  }

  // 设置亮度
  updateBrightness(context: Context) {
    let value = settings.getValueSync(context, settings.display.SCREEN_BRIGHTNESS_STATUS, '100')
    this.playerSliderModel.bright = Number(value) / 255 ?? 0.5;
  }
}