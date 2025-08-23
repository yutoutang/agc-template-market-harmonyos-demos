import { GetBanquetRoomDetailResp, https, LayoutMethodItem, SiteInformationItem } from 'network';
import { CommonBanner, CommonButton } from 'componentlib';
import { FormatUtil, RouterMap, RouterModule } from 'commonlib';
import { CallDialog } from 'module_call_dialog';

@Builder
export function banquetInfoPageBuilder() {
  BanquetInfoPage();
}

@ComponentV2
struct BanquetInfoPage {
  @Local
  private banquetDetail?: GetBanquetRoomDetailResp;

  getBanquetDetail(banquetId: number) {
    https.getBanquetRoomDetail(banquetId).then((res) => {
      if (res.code === 0) {
        this.banquetDetail = res.data;
        const layoutMethod = res.data.layoutMethod;
        this.banquetDetail.bannerList =
          this.banquetDetail.bannerList.map((item) => FormatUtil.getImgResource(item as string));
        this.banquetDetail.layoutMethod = layoutMethod.map((item) => {
          return {
            icon: FormatUtil.getImgResource(item.icon),
            id: item.id,
            layoutName: item.layoutName,
            personNum: item.personNum,
          } as LayoutMethodItem;
        });
      }
    });
  }

  build() {
    NavDestination() {
      if (this.banquetDetail) {
        Scroll() {
          Column({ space: 12 }) {
            CommonBanner({
              covers: this.banquetDetail.bannerList,
            })

            this.spaceInfoBuilder();

            this.layoutInfoBuilder();
          }
          .justifyContent(FlexAlign.Start);
        }
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({
          left: $r('app.string.padding_l'),
          right: $r('app.string.padding_l'),
          bottom: $r('app.string.padding_l'),
        })
        .layoutWeight(1)
      }

      CallDialog({
        phoneNumber: this.banquetDetail?.banquetTel,
      }) {
        CommonButton({
          title: '立即预约',
          icon: $r('app.media.ic_phone'),
        })
      }
    }
    .width($r('app.string.width_percent_full'))
    .title(this.banquetDetail?.banquetName ?? '')
    .backgroundColor($r('app.color.background_color_grey'))
    .onReady(() => {
      const banquetId = RouterModule.getNavParam<number>({
        url: RouterMap.BANQUET_INFO,
      });
      if (banquetId) {
        this.getBanquetDetail(banquetId);
      }
    });

  }

  @Builder
  spaceInfoBuilder() {
    Column() {
      Text('场地信息')
        .commonTitleTextStyle();
      if (this.banquetDetail?.profile) {
        Text(this.banquetDetail.profile)
          .labelTextStyle()
          .margin({ bottom: $r('app.string.margin_m') });
      }
      if (this.banquetDetail?.siteInformation) {
        Flex() {
          ForEach(this.banquetDetail.siteInformation, (item: SiteInformationItem) => {
            Row() {
              Text(item.siteName)
                .labelTextStyle()
                .margin({ right: $r('app.string.margin_xs') });
              Text(item.content)
                .labelTextStyle()
                .fontColor($r('app.color.font_color_level1'));
            }
            .justifyContent(FlexAlign.Center)
            .margin({ right: $r('app.string.margin_m') });
          }, (item: SiteInformationItem) => JSON.stringify(item));
        };
      }
    }
    .commonContainerStyle();
  }

  @Builder
  layoutInfoBuilder() {
    Column() {
      Text('布局方式')
        .commonTitleTextStyle();
      if (this.banquetDetail?.layoutMethod) {
        Grid() {
          ForEach(this.banquetDetail.layoutMethod, (item: LayoutMethodItem) => {
            GridItem() {
              Row() {
                Image(item.icon)
                  .height(40)
                  .width(40)
                  .borderWidth(1)
                  .borderColor('#FFE5E5E5')
                  .borderRadius($r('app.string.border_radius_8'))
                  .padding($r('app.string.padding_xs'))
                  .margin({ right: $r('app.string.margin_s') });
                Column() {
                  Text(item.layoutName)
                    .labelTextStyle();
                  Text(item.personNum + '人')
                    .labelTextStyle()
                    .fontColor($r('app.color.font_color_level1'))
                }
                .height(40)
                .justifyContent(FlexAlign.SpaceBetween)
                .alignItems(HorizontalAlign.Start);
              }
              .justifyContent(FlexAlign.Start);
            };
          }, (item: LayoutMethodItem) => JSON.stringify(item));
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap($r('app.string.margin_l'))
        .rowsGap($r('app.string.margin_l'));
      }
    }
    .commonContainerStyle();
  }
}

@Extend(Column)
function commonContainerStyle() {
  .width('100%')
  .alignItems(HorizontalAlign.Start)
  .padding($r('app.string.padding_m'))
  .borderRadius($r('app.string.border_radius_16'))
  .backgroundColor($r('app.color.background_color_white'))
}

@Extend(Text)
function commonTitleTextStyle() {
  .fontSize($r('app.string.font_size_16'))
  .fontColor($r('app.color.font_color_level1'))
  .margin({ bottom: $r('app.string.margin_m') });
}

@Extend(Text)
function labelTextStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level2'));
}