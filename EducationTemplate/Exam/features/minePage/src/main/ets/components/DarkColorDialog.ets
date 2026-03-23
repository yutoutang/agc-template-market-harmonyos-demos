import { ISelectOption, lightDarkOptions } from '../viewModel/setUpModel';

@CustomDialog
export struct DarkColorDialog {
  selectItem: string = '';
  dialogController?: CustomDialogController;
  selectItemBack: (selectItem: string) => void = () => {
  };
  cancel: () => void = () => {
  };
  @Builder
  selectItemBuilder(item: ISelectOption) {
    Row() {
      Text(item.label)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));
      Image(item.label === this.selectItem ? $r('app.media.icon_Checked') : $r('app.media.icon_ans_common'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'));
    }
    .width('100%')
    .height($r('app.float.vp_48'))
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.selectItemBack(item.label);
    });
  }

  build() {
    Column() {
      Text('夜间模式')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .height($r('app.float.vp_48'));

      Grid() {
        ForEach(lightDarkOptions, (item: ISelectOption) => {
          GridItem() {
            this.selectItemBuilder(item);
          };
        }, (item: ISelectOption, index: number) => item.label + index);
      }
      .width('100%')
      .height(150)
      .columnsTemplate('1fr')

      Text('取消')
        .textAlign(TextAlign.Center)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor('#4c5dc4')
        .width('100%')
        .height($r('app.float.vp_48'))
        .onClick(()=>{
          this.cancel()
        })
    }
    .width('90%')
    .height(270)
    .padding($r('app.float.vp_16'));
  }
}