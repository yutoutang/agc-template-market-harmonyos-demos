import { AppStorageV2, CustomContentDialog, router } from '@kit.ArkUI';
import { AccountUtil, AvoidArea, CommonModel ,LeftReturnComponent ,TitleBar } from '@ohos_agcit/common_component';
import { CommonConstants } from '@ohos_agcit/common_component';

@Builder
export function PersonalSettingBuilder() {
  PersonalSetting();
}

@Entry
@ComponentV2
struct PersonalSetting {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local isShow: boolean = false;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  vm: CommonModel = CommonModel.instance;

  // 退出登录对话框
  logOutDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '账号退出登录',
      contentBuilder: () => {
        this.logOutContent();
      },
      buttons: [
        {
          value: $r('app.string.cancel'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.logOutDialogController.close();
          },
        },
        {
          value: $r('app.string.confirm'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            AccountUtil.loginOut();
            router.back();
          },
        },
      ],
    }),
  });

  // 未登录提示弹窗内容
  @Builder
  notLoggedInContent() {
    Column() {
      Text('请先登录')
        .fontSize(14)
        .margin({ top: 6 });
    }
    .width('100%')
  }

  // 未登录提示弹窗控制器
  notLoggedInDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '当前未登录',
      contentBuilder: () => {
        this.notLoggedInContent();
      },
      buttons: [
        {
          value: '确定',
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action: () => {
            this.notLoggedInDialogController.close();
          }
        }
      ]
    })
  });

  // 退出登陆
  @Builder
  logOutContent() {
    Column() {
      Row() {
        Text('请确认是否退出当前账户？')
          .fontSize(14);
      };
    }
    .width('100%')
    .borderRadius(16)
    .margin({
      left: '4%',
      right: '4%',
      bottom: 5,
    });
  }

  build() {
    Column() {
      Row() {
        LeftReturnComponent()
          .onClick(() => {
            router.back();
          });
        TitleBar({ text: '设置' });
      }
      .height(56)
      .alignItems(VerticalAlign.Center)
      .width(CommonConstants.FULL_WIDTH)
      .alignItems(VerticalAlign.Center);

      Blank()
        .height(10)

      // 个人信息模块
      Row() {
        Text('个人信息')
          .fontSize(16)
          .margin({ left: 18})

        Blank()
        Image($r('app.media.ic_right_arrow_lined'))
          .width(7)
          .height(14)
          .fillColor('rgba(0,0,0,0.2)')
          .margin({ right: 12 })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .height(56)
      .onClick(() => {
        if (!AccountUtil.getAccountInfo().idToken) {
          // 未登录时显示提示
          this.notLoggedInDialogController.open();
        } else {
          router.pushUrl({
            url: 'pages/mine/PersonalInfo',
            params: {}
          }, router.RouterMode.Standard);
        }
      })

      // 隐私政策和用户协议模块
      Column() {
        // 隐私政策
        Row() {
          Text('隐私政策')
            .fontSize(16)
            .margin({ left: 18 })

          Blank()
          Image($r('app.media.ic_right_arrow_lined'))
            .width(7)
            .height(14)
            .fillColor('rgba(0,0,0,0.2)')
            .margin({ right: 12 })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/mine/PrivacyAgreement',
            params: {}
          }, router.RouterMode.Standard);
        })

        // 分割线
        Divider()
          .strokeWidth('1px')
          .color($r('sys.color.comp_divider'))
          .margin({ left: 18, right: 18 })

        // 用户协议
        Row() {
          Text('用户协议')
            .fontSize(16)
            .margin({ left: 18 })

          Blank()
          Image($r('app.media.ic_right_arrow_lined'))
            .width(7)
            .height(14)
            .fillColor('rgba(0,0,0,0.2)')
            .margin({ right: 12 })
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/mine/PrivacyAgreement',
            params: {}
          }, router.RouterMode.Standard);
        })
      }
      .width('100%')
      .height(113)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .margin({ top: 12 })

      Blank()

      Row() {
        Text($r('app.string.log_out'))
          .fontSize(16)
          .fontColor('#376BFC')
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(40)
      .borderRadius(20)
      .backgroundColor('#E0E0E0')
      .margin({
        left: 28,
        right: 28,
        bottom: 50
      })
      .onClick(() => {
        if (!AccountUtil.getAccountInfo().idToken) {
          // 未登录时显示提示
          this.notLoggedInDialogController.open();
        } else {
          // 已登录时显示退出确认
          this.logOutDialogController.open();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({
      top: px2vp(this.avoidArea.topRectHeight),
      left: '4%',
      right: '4%',
    });
  }
}


