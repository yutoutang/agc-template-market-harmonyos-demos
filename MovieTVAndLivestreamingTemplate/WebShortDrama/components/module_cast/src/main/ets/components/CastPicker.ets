import { AVCastPicker } from '@kit.AVSessionKit';

@ComponentV2
export struct CastPicker {
  @Param isLocked: boolean = false
  build() {
    if (this.isLocked) {
      Row() {
        this.customPickerBuilder()
      }
      .onClick(() => {
        this.getUIContext().showAlertDialog({
          title: '提示',
          message: '当前视频解锁后，可投屏观看？',
          autoCancel: true,
          alignment: DialogAlignment.Center,
          buttons: [{
            value: '知道了',
            action: () => {
              console.info('Callback when the first button is clicked');
            }
          }]
        })
      })
    } else {
      AVCastPicker({
        normalColor: Color.Red,
        customPicker: () => this.customPickerBuilder()
      })
        .width('40')
        .height('40')
    }

  }

  @Builder
  customPickerBuilder(): void {
    Row() {
      SymbolGlyph($r('sys.symbol.wireless_projection'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_on_primary')])
    }
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius(20)
    .width(40)
    .height(40)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Preview
struct CastPickerPreview {
  build() {
    Row() {
      CastPicker()
    }
    .width('100%')
    .height(40)
    .backgroundColor(Color.Black)
  }
}