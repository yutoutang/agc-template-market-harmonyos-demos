import { AppStorageV2, window } from '@kit.ArkUI';

import {
  TopBar,
  UserInfo,
  MyScrollModifier,
} from 'commonlib'


@ComponentV2
export struct TermsPage {
  @Local bottomHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (e) {
      console.error(`Failed to getLastWindow. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    NavDestination(){
      Column() {
        Column() {
          TopBar({ title: $r('app.string.terms') })
          Text('特别提醒：在您（下或称“用户”）开始阅读' +
            '并决定是否接受《美化创意平台服务协议》' +
            '（“本协议”）之前，特别提醒您仔细阅读并留意本协议中内容；' +
            '未成年人用户请在法定监护人陪同下仔细阅读本协议并决定是否接受本协议。' +
            '若您对本协议存在疑问，或者无法全部或者' +
            '部分接受本协议，或者在使用过程中需要向' +
            '美图公司反馈（含建议、投诉、举报等）。')
            .fontSize(16)
            .opacity(0.6)

        }.alignItems(HorizontalAlign.Start)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_50') })
      .alignItems(HorizontalAlign.Start)
    } .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }
}



@Builder
export function TermsPageBuilder() {
  TermsPage()
}
