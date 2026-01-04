/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { audio } from '@kit.AudioKit';
import { media } from '@kit.MediaKit';
import hilog from '@ohos.hilog';

// AVPlayer的状态机
enum AVPlayerState {
  IDLE = 'idle',
  INITIALIZED = 'initialized',
  PREPARED = 'prepared',
  PLAYING = 'playing',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  STOPPED = 'stopped',
  RELEASED = 'released',
  ERROR = 'error'
}

const TAG = '[AVPlayer]'

// AVPlayer 类用于处理视频播放相关的逻辑。
@ObservedV2
export class AVPlayer {
  callbackComplete: () => void = () => {
  };
  callbackTimeUpdate: (nol: number, total: number) => void = (nol: number) => {
  };
  callbackBitrateUpdate: (bitrateList: number[]) => void = (bitrateList: number[]) => {
  };
  callbackErrorUpdate: (error: string) => void = (error: string) => {
  };
  @Trace currentTime: number = 0;
  @Trace totalDuration: number = 0;
  @Trace isPlaying: boolean = false;
  @Trace isLoading: boolean = true;
  @Trace isLoadError: boolean = false;
  // surfaceID用于播放画面显示，具体的值需要通过XComponent接口获取，相关文档链接见上面XComponent创建方法
  surfaceID: string = '';
  // 画中画是否开启
  isPipOpen: boolean = false;
  // 复原
  isPiPWindowRestore: boolean = false;
  avPlayer: media.AVPlayer = {} as media.AVPlayer;
  isCreate: boolean = false;
  seekTime: number = 0;
  // 碰到特殊场景进入其他页时，即便加载成功也不需要播放
  isResetPause: boolean = false;

  async init(url: string, seekTime: number): Promise<void> {
    await this.release();
    // 创建avPlayer实例对象
    this.avPlayer = await media.createAVPlayer();
    // 创建状态机变化回调函数
    await this.setStateChangeCallback();
    this.setSourceInfoCallback();
    this.isCreate = true;
    this.isResetPause = false;
    this.avPlayer.url = url;
    this.isLoading = true;
    this.seekTime = seekTime;
  }

  getPlay() {
    if (this.avPlayer) {
      this.avPlayer.play();
    }
  }

  getPause() {
    if (this.avPlayer) {
      this.avPlayer.pause();
    }
  }

  getStop() {
    if (this.avPlayer) {
      this.avPlayer.stop();
    }
  }

  changeVolume(volume: number) {
    if (this.avPlayer) {
      this.avPlayer.setVolume(volume)
    }
  }

