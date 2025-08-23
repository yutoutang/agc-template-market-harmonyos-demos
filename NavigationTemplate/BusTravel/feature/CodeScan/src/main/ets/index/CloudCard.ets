import { AppStorageV2 } from '@kit.ArkUI'
import { GlobalState, RouteEntryVM, RouterModule, UserInfoModel } from 'common'
import { CodeScanComp } from './CodeScanPage'


@Builder
export function CloudCardBuilder() {
  CloudCard()
}

@ComponentV2
export struct CloudCard {
  @Local globalState: GlobalState = AppStorageV2.connect(GlobalState, 'GlobalState', () => new GlobalState())!
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'UserInfoModel', () => new UserInfoModel())!
  @Local isSecondLevel: boolean = false
  vm: RouteEntryVM = RouteEntryVM.instance
  usingTexts: string[] =
    ['1.开通乘车码：点击下方“领取电子卡”，确认信息，勾选协议，点击“点击同意协议并领卡”和“开通免密支付”。',
      ' 2.扫码乘车：上车时打开乘车码界面，将手机屏幕上的乘车码对准公交车上的扫码设备，听到“滴”声或看到相关提示即表示刷码成功，乘车费用会在余额中自动扣除。']

  aboutToAppear(): void {
    this.isSecondLevel = RouterModule.getStackSize() > 0
  }

  saveCloudCardUse() {
    this.globalState.cloudCard = true
  }

  build() {
    NavDestination() {
      if (this.userInfo.isLogin === true && this.globalState.cloudCard) {
        CodeScanComp()
      } else {
        Scroll() {
          Column() {
            Column() {
              if (!this.isSecondLevel) {
                this.buildTitle()
              }
              this.buildCard()
              this.buildUsing()
            }
            .width('100%s')
            .alignItems(HorizontalAlign.Center)

            Blank()
              .layoutWeight(1)

            Button('开通')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_L'))
              .width('312lpx')
              .backgroundColor($r('app.color.system_color_green'))
              .onClick(() => {
                if (this.userInfo.isLogin === false) {
                  this.vm.toRouteDetail('Login')
                } else if (this.globalState.cloudCard === false) {
                  this.vm.toRouteDetail('ActivateCloudCard')
                } else { // 跳转到二维码页面并且记住用户已经开通过云卡
                  this.saveCloudCardUse()
                }
              })
              .margin({ bottom: 20 })
          }
          .width('100%')
          .align(Alignment.TopStart)
          .backgroundImageSize(ImageSize.Auto)
          .backgroundColor('#F1F3F5')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarWidth('0vp')
        .edgeEffect(EdgeEffect.Spring)
      }
    }.hideTitleBar(!this.isSecondLevel)
    .title('乘车码')
  }

  @Builder
  buildTitle() {
    Row() {
      Text('乘车码')
        .fontColor($r('sys.color.black'))
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .margin({ left: 24 })
    }
    .width('100%')
    .height(70)
    .align(Alignment.Start)
  }

  @Builder
  buildCard() {
    Column() {
      Text('南京公交')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_secondary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Text('城市一卡通')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_secondary'))
        .textAlign(TextAlign.Center)
        .width('100%')
        .textAlign(TextAlign.Center)

      Row()
        .width('100%')
        .height(19)
    }
    .width('90%')
    .height('160lpx')
    .padding(10)
    .backgroundImage($r('app.media.grey'))
    .backgroundImageSize(ImageSize.Contain)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildUsing() {
    Column() {
      Text('使用说明：')
        .fontSize(14)
        .width('100%')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 12 })
        .align(Alignment.Start)
      Text(this.usingTexts[0])
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .margin({ bottom: 12 })
        .width('100%')
      Text(this.usingTexts[1])
        .fontSize(12)
        .fontWeight(FontWeight.Regular)
        .width('100%')
    }
    .width('328lpx')
    .padding(20)
    .margin({ top: 12 })
    .backgroundColor($r('app.color.background_color_white'))
    .borderRadius(20)
    .align(Alignment.Start)
  }
}