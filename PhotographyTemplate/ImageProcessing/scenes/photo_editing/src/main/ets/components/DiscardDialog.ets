import { RouterModule } from 'commonlib';

@CustomDialog
export struct DiscardDialog {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text('是否放弃当前操作？')
        .fontSize(16)
        .height(16)
        .width(144)
        .margin({ top: 24, bottom: 24 })
        .textAlign(TextAlign.Center)
      Row({ space: 16 }) {
        Button('取消')
          .width(140)
          .height(40)
          .fontColor($r('sys.color.warning'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
            }
          })

        Button('确定')
          .width(140)
          .height(40)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
            }
            RouterModule.pop()
          })
      }
    }
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 16, right: 16, bottom: 24 })
    .borderRadius(32)
    .width(328)
    .height(133)
  }
}