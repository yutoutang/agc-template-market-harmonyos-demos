import { ExpressPageVM } from '../viewModels/ExpressPageVM'
import { CustomContentDialog } from '@kit.ArkUI'
import { StoreCard } from './StoreCard'
import { RouterMap, CommonDivider, IBuilderType, payMethodList, gridList } from 'module_base'
import { CommonButton, CommonCoupon, CommonTitle, Coupon, RouterModule } from 'lib_foundation'


@ComponentV2
export struct ShippingInfo {
  vm: ExpressPageVM = ExpressPageVM.instance
  couponDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.couponBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })
  gridDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.gridBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })
  payDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.priceBuilder();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })

  build() {
    Column() {
      Column() {
        StoreCard({ servicePoint: this.vm.selectedServicePoint, isSelected: true })
        Row() {
          Text('查看全部')
            .fontSize(12)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ right: 4 })
          Image($r('app.media.ic_arrow_right'))
            .width(12)
            .height(12)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 12 })
        .onClick(() => {
          this.vm.isFresh = false
          RouterModule.push({ url: RouterMap.SERVICE_POINT_PAGE, param: this.vm.selectedServicePoint?.id })
        })

        CommonDivider()
          .margin({ bottom: 12 })
        this.contentBuilder({
          label: '物品信息',
          placeholder: '请选择物品信息',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.goodsName,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: false,
          isTime: false,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            this.vm.isFresh = false
            RouterModule.push({ url: RouterMap.GOODS_PAGE, param: true })
          },
        })
        this.contentBuilder({
          label: '付款方式',
          placeholder: '请选择付款方式',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.selectedPayMethod,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: false,
          isTime: false,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            const value = payMethodList[0].text
            this.vm.tempPayMethod = value
            this.payDialogController.open()
          },
        })
        this.contentBuilder({
          label: '格口类型',
          placeholder: '请选择格口',
          placeholderColor: $r('sys.color.font_primary'),
          text: this.vm.selectedGrid,
          textColor: $r('sys.color.font_tertiary'),
          isDivider: false,
          isTime: false,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            const value = gridList[0].text
            this.vm.tempGrid = value
            this.gridDialogController.open()
          },
        })
      }
      .backgroundColor(Color.White)
      .borderRadius(8)
      .padding({ top: 12, left: 12, right: 12 })
      .margin({ bottom: 12 })

      Row() {
        this.contentBuilder({
          label: '优惠券',
          text: this.vm.couponName,
          placeholder: '请选择优惠券',
          placeholderColor: '#0A59F7',
          textColor: '#0A59F7',
          isDivider: false,
          isTime: false,
          func: () => {
            if (!this.vm.checkAddress()) {
              return
            }
            this.couponDialogController.open()
          },
        })
      }
      .padding({ top: 12, left: 12, right: 12 })
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ bottom: 12 })
    }
    .width('100%')
  }

  @Builder
  contentBuilder($$: IBuilderType) {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text($$.label)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
        }

        Row() {
          Text($$.text ? $$.text : $$.placeholder)
            .fontSize(10)
            .fontWeight(FontWeight.Regular)
            .fontColor($$.text ? $$.placeholderColor : $$.textColor)
            .margin({ right: 4 })
          Image($r('app.media.ic_arrow_right'))
            .width(12)
            .height(12)
        }
      }
      .margin({ bottom: 12 })

      if ($$.isDivider) {
        Divider().strokeWidth(1).color('rgba(0,0,0,0.20)')
          .margin({ bottom: 12 })
      }
    }
    .onClick(() => {
      $$.func()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  couponBuilder(): void {
    Column() {
      this.titleBuilder('优惠券', () => {
        this.couponDialogController.close()
      })
      if (this.vm.couponList.length === 0) {
        Column() {
          Text('暂无优惠券')
            .fontSize(16)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.vm.couponList, (coupon: Coupon) => {
            ListItem() {
              CommonCoupon({
                isVip: false,
                coupon: coupon,
                couponDialogController: this.couponDialogController,
                onChange: (coupon) => {
                  this.vm.selectedCoupon = coupon
                  this.vm.couponName = coupon?.name!!
                },
              })
            }
            .margin({ bottom: 14 })
          }, (item: Coupon[]) => JSON.stringify(item))
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
    }
    .width('100%')
    .padding({ bottom: 28 })
  }

  // 自定义弹出框的内容区
  @Builder
  gridBuilder(): void {
    Column() {
      Scroll() {
        Column() {
          this.titleBuilder('格口类型', () => {
            this.gridDialogController.close()
          })

          TextPicker({ range: gridList, selected: this.vm.selectedGridIndex })
            .onChange((value) => {
              this.vm.tempGrid = value as string
            })
          this.buttonBuilder(
            () => {
              this.gridDialogController.close()
            }, () => {
            this.vm.selectedGrid = this.vm.tempGrid
            this.vm.selectedGridIndex = this.vm.getSelectedSettingIndex(this.vm.tempGrid, gridList)
            this.vm.getEstimatedPrice()
            this.gridDialogController.close()
          },
          )
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  @Builder
  priceBuilder(): void {
    Column() {
      Scroll() {
        Column() {
          this.titleBuilder('付款方式', () => {
            this.payDialogController.close()
          })
          TextPicker({ range: payMethodList, selected: this.vm.selectedPayMethodIndex })
            .onChange((value) => {
              this.vm.tempPayMethod = value as string
            })
          this.buttonBuilder(
            () => {
              this.payDialogController.close()
            }, () => {
            this.vm.selectedPayMethod = this.vm.tempPayMethod
            this.vm.selectedPayMethodIndex = this.vm.getSelectedSettingIndex(this.vm.tempPayMethod, payMethodList)
            this.vm.getEstimatedPrice()
            this.payDialogController.close()
          },
          )
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  @Builder
  titleBuilder(title: string, func: Function) {
    CommonTitle({ title: title, func: func })
  }

  @Builder
  buttonBuilder(cancelFunc: Function, saveButton: Function) {
    CommonButton({ cancelFunc: cancelFunc, saveButton: saveButton })
  }
}