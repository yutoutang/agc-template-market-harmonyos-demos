import { ISelectOption, lightDarkOptions } from '../viewModel/setUpModel';

@ComponentV2
export struct SettingSelectPop {
  @Require @Param selectItem: string;
  // 回调模式选项
  @Event selectItemBack: (selectItem:string) => void = () => {
  }
  build() {
    Column() {
      List() {
        ForEach((lightDarkOptions ?? []), (option: ISelectOption, index: number) => {
          ListItem() {
            Row() {
              Text(option.label)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .maxFontScale(1.45)
                .layoutWeight(1)
                .textAlign(TextAlign.Start);
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontColor([$r('sys.color.font_primary')])
                .visibility(this.selectItem === option.label ? Visibility.Visible : Visibility.Hidden);
            }
            .width('100%')
            .borderRadius(16)
            .padding(12)
            .onClick(() => {
              this.selectItemBack(option.label)
            });
          }
        }, (option: ISelectOption) => option.id + option.label);
      }
      .width('100%')
      .height('auto')
      .padding(4)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider'),
      });
    }
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }
}