  changeSpeed(speed: number) {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(speed)
    }
  }

  changeSeek(seekTime: number, mode: SliderChangeMode) {
    if (this.avPlayer) {
      this.avPlayer.seek(seekTime, 2);
    }
  }

  setSurfaceId(surfaceId: string): void {
    if (this.avPlayer.surfaceId === surfaceId) {
      return
    }
    this.surfaceID = surfaceId
    this.avPlayer.surfaceId = this.surfaceID;
  }

  // 切换播放
  async changePlay(url: string, seekTime: number) {
    if (this.avPlayer) {
      setTimeout(() => {
        this.isLoadError = false
      }, 1000)
      this.isPlaying = false
      this.isLoading = true
      this.isResetPause = false;
      await this.avPlayer.reset()
      this.totalDuration = 0
      this.seekTime = seekTime
      this.avPlayer.url = url
    }
  }

  setCompleteCallback(func: () => void) {
    this.callbackComplete = func;
    this.isPlaying = false
  }

  setTimeUpdateCallback(func: (nol: number, total: number) => void) {
    this.callbackTimeUpdate = func;
  }

  setBitrateUpdateCallback(func: (bitrateList: number[]) => void) {
    this.callbackBitrateUpdate = func;
  }

  setErrorCallback(func: (error: string) => void) {
    this.callbackErrorUpdate = func;
  }

  // 资源释放
  async release() {
    if (this.isCreate) {
      this.isCreate = false;
      this.isPlaying = false;
      this.isLoading = false;
      this.isLoadError = false;
      this.isResetPause = false;
      await this.avPlayer.release();
    }
  }

  // 视频信息上报函数
  setSourceInfoCallback() {
    // 时间上报函数
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time
      this.callbackTimeUpdate(time, this.totalDuration);
    });
    // 音量变化回调函数
    this.avPlayer.on('volumeChange', (vol: number) => {
      hilog.info(0x0000, TAG, 'volumeChange vol：: %{public}s', JSON.stringify(vol));
    });
    // 视频播放结束触发回调
    this.avPlayer.on('endOfStream', () => {
      hilog.info(0x0000, TAG, 'endOfStream')
    });
    // seek操作回调函数
    this.avPlayer.on('seekDone', (seekDoneTime: number) => {
      hilog.info(0x0000, TAG, 'seekDone seekDoneTime：: %{public}s', JSON.stringify(seekDoneTime));
    });
    // 视频总时长上报函数
    this.avPlayer.on('durationUpdate', (duration: number) => {
      hilog.info(0x0000, TAG, 'durationUpdate duration：: %{public}s', JSON.stringify(duration));
    });
    // 设置倍速播放回调函数
    this.avPlayer.on('speedDone', (speed: number) => {
      hilog.info(0x0000, TAG, 'speedDone speed：: %{public}s', JSON.stringify(speed));
    });
    // bitrate设置成功回调函数
    this.avPlayer.on('bitrateDone', (bitrate: number) => {
      hilog.info(0x0000, TAG, 'bitrateDone bitrate：: %{public}s', JSON.stringify(bitrate));

    });
    // 缓冲上报回调函数
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      hilog.info(0x0000, TAG, 'bufferingUpdate infoType：: %{public}s', JSON.stringify(infoType));
      hilog.info(0x0000, TAG, 'bufferingUpdate value：: %{public}s', JSON.stringify(value));
    });
    // 首帧上报回调函数
    this.avPlayer.on('startRenderFrame', () => {
      hilog.info(0x0000, TAG, 'startRenderFrame')
    });
    // 视频宽高上报回调函数
    this.avPlayer.on('videoSizeChange', (width: number, height: number) => {
      hilog.info(0x0000, TAG, 'videoSizeChange width：: %{public}s', JSON.stringify(width));
      hilog.info(0x0000, TAG, 'videoSizeChange height：: %{public}s', JSON.stringify(height));
    });
    // 焦点上报回调函数
    this.avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => {
      hilog.info(0x0000, TAG, 'audioInterrupt info：: %{public}s', JSON.stringify(info));
    });
    // HLS上报所有支持的比特率
    this.avPlayer.on('availableBitrates', (bitrates: number[]) => {
      this.callbackBitrateUpdate(bitrates);
    });
    // 设置错误监听
    this.avPlayer.on('error', (error) => {
      this.callbackErrorUpdate('Error ' + error.code + ' - ' + error.message);
    });
  }

  // 状态机
  async setStateChangeCallback(): Promise<void> {
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      if (this.avPlayer === null) {
        return;
      }
      switch (state) {
        // 闲置状态,成功调用reset接口后触发该状态机上报
        case AVPlayerState.IDLE:
          this.isLoadError = false
          break;
        // 资源初始化，avplayer设置播放源后触发该状态上报
        case AVPlayerState.INITIALIZED:
          if (this.surfaceID) {
            this.setSurfaceId(this.surfaceID); // 设置显示画面，当播放的资源为纯音频时无需设置
            this.avPlayer.prepare(); // 进入准备状态
          }
          break;
        // 已准备状态
        case AVPlayerState.PREPARED:
          this.avPlayer.audioInterruptMode = audio.InterruptMode.INDEPENDENT_MODE;
          this.totalDuration = this.avPlayer.duration;
          this.currentTime = this.totalDuration * this.seekTime / 100
          this.avPlayer.seek(this.currentTime, 2);
          if (this.isResetPause) {
            this.isPlaying = false;
            this.avPlayer.pause()
          } else {
            this.isPlaying = true;
            this.avPlayer.play();
          }
          this.changeSpeed(media.PlaybackSpeed.SPEED_FORWARD_1_00_X)
          this.isLoadError = false;
          break;
        // 正在播放状态
        case AVPlayerState.PLAYING:
          this.isLoading = false;
          this.isPlaying = true;
          break;
        // 暂停状态
        case AVPlayerState.PAUSED:
          this.isLoading = false;
          this.isPlaying = false;
          break;
        // 播放至结尾状态
        case AVPlayerState.COMPLETED:
          this.isPlaying = false
          this.callbackComplete();
          break;
        // 停止状态
        case AVPlayerState.STOPPED:
          break;
        // 销毁状态，销毁与当前AVPlayer关联的播放引擎，无法再进行状态转换
        case AVPlayerState.RELEASED:
          this.isLoading = true;
          break;
        // 错误状态，当播放引擎发生不可逆的错误，则会转换至当前状态
        case AVPlayerState.ERROR:
          setTimeout(() => {
            this.isPlaying = false;
            this.isLoading = false;
            this.isLoadError = true;
          }, 1000)
          break;
        default:
          break;
      }
    })
  }
}