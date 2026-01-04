/**
 * 窗口持久化
 */
@ObservedV2
export class RunWindowModel {
  @Trace windowHeight: number = 0;
  @Trace windowTopPadding: number = 40;
  @Trace windowBottomPadding: number = 28;
  @Trace windowWidth: number = 0;
}