/**
 * @usage: 展示当前用户二维码，支持返回
 * @layout: CommonHeader + 居中 QRCode + 描述文案
 * @constraints: 需用户ID；安全边距；浅色背景
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 我的二维码页
 * @subPage:
 * @component:
 * @image:
 */
import { PersistenceV2 } from '@kit.ArkUI';
import { CommonHeader, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';

@ComponentV2
struct QRCodePage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.comp_background_gray')
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.qrcode'),
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Blank()

      QRCode(this.userInfo.id)
        .width(258)
        .height(258)
        .color($r('sys.color.comp_foreground_primary'))
        .backgroundColor($r('sys.color.background_primary'))
        .contentOpacity(1)
        .padding(25)

      Text($r('app.string.qrcode_desc'))
        .fontSize(12)
        .fontColor($r('app.color.color_66000000'))
        .margin({top: 20})

      Blank()
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}

@Builder
export function QRCodePageBuilder() {
  QRCodePage()
}
