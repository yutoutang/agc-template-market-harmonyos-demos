import { CarGoodsInfo } from '../models/Index';
import { Constants } from '../constants/Index';
import { PkgGoodComp } from 'base_ui';

@ComponentV2
export struct MyCarListComp {
  @Param carGoods: Array<CarGoodsInfo> = []
  @Param carCheck: Array<string> = []
  @Event changeCarPanel: () => void = () => {
  };
  @Event clearCarCb: () => void = () => {
  };
  @Event updateCarCb: (id: string, num: number) => void = () => {
  };
  @Event changeCarCheck: (id: string, isDelete?: boolean) => void = () => {
  };

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
      }.width('100%').height('100%').backgroundColor($r('sys.color.mask_tertiary'))
      .onClick(() => {
        this.changeCarPanel()
      })

      Column() {
        Column() {
          Row().width(48).height(4).backgroundColor($r('sys.color.mask_fourth')).borderRadius(2)
          Row() {
            Row() {
              CheckboxGroup({ group: 'checkboxGroup' })
                .height(12)
                .width(12)
                .checkboxShape(CheckBoxShape.CIRCLE)
                .selectedColor($r('app.color.mainColor'))

              Text($r('app.string.check_all'))
                .fontSize(12)
                .fontColor('#E6000000')
                .lineHeight(16)
                .margin({ left: 13 })
            }

            Row() {
              Image($r('app.media.ic_clear_car')).width(14)
              Text($r('app.string.clear_car'))
                .fontSize(10)
                .fontColor($r('sys.color.mask_tertiary'))
                .lineHeight(14)
                .margin({ left: 4 })
            }.onClick(() => {
              this.clearCarCb()
            })
          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
        }
        .height(40)
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .justifyContent(FlexAlign.End)

        List({ space: 12 }) {
          ForEach(this.carGoods, (carGoodsInfo: CarGoodsInfo) => {
            ListItem() {
              Column() {
                Row() {
                  Row() {
                    Checkbox({ name: carGoodsInfo.id, group: 'checkboxGroup' })
                      .select(this.carCheck.includes(carGoodsInfo.id))
                      .height(12)
                      .width(12)
                      .selectedColor($r('app.color.mainColor'))
                      .shape(CheckBoxShape.CIRCLE)
                      .onChange((value: boolean) => {
                        this.changeCarCheck(carGoodsInfo.id, !value)
                      })
                    Image(`${Constants.CLOUD_STORAGE_URL}${carGoodsInfo.logo}`)
                      .width(60)
                      .height(60)
                      .margin({ left: 12 })
                    Column() {
                      Text(carGoodsInfo.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_primary'))
                      Text() {
                        Span($r('app.string.selected'))
                        Span(carGoodsInfo.spec?.split(',').join(' | ')).margin({ left: 2 })
                      }
                      .fontSize(10)
                      .fontColor($r('sys.color.mask_tertiary'))
                      .lineHeight(14)
                      .margin({ top: 4 })
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .visibility(carGoodsInfo.specType !== Constants.PACKAGE_TYPE ? Visibility.Visible :
                        Visibility.None)

                      Text() {
                        Span($r('app.string.currency_symbol'))
                          .fontSize(8)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                        Span(`${Number(carGoodsInfo.money)}`)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                      }.margin({ top: 4 })
                    }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).height(60)
                  }.layoutWeight(1)

                  Row() {
                    Image($r('app.media.ic_subtract_car')).width(22).onClick(() => {
                      if (carGoodsInfo?.id && carGoodsInfo?.num) {
                        if (carGoodsInfo.num === 1) {
                          this.changeCarCheck(carGoodsInfo.id, true)
                          this.changeCarPanel()
                        }
                        this.updateCarCb(carGoodsInfo.id, carGoodsInfo.num - 1)
                      }
                    })
                    Text(carGoodsInfo.num.toString())
                      .margin({ left: 8, right: 8 })
                      .fontSize(14)
                      .fontColor($r('sys.color.font_secondary'))
                      .lineHeight(20)
                    Image($r('app.media.ic_add_car')).width(22).onClick(() => {
                      if (carGoodsInfo?.id && carGoodsInfo?.num) {
                        this.updateCarCb(carGoodsInfo.id, carGoodsInfo.num + 1)
                      } else {
                        console.error(`GoodInfo not in disheList: ${JSON.stringify(carGoodsInfo.goodsId)}.`);
                        return
                      }
                    })
                  }.height(60).justifyContent(FlexAlign.End).alignItems(VerticalAlign.Bottom)
                }.width('100%').justifyContent(FlexAlign.SpaceBetween)

                PkgGoodComp({ pkgGoods: carGoodsInfo.combination })
                  .margin({ top: 12 })
                  .visibility(carGoodsInfo.specType === Constants.PACKAGE_TYPE ? Visibility.Visible : Visibility.None)
              }
            }
          }, (carGoodsInfo: CarGoodsInfo) => `${carGoodsInfo.id}+${carGoodsInfo.num}`)
          // 购物车占位
          ListItem() {
            Row().width('100%').height(60)
          }
        }
        .width('100%')
        .constraintSize({ maxWidth: '100%' })
        .margin({ left: 16, right: 16 })
        .padding({ left: 12, right: 14, top: 12 })
        .borderRadius({ topLeft: 12, topRight: 12 })
        .backgroundColor($r('sys.color.background_primary'))
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height(340)
      .backgroundColor('#E6FFFFFF')
      .borderRadius({ topLeft: 32, topRight: 32 })
      .clip(true)
      .constraintSize({ maxWidth: '100%' })
    }
  }
}