import { CommonConfirmDialog } from 'lib_common';

@ComponentV2
export struct SetReadIcon {
  @Param enable: boolean = true;
  @Event confirm: () => void = () => {
  };

  build() {
    Row() {
      Image($r('app.media.ic_public_clean'))
        .width($r('app.float.large_img_size'))
        .aspectRatio(1)
        .draggable(false)
        .onClick(() => {
          if (this.enable) {
            CommonConfirmDialog.show({
              primaryTitle: '温馨提示',
              content: '您确定将全部未读消息标记为已读？',
              secBtnV: '确定',
              confirm: () => {
                this.confirm();
              },
            });
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '暂无未读消息' });
          }
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}