import { MapOptionType } from '../commons/Enums';
import { MapOptionDialogItem } from '../commons/Types';

export interface MapOptionsDialogParam {
  handleMapOptionClick?: (type: MapOptionType) => void;
}

@Builder
export function mapOptionsDialogBuilder(params: MapOptionsDialogParam) {
  MapOptionsDialog({
    handleMapOptionClick: params.handleMapOptionClick,
  });
}

@ComponentV2
export struct MapOptionsDialog {
  @Local mapOptionList: MapOptionDialogItem[] = [
    {
      type: MapOptionType.HUAWEI,
      label: '华为地图',
    },
    {
      type: MapOptionType.CANCEL,
      label: '取消',
    },
  ];
  @Event
  handleMapOptionClick: (type: MapOptionType) => void;

  build() {
    Column({ space: 8 }) {
      ForEach(this.mapOptionList, (item: MapOptionDialogItem, index: number) => {
        Row() {
          Text(item.label)
            .fontColor($r('app.color.font_color_link'));
        }
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.font_color_level1_invert'))
        .borderRadius(99)
        .padding($r('app.string.space_l'))
        .width('90%')
        .onClick(() => {
          this.handleMapOptionClick?.(item.type);
        });
      }, (item: MapOptionDialogItem, index: number) => JSON.stringify(item));
    }
    .width($r('app.string.size_percent_full'))
    .margin({ bottom: $r('app.string.space_xl') });
  }
}