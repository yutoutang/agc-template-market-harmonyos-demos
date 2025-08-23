import { CommonButton, CommonBanner, CommonTagList } from 'componentlib';
import { LengthUnit } from '@ohos.arkui.node';
import { RoomInfoPageVM } from '../viewmodels/RoomInfoPageVM';
import { HotelDateSelector } from 'module_date_selector';

@Builder
export function roomInfoPageBuilder() {
  RoomInfoPage();
}

@ComponentV2
struct RoomInfoPage {
  vm: RoomInfoPageVM = RoomInfoPageVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          CommonBanner({
            covers: this.vm.roomDetail?.banners ?? [],
          })
            .borderRadius($r('app.string.border_radius_16'))
            .clip(true)

          this.hotelCardBuilder()

          HotelDateSelector({
            showTopLabel: false,
            paramChangeCallback: () => {
              this.vm.getRoomInfo();
            },
          })
            .borderRadius($r('app.string.border_radius_16'))
            .clip(true)

          this.iconTagsBuilder();

          this.descriptionBuilder();
        }
      }
      .padding({
        left: $r('app.string.padding_l'),
        right: $r('app.string.padding_l'),
        bottom: $r('app.string.padding_m'),
      })
      .margin({ bottom: $r('app.string.margin_l') })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)

      CommonButton({
        title: '预订房间',
        handleClick: () => {
          this.vm.jumpToHotelOrder();
        },
      });
    }
    .title('房间详情')
    .backgroundColor($r('app.color.background_color_grey'))
    .onShown(() => {
      this.vm.initData();
    })
    .onHidden(() => {
      this.vm.clearData();
    });
  }

  @Builder
  hotelCardBuilder() {
    Column() {
      if (this.vm.room && this.vm.roomRate) {
        Row() {
          Text(this.vm.room.name)
            .fontSize($r('app.string.font_size_18'))
            .fontColor($r('app.color.font_color_level1'))
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ right: $r('app.string.margin_s') });
          CommonTagList({
            list: this.vm.room.tags,
          })
        };

        Row() {
          Text('价格可能浮动，建议尽快预定~')
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.highlight_color'))
            .margin({ top: $r('app.string.margin_s') })
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text() {
            Span('￥');
            Span(this.vm.roomRate.rate.toString()).fontSize($r('app.string.font_size_20'));
          }
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.highlight_color'));
        }
        .width($r('app.string.width_percent_full'))
        .justifyContent(FlexAlign.SpaceBetween)
      }
    }
  }

  @Builder
  iconTagsBuilder() {
    Row() {
      if (this.vm.roomDetail?.iconTags) {
        Grid() {
          ForEach(this.vm.roomDetail.iconTags, (item: [ResourceStr, string]) => {
            GridItem() {
              Column() {
                Image(item[0])
                  .height($r('app.integer.icon_size_32'))
                  .margin({ bottom: $r('app.string.margin_s') });
                Text(item[1])
                  .fontSize($r('app.string.font_size_12'))
                  .fontColor($r('app.color.font_color_level1'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
              };
            };
          }, (item: ResourceStr) => JSON.stringify(item));
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr');
      }
    }
    .commonContainerStyle()
  }

  @Builder
  labelBuilder(title: string, label: string) {
    Row() {
      Row() {
        Text(title)
          .fontColor($r('app.color.font_color_level2'))
          .fontSize($r('app.string.font_size_14'));
      }
      .width($r('app.string.height_percent_25'))
      .constraintSize({ maxWidth: 150 })

      Row() {
        Text(label ? label : '暂无')
          .fontColor($r('app.color.font_color_level1'))
          .fontSize($r('app.string.font_size_14'))
          .lineSpacing({ value: 4, unit: LengthUnit.VP });
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1);
    }
    .width($r('app.string.width_percent_full'))
  }

  @Builder
  descriptionBuilder() {
    Column({ space: 12 }) {
      if (this.vm.roomDetail && this.vm.roomRate) {
        this.labelBuilder('优惠来源', this.vm.roomRate.name);
        this.labelBuilder('便利设施', this.vm.roomDetail.amenities);
        this.labelBuilder('床位', this.vm.roomDetail.beds);
        this.labelBuilder('媒体技术', this.vm.roomDetail.mediaTech);
        this.labelBuilder('食品饮品', this.vm.roomDetail.foodDrink);
        this.labelBuilder('洗漱用品', this.vm.roomDetail.toiletries);
        this.labelBuilder('浴室', this.vm.roomDetail.bath);
        this.labelBuilder('其他', this.vm.roomDetail.other);
      }
    }
    .commonContainerStyle()
  }
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}