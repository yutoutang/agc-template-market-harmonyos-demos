import { iData, routerStack, RouterMap, SimpleDialog } from 'lib_foundation';
import { promptAction } from '@kit.ArkUI';
import { NavTitleBar } from 'lib_widget';

@ComponentV2
export struct SettingPage {
  private logoutDialog: SimpleDialog = new SimpleDialog(this.getUIContext())
    .setMessage('退出登录')
    .onConfirm(() => {
      iData.local.userToken = '';
      iData.global.userInfo.reset();
      iData.global.isLogin = false;
      promptAction.showToast({ message: '已退出登录' });
      routerStack.pop();
    });

  public build(): void {
    NavDestination() {
      Column() {
        NavTitleBar({ title: '个人设置' })
        Scroll() {
          Column() {
            Column() {
              this.buildAgreementCard('隐私政策', 'resource://rawfile/static/html/privacy-policy.html');
              this.buildAgreementCard('用户协议', 'resource://rawfile/static/html/user-agreement.html');
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .padding({ left: 16, right: 16 })

            if (iData.global.isLogin) {
              Row() {
                Button() {
                  Text('退出登录')
                    .fontColor(Color.White)
                    .fontSize(16)
                    .fontWeight(500)
                }
                .width('100%')
                .height(40)
                .type(ButtonType.Normal)
                .backgroundColor($r('sys.color.mask_secondary'))
                .borderRadius(20)
                .onClick(() => this.logoutDialog.open())
              }
              .width('100%')
              .padding({ left: 28, right: 28 })
              .margin({ top: 12, bottom: 12 })
            }
          }
          .width('100%')
          .constraintSize({ minHeight: '100%' })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor('#FFF1F3F5')
    }
    .hideTitleBar(true)
  }

  @Builder
  private buildAgreementCard(label: string, url: string): void {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor('#E6000000')
      Image($r('app.media.ic_left_arrow'))
        .height(16)
        .objectFit(ImageFit.Contain)
        .rotate({ angle: 180 })
        .fillColor($r('sys.color.mask_tertiary'))
        .draggable(false)
    }
    .width('100%')
    .height(60)
    .borderRadius(16)
    .padding({ left: 18, right: 18 })
    .margin({ top: 12 })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .onClick(() => {
      const param: Record<string, string> = {
        'label': label,
        'url': url,
      };
      routerStack.pushPathByName(RouterMap.AGREEMENT, param);
    })
  }
}

@Builder
export function buildSettingPage() {
  SettingPage();
}
