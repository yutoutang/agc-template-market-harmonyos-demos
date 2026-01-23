import { Constants } from '../constant/Constants';
import { CarouseCutToolBar } from './CarouseCutToolBar';
import { FilterToolBar } from './FilterToolBar';
import { AddTextToolBar } from './AddTextToolBar';
import { ImageShowModel } from '../model/PageParams';
import { StickerToolBar } from './StickerToolBar';
import { IconAndTextView } from './IconAndTextView';
import { MosaicToolBar } from './MosaicToolBar';
import { WaterMarkToolBar } from './WaterMarkToolBar';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';

@ComponentV2
export struct BeautyActionBar {
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;

  build() {
    Row() {
      this.allToolsBuilder();
      FilterToolBar().visibility(this.vm.barIndex === 0 ? Visibility.Visible : Visibility.None);
      CarouseCutToolBar().visibility(this.vm.barIndex === 1 ? Visibility.Visible : Visibility.None);
      StickerToolBar().visibility(this.vm.barIndex === 2 ? Visibility.Visible : Visibility.None);
      AddTextToolBar().visibility(this.vm.barIndex === 3 ? Visibility.Visible : Visibility.None);
      MosaicToolBar().visibility(this.vm.barIndex === 4 ? Visibility.Visible : Visibility.None);
      WaterMarkToolBar().visibility(this.vm.barIndex === 5 ? Visibility.Visible : Visibility.None);
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .constraintSize({ maxHeight: 200 })
    .alignItems(VerticalAlign.Bottom)
    .backgroundColor($r('sys.color.background_secondary'));
  }

  @Builder
  allToolsBuilder() {
    List({ space: 16 }) {
      ForEach(Constants.BAR_LIST, (item: ImageShowModel, index: number) => {
        ListItem() {
          IconAndTextView({ barItem: item })
            .onClick(() => {
              this.vm.barIndex = index;
            });
        }.margin({ right: index === Constants.BAR_LIST.length - 1 ? 12 : 0 });
      }, (item: ImageShowModel) => JSON.stringify(item));
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .height(72)
    .margin({ left: 12 })
    .alignListItem(ListItemAlign.End)
    .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None);

  }
}