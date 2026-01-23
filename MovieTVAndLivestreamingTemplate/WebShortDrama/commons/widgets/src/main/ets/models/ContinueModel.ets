/**
 * 自由流转-应用接续模型
 */
@ObservedV2
export class ContinueModel {
  @Trace id: number = 0;
  @Trace dramaId: string = ''
  // @Trace randDrama: number = 0
  // @Trace randIndex: number = 0
  @Trace currentIndex: number = 0
  @Trace playTime: number = 0
  @Trace isTargetDevice: boolean = false
}