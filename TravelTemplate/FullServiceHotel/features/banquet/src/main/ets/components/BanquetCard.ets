import { CommonTagList } from 'componentlib';
import { BanquetRoomItem } from '../types';


@ComponentV2
export struct BanquetCard {
  @Param @Require
  banquetItem: BanquetRoomItem;

  build() {
    Flex({
      alignItems: ItemAlign.Center,
    }) {
      Image(this.banquetItem.banner ? this.banquetItem.banner : $r('app.media.ic_no_data'))
        .height($r('app.string.height_percent_full'))
        .aspectRatio(1)
        .objectFit(this.banquetItem.banner ? ImageFit.Cover : ImageFit.Contain)
        .margin({ right: $r('app.string.margin_s') })
        .borderRadius($r('app.string.border_radius_16'))

      Column() {
        Text(this.banquetItem.banquetName)
          .fontSize($r('app.string.font_size_16'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: $r('app.string.margin_s') });

        if (this.banquetItem.profile) {
          Text(this.banquetItem.profile)
            .fontSize($r('app.string.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: $r('app.string.margin_s') });
        }

        CommonTagList({
          list:this.banquetItem.labelList
        })

        Blank();

        Row() {
          Blank()
          Button('立即前往')
            .fontSize($r('app.string.font_size_14'))
            .backgroundColor($r('app.color.theme_color'))
            .height(32)
        }
        .width($r('app.string.width_percent_full'))
      }
      .alignItems(HorizontalAlign.Start)
      .height($r('app.string.height_percent_full'))
      .layoutWeight(1);
    }
    .width('100%')
    .height(152)
    .padding($r('app.string.padding_m'))
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('app.string.border_radius_16'))
  }

}