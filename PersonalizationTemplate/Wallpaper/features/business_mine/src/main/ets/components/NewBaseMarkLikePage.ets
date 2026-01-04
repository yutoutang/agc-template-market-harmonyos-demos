import { ImageInfo } from 'module_wallpaper_details';
import { NewMarkVM } from '../viewmodels/NewMarkVM';
import { MarkItemComponent } from './MarkItemComponent';

@ComponentV2
export struct NewBaseMarkLikePage {
  @Param @Require vm: NewMarkVM;

  aboutToAppear() {
    this.vm.aboutToAppear();
    this.vm.loadMarks();
  }

  aboutToDisappear() {
    this.vm.aboutToDisappear();
  }

  build() {
    Column() {
      if (this.vm.isLoading) {
        LoadingProgress()
          .size({ width: 72, height: 72 })
          .layoutWeight(1);
      } else if (this.vm.list.length === 0) {
        Column() {
          Text('暂无收藏记录')
            .fontSize(16)
            .fontColor($r('sys.color.font_tertiary'));
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        List({ space: 12 }) {
          ForEach(this.vm.list, (record: ImageInfo, index: number) => {
            ListItem() {
              MarkItemComponent({
                record: record,
                index: index,
                selectEdit: this.vm.selectEdit,
                vm: this.vm
              })
            }
          }, (record: ImageInfo, index: number) => JSON.stringify(record) + '_' + index)
        }
        .id('markList')
        .layoutWeight(1)
        .padding(16)
        .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%');
  }
}