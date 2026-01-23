
import { AppStorageV2, CustomContentDialog, window } from '@kit.ArkUI';
import {
  RouterMap,
  RouterModule,
  TopBar,
  UserInfo,
  MyScrollModifier,
} from 'commonlib'
import { ClearCacheItem } from '../views/ClearCacheItem';
import { UpdateVersionItem } from '../views/UpdateVersionItem';

@ComponentV2
export struct SetUpPage {
  @Local bottomHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号退出',
      contentBuilder: () => {
        this.disConnectContent();
      },
      buttons: [
        {
          value: '取消',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
          }
        },
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            if (this.loginUser.isLogin) {
              this.loginUser.isLogin = false
              this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
              RouterModule.pop()
            } else {
              this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
            }
          }
        }
      ],
    }),
  });
  @Builder
  disConnectContent() {
    Text('请确认是否退出账号')
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(14)
  }


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
          TopBar({ title: $r('app.string.setting') })
          Column() {
            Row() {
              Text('个人信息')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.PERSONAL_INFO_PAGE })
            })

            Divider()
              .margin({ top: 13, bottom: 13 })

            Row() {
              Text('保存设置')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.SAVESETTING_PAGE })
            })

            Divider()
              .margin({ top: 13, bottom: 13 })

            Row() {
              Text('隐私设置')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.PRIVACY_SET_PAGE })
            })

            Divider()
              .margin({ top: 13, bottom: 13 })

            //清除缓存
            ClearCacheItem()
          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding(12)
          .borderRadius(16)
          .margin({ left: 8, right: 8 ,bottom: 8})
          .alignItems(HorizontalAlign.Start)

          Column() {
            // 检查更新
            UpdateVersionItem()

            //关于我们
            Row() {
              Text('关于我们')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.ABOUT_PAGE })
            })

            Divider()
              .margin({ top: 13, bottom: 13 })

            Row() {
              Text('服务条款')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: RouterMap.TERMS_PAGE })
            })

          }
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .padding(12)
          .borderRadius(16)
          .margin({ left: 8, right: 8 })
          .alignItems(HorizontalAlign.Start)
        }.alignItems(HorizontalAlign.Start)

        this.logOutButton()
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .padding({ left: $r('app.float.vp_8'), right: $r('app.float.vp_8'), bottom: $r('app.float.vp_50') })
      .alignItems(HorizontalAlign.Start)
    } .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }

  @Builder
  logOutButton() {
    Column() {
      Button($r('app.string.log_out'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(20)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height($r('app.float.vp_40'))
        .padding({ top: $r('app.float.vp_9'), bottom: $r('app.float.vp_9') })
        .onClick(() => {
          if(this.loginUser.isLogin) {
            this.dialogController.open()
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '您还未登录', duration: 2000 });
          }
        })
    }
  }
}



@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
