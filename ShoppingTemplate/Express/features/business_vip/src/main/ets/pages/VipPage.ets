import { CheckCard } from '../components/CheckCard';
import { Title } from '../components/Title';
import { VipCard } from '../components/VipCard';
import { VipPageVM } from '../viewModels/VipPageVM';
import { TipsDialog } from '@kit.ArkUI';
import { CommonCoupon, Coupon, RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';

@Entry
@ComponentV2
export struct VipPage {
  vm: VipPageVM = VipPageVM.instance
  dialogController: CustomDialogController = new CustomDialogController({
    builder: TipsDialog({
      imageRes: $r('sys.media.ohos_ic_public_voice'),
      content: '想要卸载这个APP嘛?',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '删除',
        role: ButtonRole.ERROR,
        action: () => {
          console.info('Callback when the second button is clicked')
        },
      },
      onCheckedChange: () => {
        console.info('Callback when the checkbox is clicked')
      },
    }),
  })

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Row() {
          Image($r('app.media.ic_vip_banner'))
            .height(325)
            .width('100%')
            .draggable(false)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        }
        .width('100%')

        Column() {
          Scroll() {
            Column() {
              Row() {
                Image($r('app.media.money'))
                  .width(16)
                  .height(16)
                  .margin({ right: 4 })
                Text() {
                  Span('积分余额')
                    .fontSize(16)
                  Span(this.vm.userInfo.points.toString())
                    .fontSize(24)
                }
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
              }
              .width('100%')
              .margin({ top: 17, bottom: 12 })

              Row() {
                Text('今日积分已领取，每100积分可抵扣快递费5元')
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(Color.White)
              }
              .width('100%')
              .margin({ bottom: 12 })

              CheckCard()
              VipCard()

              Column() {
                ForEach(this.vm.couponList, (coupon: Coupon, index: number) => {
                  Row() {
                    CommonCoupon({
                      isVip: true,
                      coupon: coupon,
                      couponDialogController: this.dialogController,
                      onChange: (coupon) => {
                        if (!this.vm.isLogin) {
                          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
                          return
                        }
                        this.vm.couponList[index].isAvailable = false
                        this.vm.userInfo?.couponList.push(coupon.id)
                      },
                    })
                  }
                  .margin({ bottom: 14 })
                }, (item: Coupon) => JSON.stringify(item.id))
              }
            }
            .padding({ left: 16, right: 16 })
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .margin({ top: 47 })

        Title()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .backgroundColor('#F1F3F5')
  }
}