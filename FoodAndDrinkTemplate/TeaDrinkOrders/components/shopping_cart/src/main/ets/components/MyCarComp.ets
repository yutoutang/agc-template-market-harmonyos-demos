import { promptAction } from '@kit.ArkUI'
import { Decimal } from '@kit.ArkTS'
import { CarGoodsInfo, MyCar } from '../models/Index'

@ComponentV2
export struct MyCarComp {
  @Param @Require myCar: MyCar
  @Param @Require isRest: Boolean
  @Param @Require showCarList: Boolean
  @Param carCheck: Array<string> = []
  @Event changeCarPanel: (value: boolean) => void = () => {
  };
  @Event goConfirmOrderCb: (carGoodsSelect: Array<CarGoodsInfo>) => void = () => {
  };

  @Computed
  get carBtnName() {
    if (this.isRest) {
      return $r('app.string.store_rest')
    } else {
      return $r('app.string.place_order')
    }
  }

  @Computed
  get totalMoney() {
    let totalMoney: number = 0
    this.carCheck.forEach(item => {
      let carGoodsInfo = this.myCar.carGoods?.find(carGood => carGood.id === item)
      if (carGoodsInfo) {
        totalMoney = new Decimal(carGoodsInfo.money).mul(carGoodsInfo.num).add(totalMoney).toNumber()
      }
    })
    return totalMoney
  }

  build() {
    Row() {
      Row() {
        Badge({
          count: this.carCheck.length ?? 0,
          style: { fontSize: 10, badgeSize: 14 },
        }) {
          Image($r('app.media.ic_buy_car')).width(36)
        }

        Text() {
          Span($r('app.string.total_price'))
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .lineHeight(22)
          Span($r('app.string.currency_symbol'))
            .fontSize(8)
            .fontWeight(FontWeight.Medium)
            .fontColor('#486602')
            .lineHeight(14)
          Span(`${Number(this.totalMoney)}`)
            .fontSize(16)
            .fontColor('#486602')
            .lineHeight(20)
            .fontWeight(FontWeight.Bold)
        }.margin({ left: 16 })

      }.layoutWeight(1).onClick(() => {
        this.changeCarPanel(!this.showCarList)
      })

      Button(this.carBtnName)
        .height(32)
        .fontSize(14)
        .fontColor($r('sys.color.white'))
        .backgroundColor($r('app.color.mainColor'))
        .padding({
          left: 11,
          right: 11,
          top: 6,
          bottom: 6,
        })
        .onClick(() => {
          if (this.isRest) {
            promptAction.showToast({ message: $r('app.string.store_rest') })
          } else if (!this.myCar.carGoods?.length || !this.carCheck.length) {
            promptAction.showToast({ message: $r('app.string.need_goods') })
          } else {
            let carGoodsSelect = this.myCar.carGoods
            if (this.carCheck?.length) {
              carGoodsSelect = this.myCar.carGoods.filter(item => this.carCheck?.includes(item.id))
            }
            if (!carGoodsSelect.length) {
              promptAction.showToast({ message: $r('app.string.car_empty_toast') })
              return
            }
            // 下单后收起购物车列表
            this.changeCarPanel(false)
            this.goConfirmOrderCb(carGoodsSelect)
          }
        })
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.SpaceBetween)
    .shadow({
      radius: 4,
      color: '#0D000000',
      offsetX: 0,
      offsetY: -4,
    })
  }
}