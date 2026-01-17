@ObservedV2
export class ControlStateModel {
  @Trace isPlay: boolean = false
  @Trace currentTime: string = '00:00';
  @Trace totalTime: string = '00:00';
  @Trace progress: number = 0;
  @Trace progressMax: number = 0;
  @Trace playModeIndex: number = 0;
  @Trace imageColor: string = '';
  @Trace pageShowTime: number = 0;
}