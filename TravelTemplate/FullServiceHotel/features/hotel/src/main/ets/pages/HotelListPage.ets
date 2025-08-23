import { CommonTagList } from 'componentlib';
import { MappedHotel } from '../models/MappedHotel';
import { HotelListPageVM } from '../viewmodels/HotelListPageVM';
import { RelativeAnchorMap } from '../constants/Constants';
import { HotelDateSelector } from 'module_date_selector';
import { ImmersiveScroll } from '../components/ImmersiveScroll';

@Builder
export function hotelListPageBuilder() {
  HotelListPage();
}

@ComponentV2
struct HotelListPage {
  vm: HotelListPageVM = HotelListPageVM.instance;

  aboutToAppear(): void {
    this.vm.resetRoomCount()
  }

  build() {
    NavDestination() {
      ImmersiveScroll({ title: '选择酒店' }) {
        Column() {
          this.topBannerBuilder();
          List({ space: 12 }) {
            ForEach(this.vm.hotelList, (item: MappedHotel, index: number) => {
              ListItem() {
                this.hotelCardBuilder(item, index);
              }
            }, (item: MappedHotel) => JSON.stringify(item));
          }
          .padding($r('app.string.padding_l'))
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
        }
        .layoutWeight(1)
      }
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .onShown(() => {
      this.vm.initData();
    });
  }

  @Builder
  topBannerBuilder() {
    RelativeContainer() {
      Image(this.vm.topBanner)
        .width('100%')
        .aspectRatio(16 / 9)
        .id(RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      HotelDateSelector({
        paramChangeCallback: (data) => {
          this.vm.getHotelList(data);
        },
      })
        .margin({
          left: $r('app.string.margin_l'),
          right: $r('app.string.margin_l'),
        })
        .alignRules({
          'top': { 'anchor': RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER, 'align': VerticalAlign.Center },
          'left': { 'anchor': RelativeAnchorMap.HOTEL_LIST_BANNER_CONTAINER, 'align': HorizontalAlign.Start },
        });
    }
    .width($r('app.string.width_percent_full'))
    .height('auto')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  dividerBuilder() {
    Divider()
      .vertical(false)
      .color($r('app.color.system_color_grey_level1'))
      .strokeWidth(1)
      .margin({ bottom: $r('app.string.margin_s') });
  }

  @Builder
  hotelCardBuilder(hotel: MappedHotel, index: number) {
    RelativeContainer() {
      Image(hotel.cover)
        .height(126)
        .aspectRatio(1)
        .borderRadius($r('app.string.border_radius_16'))
        .objectFit(ImageFit.Cover)
        .padding({ right: $r('app.string.padding_s') })
        .alignRules({
          left: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.Start },
          top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_COVER);


      Text(hotel.name)
        .fontSize($r('app.string.font_size_16'))
        .fontColor($r('app.color.font_color_level1'))
        .fontWeight(500)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .layoutWeight(1)
        .alignRules({
          left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
          top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_TITLE);

      Text(hotel.distanceInMeters)
        .fontSize($r('app.string.font_size_12'))
        .fontColor($r('app.color.font_color_level2'))
        .alignRules({
          right: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.End },
          top: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: VerticalAlign.Top },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_DISTANCE);

      Text(hotel.address)
        .fontSize($r('app.string.font_size_12'))
        .fontColor($r('app.color.font_color_level3'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .margin({ top: $r('app.string.margin_s') })
        .alignRules({
          left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
          top: { anchor: RelativeAnchorMap.HOTEL_ITEM_TITLE, align: VerticalAlign.Bottom },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_ADDRESS);

      CommonTagList({
        list: hotel.tags,
      })
        .margin({ top: $r('app.string.margin_s') })
        .width('60%')
        .alignRules({
          left: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: HorizontalAlign.End },
          top: { anchor: RelativeAnchorMap.HOTEL_ITEM_ADDRESS, align: VerticalAlign.Bottom },
        })
        .id(RelativeAnchorMap.HOTEL_ITEM_TAG);

      Text() {
        Span(hotel.basePrice === '--' ? '' : '¥');
        Span(hotel.basePrice.toString())
          .fontSize($r('app.string.font_size_16'));
        Span(hotel.basePrice === '--' ? '' : '起');
      }
      .fontSize($r('app.string.font_size_12'))
      .fontColor($r('app.color.highlight_color'))
      .alignRules({
        right: { anchor: RelativeAnchorMap.HOTEL_CARD_CONTAINER, align: HorizontalAlign.End },
        bottom: { anchor: RelativeAnchorMap.HOTEL_ITEM_COVER, align: VerticalAlign.Bottom },
      })
      .id(RelativeAnchorMap.HOTEL_ITEM_PRICE);
    }
    .id(RelativeAnchorMap.HOTEL_CARD_CONTAINER)
    .height(150)
    .width($r('app.string.width_percent_full'))
    .padding($r('app.string.padding_m'))
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius($r('app.string.border_radius_16'))
    .onClick(() => {
      this.vm.jumpToRoomList(hotel);
    })
  }
}

