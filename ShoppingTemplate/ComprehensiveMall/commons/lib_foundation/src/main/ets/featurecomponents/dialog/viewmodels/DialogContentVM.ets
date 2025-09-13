@ObservedV2
export class DialogContentVM {
  @Trace
  public message: string = '';

  @Trace
  public confirmButtonText: string = '确定';

  @Trace
  public cancelButtonText: string = '取消';

  @Trace
  public confirm: () => void = () => {};

  @Trace
  public cancel: () => void = () => {};
}
