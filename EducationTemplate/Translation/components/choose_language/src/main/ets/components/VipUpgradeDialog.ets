// VIP升级提示弹窗组件

import { VipDialogConstants } from '../constants/LanguageConstants';

@ComponentV2
export struct VipUpgradeDialog {
  @Require @Param visible: boolean = false;
  @Param onClose?: () => void = undefined;
  @Param onUpgrade?: () => void = undefined;

  aboutToAppear(): void {
  }

  build() {
    if (this.visible) {
      // 全屏遮罩层
      Column() {
        // 弹窗内容区域
        Column() {
          //VIP图标
          Image($r('app.media.vip_logo'))
            .width(VipDialogConstants.VIP_ICON_WIDTH)
            .height(VipDialogConstants.VIP_ICON_HEIGHT)
            .objectFit(ImageFit.Contain)
            .margin({ top: VipDialogConstants.VIP_ICON_TOP_MARGIN })

          // 提示文字
          Text(VipDialogConstants.UPGRADE_TEXT)
            .fontSize(VipDialogConstants.TEXT_FONT_SIZE)
            .fontColor(VipDialogConstants.TEXT_COLOR)
            .fontWeight(FontWeight.Medium)
            .margin({
              top: VipDialogConstants.TEXT_TOP_MARGIN,
              bottom: VipDialogConstants.TEXT_BOTTOM_MARGIN
            })

          // 去解锁按钮
          Button(VipDialogConstants.UNLOCK_BUTTON_TEXT)
            .width('100%')
            .height(VipDialogConstants.BUTTON_HEIGHT)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor(VipDialogConstants.BUTTON_BG_COLOR)
            .borderRadius(VipDialogConstants.BUTTON_BORDER_RADIUS)
            .onClick(() => {
              this.handleUpgrade();
            })
        }
        .width(VipDialogConstants.DIALOG_WIDTH)
        .padding({
          left: VipDialogConstants.DIALOG_HORIZONTAL_PADDING,
          right: VipDialogConstants.DIALOG_HORIZONTAL_PADDING,
          top: 0,
          bottom: VipDialogConstants.DIALOG_BOTTOM_PADDING
        })
        .backgroundColor(VipDialogConstants.BG_COLOR)
        .borderRadius(VipDialogConstants.DIALOG_BORDER_RADIUS)

        // 关闭按钮
        Image($r('app.media.ic_close'))
          .width(32)
          .height(32)
          .objectFit(ImageFit.Contain)
          .margin({ top: 24 })
          .onClick(() => {
            if (this.onClose) {
              this.onClose();
            }
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(VipDialogConstants.MASK_BG_COLOR)
      .justifyContent(FlexAlign.Center)
      .onAppear(() => {
      })
    }
  }

  private handleUpgrade(): void {
    if (this.onUpgrade) {
      this.onUpgrade();
    }
  }
}
