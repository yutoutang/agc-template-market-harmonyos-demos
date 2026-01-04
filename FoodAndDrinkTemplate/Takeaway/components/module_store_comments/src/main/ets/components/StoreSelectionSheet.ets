import { StoreItem } from '../commons/Types';

@ComponentV2
export struct StoreSelectionSheet {
  @Param
  hotelList: StoreItem[] = [];
  @Local
  curIndex: number = 0;
  @Event
  handleConfirm: (store: StoreItem) => void = () => {
    // do nothing
  };

  @Computed
  get hotelLabelList() {
    return this.hotelList.map((item) => item.name);
  }

  build() {
    Column() {
      TextPicker({ range: this.hotelLabelList, selected: this.curIndex })
        .onChange((value: string | string[], index: number | number[]) => {
          this.curIndex = index as number;
        })
        .onClick(() => {
          this.handleConfirm?.(this.hotelList[this.curIndex])
        })
        .textStyle({
          color: $r('app.color.font_color_level1'),
          font: { size: $r('app.string.font_size_16') },
        })
        .selectedTextStyle({
          color: $r('app.color.theme_color'),
          font: { size: $r('app.string.font_size_20'), weight: FontWeight.Medium },
        })
        .canLoop(false)
        .width($r('app.string.size_percent_100'))
    }
    .height($r('app.string.size_percent_100'))
    .width($r('app.string.size_percent_100'));
  }
}