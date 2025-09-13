import { Constants } from '../constants/Index';
import { Goods } from '../models/Index';

@ComponentV2
export struct SnackSizedDeal {
  @Param @Require goodsList: Goods[] = []
  @Local addGoodsList: Goods[] = []
  private indicatorController: IndicatorComponentController = new IndicatorComponentController();
  private swiperController: SwiperController = new SwiperController();
  @Event closeDialog: (addGoodsList?: Goods[]) => void = () => {
  }

  @Computed
  get lowestPrice() {
    let minPrice: number = this.goodsList.length > 0 ? this.goodsList[0].money : 0
    this.goodsList.forEach(item => {
      if (item.money < minPrice) {
        minPrice = item.money
      }
    })
    return minPrice
  }

  @Computed
  get totalMoney() {
    let totalMoney: number = 0
    this.addGoodsList.forEach(item => {
      totalMoney = totalMoney + item.money
    })
    return totalMoney
  }

  build() {
    Column({ space: 12 }) {
      Text('超值加购').fontSize(30).fontColor($r('sys.color.font_on_primary')).fontWeight(FontWeight.Medium)
      Row({ space: 24 }) {
        Row({ space: 2 }) {
          Text(`低至`).fontSize(14).fontColor($r('sys.color.font_on_primary'))
          Text(`￥${this.lowestPrice}`).fontSize(14).fontColor($r('sys.color.multi_color_08'))
          Text(`起差值加购以下商品`).fontColor($r('sys.color.font_on_primary'))
        }

        Image($r('app.media.ic_close_white')).width(40).onClick(() => {
          this.closeDialog()
        })
      }.width('100%').justifyContent(FlexAlign.Center)

      Swiper(this.swiperController) {
        ForEach(this.goodsList, (item: Goods) => {
          Column({ space: 8 }) {
            Column({ space: 12 }) {
              Image(`${Constants.CLOUD_STORAGE_URL}${item.logo}`).width(220).height(220).borderRadius(8)
              Row() {
                Text(item.name).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary')).layoutWeight(1)
                Text('限购一件')
                  .fontSize($r('sys.float.Caption_L'))
                  .fontColor($r('sys.color.multi_color_09'))
                  .padding({
                    top: 1,
                    bottom: 1,
                    left: 2,
                    right: 2,
                  })
                  .margin({ left: 8 })
                  .border({ width: 1, color: $r('sys.color.multi_color_09'), radius: 2 })
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)
            }.width(244).padding(12).backgroundColor($r('sys.color.background_primary'))

            Row() {
              Row() {
                Text() {
                  Span('￥').fontSize(12).fontWeight(FontWeight.Regular)
                  Span(item.money.toString()).fontSize(16).fontWeight(FontWeight.Medium)
                }.fontColor($r('sys.color.multi_color_08'))

                Text() {
                  Span('￥').fontSize(8).fontWeight(FontWeight.Medium)
                  Span(item.money2.toString()).fontSize(12).fontWeight(FontWeight.Medium)
                }.fontColor($r('sys.color.font_primary')).opacity(0.4).margin({ left: 4 }).decoration({
                  type: TextDecorationType.LineThrough,
                  color: $r('sys.color.font_secondary'),
                });
              }

              Row() {
                Row() {
                  Text('已选').fontSize(12).fontColor($r('sys.color.font_secondary'))
                  Text(`1`).fontSize(12).fontColor($r('sys.color.multi_color_09'))
                  Text('件').fontSize(12).fontColor($r('sys.color.font_secondary'))
                }

                Image($r('app.media.ic_add_grey')).width(28).margin({ left: 8 })
              }.visibility(this.isSelectedGood(item) ? Visibility.Visible : Visibility.None)

              Image($r('app.media.add_car'))
                .width(28)
                .margin({ left: 8 })
                .visibility(this.isSelectedGood(item) ? Visibility.None : Visibility.Visible)
                .onClick(() => {
                  this.addGoodsList.push(item)
                })
            }
            .width(244)
            .padding(12)
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor($r('sys.color.background_primary'))
          }.borderRadius(16).clip(true).backgroundColor($r('sys.color.background_secondary'))
        }, (item: Goods) => JSON.stringify(item))
      }.loop(true).curve(Curve.Linear).itemSpace(12).indicator(this.indicatorController)

      IndicatorComponent(this.indicatorController)
        .initialIndex(0)
        .style(
          new DotIndicator()
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(6)
            .selectedItemHeight(6)
            .color('#33FFFFFF')
            .selectedColor($r('sys.color.comp_background_primary_contrary')))
        .loop(true)
        .count(this.goodsList.length)
        .vertical(true)

      Column({ space: 24 }) {
        Text() {
          Span('已加购')
          Span(this.addGoodsList.length.toString())
          Span('件商品（最多加购2件）')
        }.fontSize(16).fontColor($r('sys.color.font_on_primary')).fontWeight(FontWeight.Medium)

        List({ space: 8 }) {
          ForEach(this.addGoodsList, (item: Goods) => {
            ListItem() {
              Stack() {
                Image(`${Constants.CLOUD_STORAGE_URL}${item.logo}`).width(48).height(48).borderRadius(8)
                Image($r('app.media.ic_close_circle')).width(16).position({ x: 40 }).onClick(() => {
                  this.addGoodsList = this.addGoodsList.filter(goods => goods.id !== item.id)
                })
              }.align(Alignment.TopEnd)
            }.width(56).align(Alignment.Start)
          }, (item: Goods) => item.id)
        }.height(48).listDirection(Axis.Horizontal).alignListItem(ListItemAlign.Start)
      }.visibility(this.addGoodsList.length ? Visibility.Visible : Visibility.None)

      Row({ space: 8 }) {
        Button('放弃加购')
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor($r('sys.color.comp_common_contrary'))
          .layoutWeight(1)
          .onClick(() => {
            this.closeDialog()
          })
        Button() {
          Text() {
            if (this.addGoodsList.length) {
              Span(`￥${this.totalMoney}`)
            }
            Span(`一键加购`)
          }
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_on_primary'))
          .fontWeight(FontWeight.Medium)
        }
        .height(40)
        .backgroundColor($r('sys.color.multi_color_09'))
        .layoutWeight(1)
        .onClick(() => {
          this.closeDialog(this.addGoodsList)
        })
      }.width('100%')
      .margin({ top: 12, left: 12, right: 12 })
      .constraintSize({ maxWidth: '100%' })
    }.width('100%')
    .margin({ left: 6, right: 16 })
    .constraintSize({ maxWidth: '100%' })
  }

  isSelectedGood(item: Goods) {
    return this.addGoodsList.find(goods => goods.id === item.id)
  }
}