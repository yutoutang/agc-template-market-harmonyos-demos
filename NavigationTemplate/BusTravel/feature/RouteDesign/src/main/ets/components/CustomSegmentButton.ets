import { ButtonItem, ButtonOptions } from '../viewmodels/ButtonItems'

@ComponentV2
export struct CustomSegmentButton {
  @Param buttonOptions: ButtonOptions = new ButtonOptions()
  @Param selectIndex: number = 0
  @Event onSelectIndexChange: (index: number) => void = (index: number) => {

  }

  build() {
    Row() {
      ForEach(this.buttonOptions.buttons, (item: ButtonItem, index: number) => {
        Column() {
          Image(this.selectIndex === index ? item.selectedIcon : item.icon).width(24).height(24)
          Text(item.text)
            .fontColor(this.selectIndex === index ? this.buttonOptions.selectedFontColor :
            this.buttonOptions.fontColor)
            .fontSize(this.buttonOptions.fontSize ?? 12)
            .padding(this.buttonOptions.textPadding)
        }
        .width('50%')
        .height(63)
        .borderRadius(12)
        .backgroundColor(this.selectIndex === index ? this.buttonOptions.selectedBackgroundColor :
        $r('sys.color.gray_02'))
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.onSelectIndexChange(index)
        })
      }, (item: ButtonItem) => new Date().toString() + item.text)
    }
    .width('100%')
    .backgroundColor($r('sys.color.gray_02'))
    .borderRadius(12)
  }
}