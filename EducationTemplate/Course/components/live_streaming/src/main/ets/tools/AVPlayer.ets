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

// AVPlayer 类用于处理视频播放相关的逻辑。
@ObservedV2
export class AVPlayer {
  @Trace currentTime: number = 0;
  @Trace totalDuration: number = 0;
  @Trace isPlaying: boolean = false;
  @Trace isLoading: boolean = true;
  @Trace isLoadError: boolean = false;
  // 画中画是否开启
  isPiPWindowLoad: boolean = false;
  // 复原
  isPiPWindowRestore: boolean = false;
  surfaceID: string = '';
  avPlayer: media.AVPlayer = {} as media.AVPlayer;
  isCreate: boolean = false;

  async init(url: string): Promise<void> {
    await this.release();
    this.isCreate = true;
    this.avPlayer = await media.createAVPlayer();
    await this.setStateChangeCallback();
    await this.setSourceInfoCallback();
    this.avPlayer.url = url;
    this.isLoading = true;
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
      this.avPlayer.setVolume(volume);
    }
  }

  changeSpeed(speed: number) {
    if (this.avPlayer) {
      this.avPlayer.setSpeed(speed);
    }
  }

  changeSeek(seekTime: number, mode: SliderChangeMode) {
    if (this.avPlayer) {
      this.avPlayer.seek(seekTime, 2);
    }
  }

  setSurfaceId(surfaceId: string): void {
    if (this.avPlayer.surfaceId === surfaceId) {
      return;
    }
    this.surfaceID = surfaceId;
    this.avPlayer.surfaceId = this.surfaceID;
  }

  // 资源释放
  async release() {
    if (this.isCreate) {
      this.isCreate = false;
      this.isPlaying = false;
      this.isLoading = false;
      this.isLoadError = false;
      await this.avPlayer.release();
    }
  }

  // 视频信息上报函数
  async setSourceInfoCallback(): Promise<void> {
    // 时间上报函数
    this.avPlayer.on('timeUpdate', (time: number) => {
      this.currentTime = time;
    });
    // 音量变化回调函数
    this.avPlayer.on('volumeChange', (vol: number) => {
    });
    // 视频播放结束触发回调
    this.avPlayer.on('endOfStream', () => {
    });
    // seek操作回调函数
    this.avPlayer.on('seekDone', (seekDoneTime: number) => {
    });
    // 视频总时长上报函数
    this.avPlayer.on('durationUpdate', (duration: number) => {
    });
    // 设置倍速播放回调函数
    this.avPlayer.on('speedDone', (speed: number) => {
    });
    // bitrate设置成功回调函数
    this.avPlayer.on('bitrateDone', (bitrate: number) => {
    });
    // 缓冲上报回调函数
    this.avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
    });
    // 首帧上报回调函数
    this.avPlayer.on('startRenderFrame', () => {
    });
    // 视频宽高上报回调函数
    this.avPlayer.on('videoSizeChange', (width: number, height: number) => {
    });
    // 焦点上报回调函数
    this.avPlayer.on('audioInterrupt', (info: audio.InterruptEvent) => {
    });
    // HLS上报所有支持的比特率
    this.avPlayer.on('availableBitrates', (bitrates: number[]) => {
    });
    // 设置错误监听
    this.avPlayer.on('error', (error) => {
      this.isPlaying = false;
      this.isLoading = false;
      this.isLoadError = true;
    });
  }

  // 状态机
  async setStateChangeCallback(): Promise<void> {
    this.avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      if (this.avPlayer == null) {
        return;
      }
      switch (state) {
        // 闲置状态,成功调用reset接口后触发该状态机上报
        case AVPlayerState.IDLE:
          this.isLoadError = false;
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
          this.avPlayer.seek(this.currentTime, 2);
          this.isPlaying = true;
          this.avPlayer.loop = true;
          this.avPlayer.play();
          this.isLoadError = false;
          break;
        // 正在播放状态
        case AVPlayerState.PLAYING:
          this.isLoading = false;
          break;
        // 暂停状态
        case AVPlayerState.PAUSED:
          this.isLoading = false;
          break;
        // 播放至结尾状态
        case AVPlayerState.COMPLETED:
          this.isPlaying = false;
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
          break;
        default:
          break;
      }
    });
  }
}