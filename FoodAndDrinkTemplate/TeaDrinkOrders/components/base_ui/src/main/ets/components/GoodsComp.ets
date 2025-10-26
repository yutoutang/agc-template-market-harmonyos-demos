import { Decimal } from '@kit.ArkTS';
import { Constants } from '../constants/Index';
import { CarGoodsInfo, GoodsOfOrder } from '../models/Index';
import { PkgGoodComp } from './PkgGoodComp';

@Styles
function cardStyle() {
  .width(Constants.FULL_SIZE)
  .constraintSize({ maxWidth: Constants.FULL_SIZE })
  .backgroundColor($r('sys.color.comp_background_list_card'))
  .borderRadius(12)
  .padding(12)
  .margin({
    left: 16,
    right: 16,
  });
}

@ComponentV2
export struct GoodsComp {
  @Param @Require goodsList: Array<CarGoodsInfo | GoodsOfOrder>;
  @Param bagMoney: number = 0
  @Param readonly: boolean = true
  @Event changeSelectBag: (value: boolean) => void = () => {
  };

  build() {
    Column() {
      // 单品详情
      Column() {
        List({ space: 16 }) {
          ForEach(this.goodsList, (goodsInfo: CarGoodsInfo | GoodsOfOrder) => {
            ListItem() {
              GoodsCard({ goodsInfo });
            };
          }, (goodsInfo: CarGoodsInfo | GoodsOfOrder) => goodsInfo.id);
        };

        Divider().margin({ top: 12, bottom: 10 })
        Row() {
          Column() {
            Text($r('app.string.insulation_bag')).fontSize(14).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.insulation_bag_desc'))
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Row() {
            Text($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text(this.bagMoney.toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            if (!this.readonly) {
              Checkbox({ name: 'selectBag', group: '' })
                .height(12)
                .width(12)
                .selectedColor('#486602')
                .shape(CheckBoxShape.CIRCLE)
                .margin({ left: 4 })
                .onChange(value => {
                  this.changeSelectBag(value)
                })
            }
          }
        }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween)
      }.cardStyle();
    }
  }
}

@ComponentV2
export struct GoodsCard {
  @Param @Require goodsInfo: CarGoodsInfo;

  build() {
    Column() {
      Row() {
        Row() {
          Image(`${Constants.CLOUD_STORAGE_URL}${this.goodsInfo.logo}`).width(60).height(60).borderRadius(8)
          Column() {
            Column() {
              Text(this.goodsInfo.name).fontSize(14).fontColor($r('sys.color.font_primary')).maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis });
              Text(this.goodsInfo.spec?.split(',').join(' | '))
                .fontSize(10)
                .fontColor($r('sys.color.mask_tertiary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .visibility(this.goodsInfo.specType !== Constants.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1).height(60)

            Text(`x${this.goodsInfo.num}`)
              .fontSize(10)
          }
          .height(60)
          .margin({ left: 12 })
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)
          .layoutWeight(1);
        }.layoutWeight(1);

        Row() {
          Text() {
            Span($r('app.string.currency_symbol'))
              .fontSize(8)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Span(new Decimal(this.goodsInfo.money).mul(new Decimal(this.goodsInfo.num)).toString())
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
          };
        }.height(60).alignItems(VerticalAlign.Top).margin({ left: 4 })

      }.width(Constants.FULL_SIZE).justifyContent(FlexAlign.SpaceBetween);

      PkgGoodComp({ pkgGoods: this.goodsInfo.combination })
        .margin({ top: 12 })
        .visibility(this.goodsInfo.specType === Constants.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
    }
  }
}