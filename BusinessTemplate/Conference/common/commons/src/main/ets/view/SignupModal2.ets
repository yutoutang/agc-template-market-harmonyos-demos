import { WebViewParams } from '../viewModel/ParamsType'
import { MyConfig } from '../constants/MyConfig'

@Builder
export function SignupModal2Builder() {
  SignupModal2()
}

@Component
export struct SignupModal2 {
  @Consume('pageStack') pageStack: NavPathStack

  build() {
    NavDestination() {
      Stack() {
        // 蒙层
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor(0x33000000)

        Column() {
          Row() {
            Image(`${MyConfig.URL}agenda3%2Fmodal_close.png?token=538f6e5b-884d-4949-b88d-5ac5aca18b80`).width(13)
          }.padding(15)
          .position({
            right: 0,
            top: 0
          }).onClick(() => {
            this.pageStack.pop()
          })

          Column() {
            Text('您尚未报名')
              .fontSize(18)
              .lineHeight(22)
              .margin({ top: 50 })
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
            Text('报名后可体验更多元服务内容').fontSize(14).lineHeight(22).margin({ top: 10 }).fontColor('#333')
            Text('您可以点击下方链接进入大会官网进行报名').fontSize(12).lineHeight(22).fontColor('#999')
            Button('大会官网')
              .width(210)
              .height(40)
              .margin({ top: 16 })
              .backgroundColor(Color.Transparent)
              .fontColor($r('sys.color.font_emphasize'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Normal)
              .border({
                color: '#F2403D',
                width: 1,
                radius: 8
              })
              .onClick(() => {
                let url = getContext(this).resourceManager.getStringByNameSync('WEBSITE_URL_HDC2025');
                this.pageStack.replacePath({
                  name: 'MyWebView',
                  param: new WebViewParams(url)
                })
              })
          }
        }
        .width(320)
        .height(214)
        .borderRadius(15)
        .backgroundImage(`${MyConfig.URL}agenda3%2FcommonModalBg.png?token=ba5e45ec-1227-4047-8f2c-cea53f81354c`)
        .backgroundImageSize({ width: 94 })
        .backgroundImagePosition(Alignment.BottomStart)
        .backgroundColor('#fff')
      }

    }.hideTitleBar(true)
    .systemTransition(NavigationSystemTransitionType.FADE)
    .mode(NavDestinationMode.DIALOG)
  }
}