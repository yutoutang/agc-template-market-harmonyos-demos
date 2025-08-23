import { MappedRoom, MappedRoomRate } from '../models/MappedRoom';
import { MappedHotel } from '../models/MappedHotel';
import { HotelBookingVM } from '../viewmodels/HotelBookingVM';
import { RouterMap, RouterModule } from 'commonlib';
import { CommonDivider, CommonTagList } from 'componentlib';

@ComponentV2
export struct RoomCard {
  @Param
  room: MappedRoom | undefined = undefined;
  @Param
  hotel: MappedHotel | undefined = undefined;
  @Local
  private _name: string = this.room!.name;
  @Local
  private _basePrice: string | number = this.room!.basePrice;
  @Local
  private _cover: PixelMap | ResourceStr | DrawableDescriptor = this.room!.cover;
  @Local
  private _tags: string[] = this.room!.tags;
  @Local
  private _showRoomRateList: boolean = false;
  @Local
  private cardHeight: number = 100

  build() {
    Column() {
      Row() {
        Row() {
          Image(this._cover)
            .height($r('app.string.height_percent_full'))
            .aspectRatio(1)
            .objectFit(ImageFit.Fill)
            .borderRadius($r('app.string.border_radius_16'))
            .margin({ right: $r('app.string.margin_s') })
            .alt($r('app.media.ic_no_data'))
          Column() {
            Text(this._name)
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.font_color_level1'))
              .margin({ bottom: $r('app.string.margin_m') })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width($r('app.string.width_percent_full'));

            CommonTagList({
              list: this._tags,
            })
          }
          .padding({ left: $r('app.string.padding_s') })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .height($r('app.string.height_percent_full'))
        }
        .width($r('app.string.width_percent_75'))
        .margin({ right: $r('app.string.padding_m') })
        .height(this.cardHeight)

        Column() {
          Image($r('app.media.ic_up'))
            .height(24)
            .fillColor($r('app.color.icon_color_level1'))
            .rotate({ angle: this._showRoomRateList ? 0 : 180 })
            .margin({ right: $r('app.string.margin_s'), bottom: $r('app.string.margin_s') });
          Blank();

          if (!this._showRoomRateList) {
            Text() {
              Span('¥')
              Span(this._basePrice.toString()).fontSize($r('app.string.font_size_16'))
              Span('起');
            }
            .fontColor($r('app.color.highlight_color'))
            .fontSize($r('app.string.font_size_12'));
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.End)
        .height(this.cardHeight)
      }
      .width($r('app.string.width_percent_full'))
      .alignItems(VerticalAlign.Top)
      .height('auto')
      .onClick(() => this._showRoomRateList = !this._showRoomRateList);

      if (this._showRoomRateList) {
        CommonDivider()

        ForEach(this.room!.mappedRoomRateList, (item: MappedRoomRate, index: number) => {
          Row() {
            Text(item.name)
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.font_color_level2'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1);
            Row() {
              Text() {
                Span('¥');
                Span(item.rate.toString())
                  .fontSize($r('app.string.font_size_16'));
              }
              .fontSize($r('app.string.font_size_12'))
              .fontColor($r('app.color.highlight_color'));
            }
            .alignItems(VerticalAlign.Bottom)
            .margin({ right: $r('app.string.margin_s') })

            Button('预订')
              .fontSize($r('app.string.font_size_12'))
              .backgroundColor($r('app.color.theme_color'))
              .height(28)
          }
          .width($r('app.string.width_percent_full'))
          .padding($r('app.string.padding_s'))
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            HotelBookingVM.instance.setRoomInfo(this.room, item);
            RouterModule.push({ url: RouterMap.HOTEL_ROOM_DETAIL, param: [this.hotel, this.room, item] });
          });
        }, (item: MappedRoomRate) => JSON.stringify(item));
      }
    }
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_m'))
    .borderRadius($r('app.string.border_radius_16'))
    .backgroundColor($r('app.color.background_color_white'))
  }
}