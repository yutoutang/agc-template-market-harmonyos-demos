import { RouterModule } from 'commonlib';

@Builder
export function TermsOfServicePageBuilder() {
  TermsOfServicePage();
}

@ComponentV2
export struct TermsOfServicePage {
  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back'))
          .size({ width: $r('app.float.vp_40'), height: $r('app.float.vp_40') })
          .borderRadius($r('app.float.vp_20'))
          .margin({ left: 16 })
          .onClick(() => {
            RouterModule.pop();
          });
        Blank();
      }
      .justifyContent(FlexAlign.Start)
      .size({ width: '100%', height: 56 });

      Scroll() {
        Column() {
          Row() {
            Text('用户服务协议')
              .fontSize($r('sys.float.Title_S'))
              .fontWeight(FontWeight.Bold);
          }
          .width('100%')
          .justifyContent(FlexAlign.Center);

          Text('本《备考用户服务协议》（简称“本服务协议”或“备考用户协议”）是您与备考之间就注册备考用户账号及使用备考的各项服务等相关事宜所订立的协议。为使用备考的服务，您应当仔细阅读并遵守本服务协议下的全部内容，特别是涉及免除或者责任限制的条款，该类条款可能以黑体加粗或加下划线的形式提示您重点注意。除非您已阅读并接受本服务协议所有条款，否则您将不能注册备考账号或使用备考的服务，如您不同意本服务条款的任意内容，请勿注册或使用备考的服务，并应立即停止注册程序。如您对本服务协议的内容（特别是涉及免除或者责任限制的条款）有任何疑义，可随时按照本服务协议中列明的联系方式与我们联系，我们将根据您的要求为您进一步解释和说明相关内容。如您勾选“我同意《备考用户服务协议》”并通过注册程序或其他任何方式使用或接受备考的任何服务，即视为您已阅读并同意本服务协议，自愿接受本服务协议的所有内容的约束。请您在决定注册或使用服务前再次确认您已知悉并完全理解本服务协议的所有内容。\n' +
            '如果您未满18周岁，请务必在家长和其他法定监护人的陪同下阅读本服务协议，并在进行注册、下单、支付等任何行为或使用备考的其他任何服务前，应事先征得您的家长和其他法定监护人的同意。\n')
            .lineHeight(24);
        }.layoutWeight(1).padding(16);
      }
      .align(Alignment.TopStart)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring);
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}