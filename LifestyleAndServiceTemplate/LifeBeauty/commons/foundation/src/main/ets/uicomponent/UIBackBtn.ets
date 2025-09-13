import { RouterModule } from '../router/RouterModule';

/**
 * 自定义返回按钮，模拟系统NavDestination
 */
@ComponentV2
export struct UIBackBtn {
  @Event clickEvent: () => void = () => {
    RouterModule.pop();
  };

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.chevron_backward'))
        .fontWeight(FontWeight.Normal)
        .fontSize(24)
    }
    .width(40)
    .height(40)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ left: 16 })
    .onClick(() => {
      this.clickEvent();
    })
  }
}