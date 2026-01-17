import { media } from '@kit.MediaKit';
import { audio } from '@kit.AudioKit';
import { AVPlayerState } from '../type/Index';
import { Logger } from '../utils/Logger';

const TAG = '[AVPlayerManager]';

export class AVPlayerManager {
  private static instance?: AVPlayerManager
  private playerConnectMap: Map<number, string> = new Map();
  private playerSessionCache: Map<string, AVPlayerSession> = new Map();

  public static getInstance(): AVPlayerManager {
    if (!AVPlayerManager.instance) {
      AVPlayerManager.instance = new AVPlayerManager()
    }
    return AVPlayerManager.instance
  }

  public getAVPlayer(index: number): media.AVPlayer | undefined {
    let playerId = this.playerConnectMap.get(index);
    return this.playerSessionCache.get(playerId!)?.avPlayer;
  }

  private canPlay(state: string): boolean {
    let canPlayStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED
    ] as string[]
    return canPlayStates.includes(state)
  }

  public async play(index: number) {
    let playerId = this.playerConnectMap.get(index);
    const target = this.playerSessionCache.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (!this.canPlay(target.state)) {
      return;
    }

    try {
      await target.play();
    } catch (err) {
      Logger.debug(TAG, 'play error! avPlayer undefined!');
    }
  }

  public async pause(index: number) {
    let playerId = this.playerConnectMap.get(index);
    const target = this.playerSessionCache.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (target.state !== AVPlayerState.PLAYING) {
      return;
    }

    try {
      await target.pause();
    } catch (err) {
      Logger.debug(TAG, 'pause error! avPlayer undefined!');
    }
  }

  public async release(index: number) {
    let playerId = this.playerConnectMap.get(index);
    if (!this.playerSessionCache.get(playerId!)?.avPlayer) {
      return;
    }

    try {
      await this.playerSessionCache.get(playerId!)?.avPlayer?.release();
    } catch (err) {
      Logger.debug(TAG, 'release error! avPlayer undefined!');
    }
  }

  public seek(index: number, timeMs: number) {
    let playerId = this.playerConnectMap.get(index);
    if (!this.playerSessionCache.get(playerId!)?.avPlayer) {
      return;
    }

    try {
      this.playerSessionCache.get(playerId!)?.avPlayer?.seek(timeMs, media.SeekMode.SEEK_PREV_SYNC);
    } catch (err) {
      Logger.debug(TAG, 'seek error! avPlayer undefined!');
    }
  }

  private canSetSpeed(state: string): boolean {
    let canSetSpeedStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PLAYING,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED
    ] as string[]
    return canSetSpeedStates.includes(state)
  }

  public setSpeed(index: number, speed: media.PlaybackSpeed) {
    let playerId = this.playerConnectMap.get(index);
    const target = this.playerSessionCache.get(playerId!)?.avPlayer;
    if (!target) {
      return;
    }
    if (!this.canSetSpeed(target.state)) {
      return;
    }

    try {
      this.playerSessionCache.get(playerId!)?.avPlayer?.setSpeed(speed);
    } catch (err) {
      Logger.debug(TAG, 'setSpeed error! avPlayer undefined!');
    }
  }

  public setPlayerId(index: number, playerId: string) {
    this.playerConnectMap.set(index, playerId);
  }

  public getPlayerId(index: number): string | undefined {
    return this.playerConnectMap.get(index);
  }

  public setSession(playerId: string, playerSession: AVPlayerSession) {
    this.playerSessionCache.set(playerId, playerSession);
  }

  public getSession(index: number): AVPlayerSession | undefined {
    let playerId = this.playerConnectMap.get(index);
    return this.playerSessionCache.get(playerId!);
  }

  public deleteSession(playerId: string) {
    this.playerSessionCache.delete(playerId);
  }

  public clear() {
    this.playerConnectMap.clear()
    this.playerSessionCache.clear()
  }
}

export class AVPlayerSession {
  public avPlayer: media.AVPlayer | undefined = undefined;
  public avPlayerCallback: Map<string, Array<(...args: ESObject) => void>> = new Map();

