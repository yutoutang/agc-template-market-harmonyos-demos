import {
  CarGoodsInfo,
  CommonUrl,
  Constants,
  Goods,
  GoodsRouter,
  GoodsSpecEnum,
  MyCarModel,
  RouterMap,
} from 'common/Index';
import { AppStorageV2, MeasureText } from '@kit.ArkUI';
import { SpecSheetBuilder } from './SpecSheetComp';

@ComponentV2
export struct GoodsInfoComp {
  @Consumer('pageStack') pageStack: NavPathStack = new NavPathStack();
  @Param @Require goods: Goods;
  @Local myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel) as MyCarModel
  @Local specSheetFlag: boolean = false;
  @Local showGoodsContent: boolean = true;
  @Local goodTextWidth: number = 0;

  @Computed
  get carGoodsInfo() {
    return this.myCarModel.myCar.carGoods?.find((item: CarGoodsInfo) => item.goodsId === this.goods.id)
  }

  goodsChange() {
    let nameWidth: number = MeasureText.measureText({
      textContent: this.goods.name,
      fontSize: '14px',
    });
    if (nameWidth > this.goodTextWidth) {
      this.showGoodsContent = false;
    } else {
      this.showGoodsContent = true;
    }
  }

  goGoodsDetail() {
    this.pageStack.pushPathByName(RouterMap.GOODS_DETAIL_PAGE, { goodsInfo: this.goods } as GoodsRouter);
  }

  build() {
    Row() {
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.goods?.logo}`).width(82).height(82).borderRadius(8)
      Column() {
        Column() {
          Text(this.goods?.name)
            .fontSize(14)
            .fontWeight(500)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(20);
          if (this.showGoodsContent) {
            Text(this.goods?.content)
              .fontSize(10)
              .lineHeight(14)
              .fontColor($r('sys.color.mask_tertiary'))
              .margin({ top: 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis });
          }
          Text(Number(this.goods?.sales) > 100 ? $r('app.string.sales_more') :
          $r('app.string.month_sale', this.goods?.sales))
            .fontSize(10)
            .lineHeight(14)
            .fontColor($r('sys.color.mask_tertiary'))
            .margin({ top: 2 });
        }.alignItems(HorizontalAlign.Start)

        Row() {
          Row() {
            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize(8)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(14);
              Span(`${Number(this.goods?.money)}`)
                .fontSize(14)
                .fontWeight(500)
                .fontColor($r('sys.color.font_primary'))
                .lineHeight(20);
            };
          };

          Row() {
            Text(this.goods?.specType === GoodsSpecEnum.PACKAGE_TYPE ? $r('app.string.select_package') :
            $r('app.string.select_spec'))
              .fontSize(10)
              .fontColor($r('sys.color.white'))
              .padding({
                top: 5,
                bottom: 5,
                left: 8,
                right: 8,
              });
          }
          .borderRadius(14)
          .backgroundColor($r('app.color.mainColor'))
          .onClick(() => {
            if (this.goods?.specType === GoodsSpecEnum.PACKAGE_TYPE) {
              this.goGoodsDetail();
              return;
            }
            this.specSheetFlag = true;
          });
        }.margin({ top: 6 }).width(Constants.FULL_SIZE).height(22).justifyContent(FlexAlign.SpaceBetween);

      }
      .layoutWeight(1)
      .height(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ left: 5.5, top: 1, bottom: 1 })
      .alignItems(HorizontalAlign.Start)
      .onAreaChange((oldValue, newValue) => {
        if (newValue.width && oldValue.width !== newValue.width) {
          this.goodTextWidth = Number(newValue.width);
          this.goodsChange();
        }
      })
    }
    .alignItems(VerticalAlign.Top)
    .width(Constants.FULL_SIZE)
    .height(80)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.goGoodsDetail();
    })
    .bindSheet($$this.specSheetFlag, SpecSheetBuilder(this.goods, () => {
      this.specSheetFlag = false
    }), {
      detents: [500, 501],
      blurStyle: BlurStyle.Thick,
      showClose: true,
      backgroundColor: $r('sys.color.background_fourth'),
      title: { title: '' },
    });
  }
}