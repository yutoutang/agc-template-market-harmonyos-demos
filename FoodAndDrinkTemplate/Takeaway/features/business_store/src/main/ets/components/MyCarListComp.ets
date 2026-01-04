import { CarGoodsInfo, CarGoodsInfoResp, MyCar, MyCartServiceApi, StoreServiceApi } from 'lib_takeaway_api';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { StorePageViewModel } from '../viewModels/StorePageVM';
import { CommonConstants } from 'lib_common';
import { CommonUrl } from '../common/Constants';

@ComponentV2
export struct MyCarListComp {
  @Consumer() storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;
  @Require @Param vm: StorePageViewModel
  @Local carGoodsList: CarGoodsInfo[] = []
  @Event close: () => void = () => {
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 蒙层
      Column() {
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.mask_fourth'))
      .onClick(() => {
        this.close()
      })

      Column() {
        Column() {
          Row()
            .width(48)
            .height(4)
            .backgroundColor($r('sys.color.mask_fourth'))
            .borderRadius(2)
            .margin({ top: 8 })
          Row() {
            Text('已选商品')
              .fontColor($r('sys.color.black'))
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .layoutWeight(1)
            Row() {
              Text($r('app.string.clear_car'))
                .fontSize(14)
                .fontWeight(400)
                .fontColor('#999999')
                .margin({ left: 4 })
              Image($r('app.media.clear_car')).width(24)

            }
            .onClick(() => {
              StoreServiceApi.clearStoreCar(this.vm.storeId)
              this.storeCar = new MyCar()
              this.vm.cleanStoreCar()
            })
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(56)
          .padding(16)
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width(CommonConstants.FULL_PERCENT)
        .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT })

        List({ space: 12 }) {
          ForEach(this.storeCar?.goodsList, (carGoodsInfo: CarGoodsInfo) => {
            ListItem() {
              CarCard({ carGoodsInfo: carGoodsInfo, vm: this.vm })
            }
          }, (carGoodsInfo: CarGoodsInfoResp) => `${carGoodsInfo.id}-${carGoodsInfo.num}`)
          // 购物车占位
          ListItem() {
            Row().width(CommonConstants.FULL_PERCENT).height(62)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .layoutWeight(1)
        .padding({
          top: 8,
          left: 16,
          right: 16,
        })
        .backgroundColor($r('sys.color.background_primary'))
        .scrollBar(BarState.Off)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(500)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius({ topLeft: 32, topRight: 32 })
      .constraintSize({ maxWidth: CommonConstants.FULL_PERCENT })
    }

  }
}

@ComponentV2
struct CarCard {
  @Require @Param vm: StorePageViewModel
  @Param @Require carGoodsInfo: CarGoodsInfo
  @Local carGoodsNum: number = 0
  @Consumer() storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;

  aboutToAppear(): void {
    this.carGoodsNum = this.carGoodsInfo.num
  }

  @Monitor('vm.storeCar.num')
  listenChange(monitor: IMonitor) {
    this.carGoodsNum = this.carGoodsInfo.num
  }

  build() {
    Row() {
      // 左侧图片
      Image(`${CommonUrl.CLOUD_STORAGE_URL}${this.carGoodsInfo.logo}`)
        .width(60)
        .height(60)
        .borderRadius(8)
      // 右侧交互区
      Column() {
        // 商品名称 价格 操作按钮
        Row() {
          Text(this.carGoodsInfo.name)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#121212')
          // 必选
          if (this.carGoodsInfo.isMust === 1) {
            Text('必选')
              .fontSize(10)
              .fontWeight(500)
              .fontColor($r('sys.color.comp_background_list_card'))
              .backgroundColor($r('app.color.app_theme'))
              .width(26)
              .margin({ left: 6 })
              .textAlign(TextAlign.Center)
          }
          Blank().layoutWeight(1)
          Row() {
            Text() {
              Span($r('app.string.currency_symbol'))
                .fontSize($r('sys.float.Caption_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
              Span(`${Number(this.carGoodsInfo.money)}`)
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
            }
            .margin({ right: 8 })

            Image($r('app.media.ic_subtract'))
              .width(20)
              .height(20)
              .onClick(() => {
                if (this.carGoodsInfo?.id && this.carGoodsInfo?.num) {
                  MyCartServiceApi.subMyCar(this.vm.storeId, this.carGoodsInfo.id)
                  this.vm.updateStoreCar()
                  this.storeCar =
                    this.vm.myCar.myCar.find((item: MyCar) => item.storeId === this.vm.storeId) || new MyCar()
                  if (this.carGoodsInfo.isMust === 1) {
                    this.vm.mustGoodsCtrl.subIsMust()
                  }
                }
              })
            Text(`${this.carGoodsNum}`)
              .margin({ left: 8, right: 8 })
              .fontSize(12)
              .fontColor('#909399')
              .fontWeight(400)
            Image($r('app.media.ic_add_car'))
              .width(20)
              .height(20)
              .onClick(() => {
                if (this.carGoodsInfo?.id && this.carGoodsInfo?.num) {
                  if (this.carGoodsInfo.num >= 10) {
                    promptAction.showToast({ message: '已达最大限购数量' });
                    return
                  }
                  let flag = MyCartServiceApi.addMyCar(this.vm.storeId, this.carGoodsInfo.id)
                  if (flag === 1) {
                    this.vm.updateStoreCar()
                    this.storeCar =
                      this.vm.myCar.myCar.find((item: MyCar) => item.storeId === this.vm.storeId) || new MyCar()
                  }
                  if (this.carGoodsInfo.isMust === 1) {
                    this.vm.mustGoodsCtrl.addIsMust()
                  }
                } else {
                  return
                }
              })
          }

        }

        // 规格
        Row() {
          Text(this.carGoodsInfo.spec)
            .fontSize(12)
            .fontColor('#909399')
            .fontWeight(400)
        }
        .justifyContent(FlexAlign.Start)
      }
      .padding({
        top: 8,
        bottom: 8,
      })
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(60)
      .layoutWeight(1)

    }
    .visibility(this.carGoodsInfo.num > 0 ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }
}