import { AvoidRepeatClick } from '../common/AvoidRepeatClick';
import { WebViewParams } from '../viewModel/ParamsType';
import { promptAction } from '@kit.ArkUI';
import { sign } from '../api/serviceLogin';
import { MyConfig } from '../constants/MyConfig';

@Builder
export function PrivacyDialogBuilder() {
  PrivacyDialog()
}

@Component
export struct PrivacyDialog {
  @Consume('pageStack') pageStack: NavPathStack
  @State isAgree: string = 'Not Agree';
  @StorageLink('token') token: string = '';
  @State isChecked: boolean = false

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        // 蒙层
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor(0x33000000)

        // 隐私弹窗
        Column() {
          Row() {
            Text('某开发者服务协议及隐私声明')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')
              .layoutWeight(1)
            Image(`${MyConfig.URL}agenda3%2Fclose1Icon.png?token=3577485c-a68d-4ac4-bf60-9bd027d4ca4b`).width(40).onClick(() => {
              this.pageStack.pop()
            })
          }.margin({ bottom: 16 })

          Text('某开发者平台尊重并保障您的隐私安全。《某开发者生态隐私声明》将阐述某开发者平台处理的个人数据以及处理个人数据的方式和目的。')
            .fontSize(14)
            .lineHeight(21)
            .fontColor('#99191919')
            .textIndent(28)
          Text('为保障某开发者平台健康发展，维护某开发者正当权益，请您阅读并签署 《某开发者服务协议》及《某开发者生态隐私声明》。')
            .margin({ top: 10 })
            .fontSize(14)
            .lineHeight(21)
            .fontColor('#99191919')
            .textIndent(28)
          Row() {
            Checkbox()
              .shape(CheckBoxShape.ROUNDED_SQUARE)
              .width(15)
              .height(15)
              .select($$this.isChecked)
              .margin({
                top: 3
              })
            Flex({
              wrap: FlexWrap.Wrap,
            }) {
              Text('我已阅读并同意上述')
                .fontSize(12)
                .fontColor('#A3A3A3')
                .lineHeight(18)
              Text('《某开发者平台服务协议》')
                .fontColor('#0A59F7')
                .fontSize(12)
                .lineHeight(18)
                .onClick(() => {
                  this.pageStack.pushPath({
                    name: 'MyWebView',
                    param: new WebViewParams($r('app.string.develop_privacy'))
                  })
                })
              Text('、').fontSize(12)
                .fontColor('#A3A3A3')
                .lineHeight(18)
              Text('《某开发者生态隐私声明》')
                .fontColor('#0A59F7')
                .fontSize(12)
                .lineHeight(18)
                .wordBreak(WordBreak.BREAK_ALL)
                .onClick(() => {
                  this.pageStack.pushPath({
                    name: 'MyWebView',
                    param: new WebViewParams($r('app.string.develop_ecology_privacy'))
                  })
                })
            }.layoutWeight(1)
          }.margin({ top: 16 }).alignItems(VerticalAlign.Top)

          Button('同意并进入')
            .margin({ top: 24 })
            .width('100%')
            .onClick(() => {
              if (!this.isChecked) {
                this.getUIContext().getPromptAction().showToast({
                  message: '请勾选同意服务协议',
                  duration: 2000
                });
                return
              }
              AvoidRepeatClick.avoidRepeatClick(() => {
                sign({
                  token: this.token
                }).then((res) => {
                  this.pageStack.pop('success')
                })
              });
            })
        }
        .width('100%')
        .padding({
          top: 16,
          left: 16,
          right: 16,
          bottom: 56
        })
        .backgroundColor(Color.White)
        .borderRadius({
          topLeft: 32,
          topRight: 32,
        })
      }
    }
    .hideTitleBar(true)
    .systemTransition(NavigationSystemTransitionType.FADE)
    .mode(NavDestinationMode.DIALOG)
  }
}