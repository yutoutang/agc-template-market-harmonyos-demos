import { RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'
import { vipList } from '../constants'
import { IVip } from '../types'
import { PurchasePageVM } from '../viewModels/PurchasePageVM'

@Builder
export function PurchasePageBuilder() {
  PurchasePage()
}

@Entry
@ComponentV2
struct PurchasePage {
  vm: PurchasePageVM = PurchasePageVM.instance

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            Column() {
              Row() {
                Text('寄件会员')
                  .fontSize(18)
                  .fontColor('#68401F')
                  .fontWeight(FontWeight.Bolder)
                  .margin({ right: 6 })
                Image($r('app.media.ic_level'))
                  .width(17)
                  .height(16)
              }
              .width('100%')
              .margin({ bottom: 4 })

              Row() {
                Text('即可开通，升级寄件体验')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('#68401F')
                  .margin({ bottom: 36 })
              }
              .width('100%')

              Row() {
                Image($r('app.media.ic_vip_coupon'))
                  .width(16)
                  .height(16)
                  .margin({ right: 3 })
                Row() {
                  Text('每月6张优惠券')
                    .fontSize(10)
                    .fontWeight(FontWeight.Regular)
                    .fontColor('#68401F')
                }
                .width(72)
                .justifyContent(FlexAlign.Start)

                Image($r('app.media.ic_vip_money'))
                  .width(16)
                  .height(16)
                  .margin({ right: 3 })
                Text('积分翻倍当钱花')
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('#68401F')
              }
              .width('100%')
            }
            .backgroundImage($r('app.media.ic_purchase_vip'))
            .backgroundImageSize(ImageSize.FILL)
            .padding({
              top: 14,
              bottom: 16,
              left: 17,
              right: 17,
            })
            .margin({ bottom: 28 })

            Row() {
              Text('会员周期')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 16 })
            }
            .width('100%')
            .margin({ bottom: 8 })

            List({ space: 8 }) {
              ForEach(vipList, (vip: IVip, index: number) => {
                ListItem() {
                  Column() {
                    Text(vip.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('sys.color.font_primary'))
                    Row() {
                      Text() {
                        Span('￥')
                          .fontSize(14)
                        Span(vip.discountPrice.toString())
                          .fontSize(24)
                      }
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('sys.color.font_primary'))
                      .margin({ right: 6 })

                      Text(`￥${vip.originalPrice}`)
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_tertiary'))
                        .decoration({ type: TextDecorationType.LineThrough })
                    }
                    .alignItems(VerticalAlign.Bottom)

                    if (this.vm.currentIndex === index) {
                      Row() {
                        Text('首月特惠')
                          .fontSize(10)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#68401F')
                      }
                      .width(56)
                      .height(18)
                      .justifyContent(FlexAlign.Center)
                      .backgroundImage($r('app.media.ic_vip_special'))
                      .backgroundImageSize(ImageSize.Contain)
                      .position({ left: 5, top: 5 })
                    }
                  }
                  .width(150)
                  .height(92)
                  .borderRadius(12)
                  .borderWidth(this.vm.currentIndex === index ? 2 : 0)
                  .borderColor(this.vm.currentIndex === index ? '#989898' : '')
                  .backgroundColor(Color.White)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                }
                .onClick(() => {
                  this.vm.currentIndex = index
                })
              }, (item: IVip[]) => JSON.stringify(item))
            }
            .width('100%')
            .margin({ bottom: 12 })
            .listDirection(Axis.Horizontal)

            Row() {
              Text(vipList[this.vm.currentIndex].instructions)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .width('100%')
            .margin({ bottom: 18 })

            Row() {
              Button(`确认支付${vipList[this.vm.currentIndex].discountPrice}元`)
                .width('100%')
                .backgroundColor('#C79E63')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 12 })
            .onClick(() => {
              this.vm.prepay()
            })

            Row() {
              Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
                .width(10)
                .height(10)
                .select($$this.vm.isSign)
                .shape(CheckBoxShape.CIRCLE)
                .onChange((value: boolean) => {

                })
              Text() {
                Span('订阅即代表同意')
                  .fontColor($r('sys.color.font_tertiary'))
                Span('《阅读会员服务协议》')
                  .fontColor('rgba(104,64,31,0.6)')
                  .onClick(() => {
                    RouterModule.push({ url: RouterMap.PRIVACY_PAGE })
                  })
              }
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
            }
            .margin({ bottom: 12 })
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      }
      .padding({ left: 16, right: 16 })
    }
    .title('开通会员')
    .backgroundColor('#F1F3F5')
  }
}