@ObservedV2
export class KickedDialogModel {
  @Trace title: ResourceStr = '你的账号在其他设备登录，其重新登录';
  @Trace cancelTitle: ResourceStr = '取消';
  @Trace confirmTitle: ResourceStr = '确认';
  onValueConfirmClick = (_model: KickedDialogModel) => {
  };
  onValueConcelClick = (_model: KickedDialogModel) => {
  };
}