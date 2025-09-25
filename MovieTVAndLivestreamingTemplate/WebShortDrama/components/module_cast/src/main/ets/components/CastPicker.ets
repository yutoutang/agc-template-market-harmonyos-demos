import { AVCastPicker } from '@kit.AVSessionKit';

@ComponentV2
export struct CastPicker {
  build() {
    AVCastPicker({
      normalColor: Color.Red,
      customPicker: () => this.customPickerBuilder(),
    })
      .width('40')
      .height('40')
  }

  @Builder
  customPickerBuilder(): void {
    Row() {
      SymbolGlyph($r('sys.symbol.wireless_projection'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_on_primary')])
    }.backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius(20)
    .width(40)
    .height(40)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}

@Preview
struct CastPickerPreview{
  build(){
    Row(){
      CastPicker()
    }
    .width('100%')
    .height(40)
    .backgroundColor(Color.Black)
  }
}