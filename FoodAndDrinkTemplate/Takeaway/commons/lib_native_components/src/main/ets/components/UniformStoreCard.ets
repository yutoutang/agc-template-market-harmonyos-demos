import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { StoreModel } from 'lib_takeaway_api';

export interface UniformStoreStyle {
  bodyFg?: Length
  bodyFgColor?: ResourceColor
  imgRatio?: number
}

@ComponentV2
export struct UniformStoreCard {
  @Require @Param storeInfo: StoreModel;
  @Param showAuthorInfoTop: boolean = false;
  @Param showAuthorInfoBottom: boolean = true;
  @Param customStyle: UniformStoreStyle = {
    bodyFg: $r('sys.float.Title_L'),
    bodyFgColor: $r('sys.color.font_primary'),
    imgRatio: 1,
  };

  build() {
    Row({ space: CommonConstants.SPACE_S }) {
      RelativeContainer() {
        Image($r(`app.media.${this.storeInfo.coverUrl}`))
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .borderRadius($r('app.float.small_radius'))

      }
      .width(80 / (this.customStyle.imgRatio ?? 1))
      .height(80 / (this.customStyle.imgRatio ?? 1))
      .accessibilityGroup(true)
      .accessibilityLevel('no')

      Column({ space: CommonConstants.SPACE_S }) {
        //店铺名称
        Text(this.storeInfo?.name)
          .fontSize(18)
          .fontColor(this.customStyle.bodyFgColor ?? $r('sys.color.font_primary'))
          .textAlign(TextAlign.Start)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ top: CommonConstants.PADDING_XXS })
        //评分 月售
        Row({ space: CommonConstants.SPACE_S }) {
          Row() {
            RelativeContainer() {
              //替换成 收藏svg图片
              Image($r('app.media.ic_star_filled'))
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
                .borderRadius($r('app.float.small_radius'))
            }
            .width(14 / (this.customStyle.imgRatio ?? 1))
            .height(14 / (this.customStyle.imgRatio ?? 1))
            .accessibilityGroup(true)
            .accessibilityLevel('no')

            //评分
            Text(this.storeInfo?.score.toString())
              .fontSize(14)
              .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }

          //月销量
          Text('月售' + this.storeInfo?.monthlySales.toString())
            .fontSize(14)
            .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
            .textAlign(TextAlign.Start)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)

        Blank().height('10%')

        // 起送价+配送费+配送时间+配送距离
        Row({ space: CommonConstants.SPACE_S }) {
          //起送价
          Text('起送¥' + this.storeInfo?.startingPrice.toString())
            .fontSize(14)
            .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          //配送费
          Text('配送¥' + this.storeInfo?.deliveryFee.toString())
            .fontSize(14)
            .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Blank().width('10%')
          // 配送时间
          Text(this.storeInfo?.deliveryTime.toString() + '分钟')
            .fontSize(14)
            .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          // 距离
          Text(this.storeInfo?.distance.toString() + 'km')
            .fontSize(14)
            .fontColor(this.customStyle.bodyFgColor ?? $r('app.color.app_grey'))
            .textAlign(TextAlign.Start)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)
        .padding({ bottom: CommonConstants.PADDING_XS })
      }
      .width(CommonConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.Start)

    }
    .height(100)
    .borderRadius(5)
    .padding(CommonConstants.PADDING_S)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      RouterUtils.pushPathByName(RouterMap.STORE_PAGE, this.storeInfo.id);
    })
  }
}