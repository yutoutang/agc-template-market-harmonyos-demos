import { CommonConstants, Logger } from 'lib_common'
import { CarGoodsInfo, MyCar, MyCartServiceApi } from 'lib_takeaway_api'
import { CarPageViewModel } from '../viewmodels/CarPageViewModel'
import { promptAction } from '@kit.ArkUI'

const TAG = '[CarGoodsCard]';

@ComponentV2
export struct CarGoodsCard {
  @Param @Require carVM: CarPageViewModel
  @Param @Require carGoods: CarGoodsInfo
  @Param @Require storeId: string
  @Consumer() checkCarIds: string[] = []
  @Consumer() allCarIds: string[] = []
  @Local carGoodsNum: number = 0
  @Event refresh: () => void = () => {
  }

  aboutToAppear(): void {
    this.carGoodsNum = this.carGoods.num
  }

  @Monitor('carVM.totalGoodsNum')
  listenChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      Logger.info(TAG,`change from ${monitor.value()?.before} to ${monitor.value()?.now}`);
      let isDelete: boolean = true
      this.carVM.myCar.myCar.forEach((car: MyCar) => {
        car.goodsList.forEach((goods: CarGoodsInfo) => {
          if (goods.id === this.carGoods.id) {
            isDelete = false
            this.carGoodsNum = goods.num
          }
        })
      })
      if (isDelete) {
        this.carGoodsNum = 0
      }
    }
  }

  build() {
    Row() {
      Checkbox({ name: this.carGoods.id, group: this.storeId })
        .shape(CheckBoxShape.CIRCLE)
        .select(this.checkCarIds.includes(this.carGoods.id))
        .selectedColor($r('app.color.orange_yellow'))
        .margin({
          left: 10,
          right: 10
        })
        .onChange((isSelect: boolean) => {
          this.carGoods.isCheck = isSelect
          this.refresh()
        })
      Image(`https://agc-storage-drcn.platform.dbankcloud.cn/v0/test-1pvkp/${this.carGoods.logo}`)
        .width(60)
        .height(60)
        .borderRadius(8)
        .margin({
          right: 12
        })
      Column() {
        Row() {
          Row() {
            Text(this.carGoods.name)
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#121212')
            if (this.carGoods.isMust) {
              Text('必选')
                .fontSize(10)
                .fontWeight(500)
                .fontColor($r('sys.color.comp_background_list_card'))
                .backgroundColor($r('app.color.app_theme'))
                .width(26)
                .margin({ left: 6 })
                .textAlign(TextAlign.Center)
            }
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)

          Text() {
            Span($r('app.string.currency_symbol'))
              .fontColor('#121212')
              .fontWeight(500)
              .fontSize(12)
            Span(`${this.carGoods.money}`)
              .fontColor('#121212')
              .fontWeight(500)
              .fontSize(16)
          }.margin({
            right: 8
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Text(this.carGoods.spec)
            .fontSize(12)
            .fontWeight(400)
            .fontColor('#909399')
          // 编辑状态下
          Row() {
            Image($r('app.media.ic_subtract'))
              .width(20)
              .height(20)
              .enabled(this.carGoodsNum > 1)
              .opacity(this.carGoodsNum > 1 ? 1 : 0.5)
              .onClick(() => {
                let flag = MyCartServiceApi.subMyCar(this.storeId, this.carGoods.id)
                if (flag === 1) {
                  this.refresh()
                  promptAction.showToast({ message: '减少成功！' });
                }
              })
            Text(this.carGoodsNum + '')
              .margin({ left: 8, right: 8 })
              .fontSize(12)
              .fontColor('#909399')
              .fontWeight(400)
            Image($r('app.media.ic_add_car'))
              .width(20)
              .height(20)
              .enabled(this.carGoodsNum < 10)
              .opacity(this.carGoodsNum < 10 ? 1 : 0.5)
              .onClick(() => {
                let flag = MyCartServiceApi.addMyCar(this.storeId, this.carGoods.id)
                if (flag === 1) {
                  this.refresh()
                  promptAction.showToast({ message: '添加成功！' });
                }
              })
          }
          .visibility(this.carVM.isEdit ? Visibility.Visible : Visibility.None)
          .margin({
            right: 8
          })

          // 非编辑状态下
          Text(`x${this.carGoods.num}`)
            .fontSize(12)
            .fontWeight(400)
            .fontColor('#909399')
            .margin({
              right: 8
            })
            .visibility(!this.carVM.isEdit ? Visibility.Visible : Visibility.None)
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .height(60)
      .layoutWeight(1)
      .padding({
        top: 8,
        bottom: 8,
      })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({
      top: 5,
      bottom: 5
    })
    .visibility(this.carGoodsNum > 0 ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_PERCENT)
  }
}