import { avSession } from '@kit.AVSessionKit';

@ObservedV2
export class CastServiceModule {
  @Trace public isCasting: boolean = false;
  @Trace isCastPlaying: boolean = false;
  @Trace castCurrentTime: number = 0
  @Trace castDuration: number = 0
  @Trace castResolution: string = ''
  @Trace castVolume: number = 0;
  @Trace castMaxVolume: number = 100;
  @Trace currentDeviceName: string = ''
  @Trace currentDeviceType: avSession.DeviceType = avSession.DeviceType.DEVICE_TYPE_LOCAL
}

export interface CastSessionListener {
  onStartCasting(): void

  onEndCasting(): void

  onPlay(): void

  onPause(): void

  onPlayNext(): void

  onPlayPre(): void

  onSeek(time: number): void

  onFastForward(time: number): void

  onRewind(time: number): void
}