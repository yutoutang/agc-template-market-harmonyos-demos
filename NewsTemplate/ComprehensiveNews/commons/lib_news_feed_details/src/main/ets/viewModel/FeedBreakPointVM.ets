import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel, BreakpointNameEnum } from 'lib_common';

@ObservedV2
export class FeedBreakPointVM {
  @Trace isSplit: boolean = false
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Computed
  get getNewsLanes() {
    return this.isFolderStatus  ? 2 : 1
  }

  @Computed
  get isFolderStatus() {
    return this.isSmDevice && this.isSplit
  }

  @Computed
  get isSmDevice() {
    return this.breakpointModel.currentBreakpoint !== BreakpointNameEnum.SM
  }

  public switchSplit() {
    animateTo({
      duration: 200,
      curve: Curve.EaseOut,
      playMode: PlayMode.Normal,
    }, () => {
      this.isSplit = !this.isSplit
    })
  }
}