  onEvent(key: string, callback: (...args: ESObject) => void): void {
    if (this.avPlayerCallback.has(key)) {
      this.avPlayerCallback.get(key)?.push(callback);
    } else {
      this.avPlayerCallback.set(key, [callback]);
    }
  }

  setAVPlayer(avPlayer: media.AVPlayer) {
    this.avPlayer = avPlayer;
  }

  getAVPlayer() {
    return this.avPlayer;
  }

  private canPlay(state: string): boolean {
    let canPlayStates = [
      AVPlayerState.PREPARED,
      AVPlayerState.PAUSED,
      AVPlayerState.COMPLETED
    ] as string[]
    return canPlayStates.includes(state)
  }

  async play() {
    if (!this.avPlayer) {
      return;
    }
    if (!this.canPlay(this.avPlayer.state)) {
      return;
    }
    try {
      await this.avPlayer.play();
    } catch (err) {
      Logger.debug(TAG, 'play error! avPlayer undefined!');
    }
  }

  async pause() {
    if (!this.avPlayer) {
      return;
    }
    if (this.avPlayer.state !== AVPlayerState.PLAYING) {
      return;
    }

    try {
      await this.avPlayer.pause();
    } catch (err) {
      Logger.debug(TAG, 'pause error! avPlayer undefined!');
    }
  }

  seek(seekTime:number) {
    if (!this.avPlayer) {
      return;
    }
    if (this.avPlayer.state !== AVPlayerState.PREPARED) {
      return;
    }

    try {
      this.avPlayer.seek(seekTime, media.SeekMode.SEEK_PREV_SYNC);
    } catch (err) {
      Logger.debug(TAG, 'seek error! avPlayer undefined!');
    }
  }

}

export function registerAVPlayerCallback(
  avPlayer: media.AVPlayer,
  callbackMap: Map<string, Array<(...args: ESObject) => void>>
) {
  avPlayer.on('durationUpdate', (duration: number) => {
    callbackMap.get('durationUpdate')?.forEach((item) => {
      item(duration);
    });
  });

  avPlayer.on('seekDone', (time: number) => {
    callbackMap.get('seekDone')?.forEach((item) => {
      item(time);
    });
  });

  avPlayer.on('speedDone', (speed: number) => {
    callbackMap.get('speedDone')?.forEach((item) => {
      item(speed);
    });
  });

  avPlayer.on('bitrateDone', (bitrate: number) => {
    callbackMap.get('bitrateDone')?.forEach((item) => {
      item(bitrate);
    });
  });

  avPlayer.on('availableBitrates', (bitrates: Array<number>) => {
    callbackMap.get('availableBitrates')?.forEach((item) => {
      item(bitrates);
    });
  });

  avPlayer.on('volumeChange', (vol: number) => {
    callbackMap.get('volumeChange')?.forEach((item) => {
      item(vol);
    });
  });

  avPlayer.on('endOfStream', () => {
    callbackMap.get('endOfStream')?.forEach((item) => {
      item();
    });
  });

  avPlayer.on('timeUpdate', (time: number) => {
    callbackMap.get('timeUpdate')?.forEach((item) => {
      item(time);
    });
  });

  avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
    callbackMap.get('bufferingUpdate')?.forEach((item) => {
      item(infoType, value);
    });
  });

  avPlayer.on('startRenderFrame', () => {
    callbackMap.get('startRenderFrame')?.forEach((item) => {
      item();
    });
  });

  avPlayer.on('audioOutputDeviceChangeWithInfo', (data: audio.AudioStreamDeviceChangeInfo) => {
    callbackMap.get('audioOutputDeviceChangeWithInfo')?.forEach((item) => {
      item(data);
    });
  });

  avPlayer.on('subtitleUpdate', (info: media.SubtitleInfo) => {
    callbackMap.get('subtitleUpdate')?.forEach((item) => {
      item(info);
    });
  });

  avPlayer.on('trackChange', (index: number, isSelect: boolean) => {
    callbackMap.get('trackChange')?.forEach((item) => {
      item(index, isSelect);
    });
  });

  avPlayer.on('trackInfoUpdate', (info: Array<media.MediaDescription>) => {
    callbackMap.get('trackInfoUpdate')?.forEach((item) => {
      item(info);
    });
  });
}