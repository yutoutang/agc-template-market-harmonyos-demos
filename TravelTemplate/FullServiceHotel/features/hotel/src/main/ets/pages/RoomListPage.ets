import { CommonBanner } from 'componentlib';
import { RoomCard } from '../components/RoomCard';
import { MappedRoom } from '../models/MappedRoom';
import { RoomListPageVM } from '../viewmodels/RoomListPageVM';
import { HotelDateSelector } from 'module_date_selector';
import { CallDialog } from 'module_call_dialog';

@Builder
export function roomListPageBuilder() {
  RoomListPage();
}

@ComponentV2
struct RoomListPage {
  vm: RoomListPageVM = RoomListPageVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          CommonBanner({
            covers: this.vm.topBannerList,
          })

          this.hotelInfoBuilder();

          HotelDateSelector({
            showTopLabel: false,
            paramChangeCallback: () => {
              this.vm.getRoomList();
            },
          })
            .borderRadius($r('app.string.border_radius_16'))
            .clip(true)

          ForEach(this.vm.roomList, (room: MappedRoom) => {
            RoomCard({ room: room, hotel: this.vm.hotel });
          }, (item: MappedRoom) => JSON.stringify(item));
        }
      }
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
        bottom: $r('app.string.padding_l'),
      })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('酒店详情')
    .backgroundColor($r('app.color.background_color_grey'))
    .onShown(() => {
      this.vm.initData();
    });
  }

  @Builder
  hotelInfoBuilder() {
    Column() {
      Row() {
        Text(this.vm.hotel?.name ?? '')
          .fontSize($r('app.string.font_size_18'))
          .fontColor($r('app.color.font_color_level1'))
          .fontWeight(500)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        CallDialog({ phoneNumber: this.vm.hotel?.phoneNumber }) {
          Row() {
            Image($r('app.media.icon_phone'))
              .height($r('app.integer.icon_size_12'))
              .fillColor($r('app.color.theme_color'))
              .margin({ right: $r('app.string.margin_xs') });
            Text('联系商家')
              .fontSize($r('app.string.font_size_14'))
              .fontColor($r('app.color.theme_color'));
          }
        }
      }
      .width($r('app.string.width_percent_full'))
      .justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Image($r('app.media.icon_local'))
          .height(12)
          .fillColor($r('app.color.icon_color_level2'))
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .margin({ right: $r('app.string.margin_xs') });
        Text(this.vm.hotel?.address ?? '--')
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width($r('app.string.width_percent_full'))
      .margin({ top: $r('app.string.margin_m') })
      .justifyContent(FlexAlign.Start);
    }
    .width($r('app.string.width_percent_full'))
  }
}

@Extend(Column)
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}