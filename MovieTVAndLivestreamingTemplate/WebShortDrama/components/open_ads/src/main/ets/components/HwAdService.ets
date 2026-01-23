import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { AdComponent, advertising, identifier } from '@kit.AdsKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdStatus } from '../common/Constant';

@ComponentV2
export struct HwAdService {
  @Param adId: string = '';
  @Param closeCallBack: () => void = () => {
  };
  @Local oaid: string = '';
  @Local isShow: boolean = false;
  private ads: Array<advertising.Advertisement> = [];
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private isTimeOut: boolean = false;
  // 超时时间(单位毫秒)，开发者可根据实际情况修改
  private timeOutDuration: number = 1000;
  // 超时index
  private timeOutIndex: number = -1;
  private adDisplayOptions: advertising.AdDisplayOptions = {
    mute: true,
  };

  private async loadAd(adId: string): Promise<void> {
    // 广告配置参数
    const adOptions: advertising.AdOptions = {
      // 是否允许流量下载 0：不允许，1：允许，不设置以广告主设置为准
      allowMobileTraffic: 1,
      // 是否希望根据 COPPA 的规定将您的内容视为面向儿童的内容: -1: 默认值，不确定 0: 不希望 1: 希望
      tagForChildProtection: -1,
      // 是否希望按适合未达到法定承诺年龄的欧洲经济区 (EEA) 用户的方式处理该广告请求 -1: 默认值，不确定 0: 不希望 1: 希望
      tagForUnderAgeOfPromise: -1,
      // 设置广告内容分级上限 W: 3+,所有受众 PI: 7+,家长指导 J: 12+,青少年 A: 16+/18+,成人受众
      adContentClassification: 'A'
    };
    // 广告请求回调监听
    const adLoadListener: advertising.AdLoadListener = {
      // 广告请求失败回调
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, 'testTag', `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
        // this.getUIContext().getPromptAction().showToast({
        //   message: `Failed to load ad, errorCode is:  ${errorCode} , errorMsg is: ${errorMsg}`,
        //   duration: 1000,
        // });
      },
      // 广告请求成功回调
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        clearTimeout(this.timeOutIndex);
        if (this.isTimeOut) {
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in loading ad');
        this.isShow = true;
        this.ads = ads;
      }
    };
    // 创建AdLoader广告对象
    const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
    // 广告请求参数
    const adRequestParams: advertising.AdRequestParams = {
      // 广告位ID
      adId: adId,
      // 开屏广告类型
      adType: 1,
      // 请求的广告数量
      adCount: 2,
      // 开放匿名设备标识符
      oaid: await this.requestOAID(this.context)
    };
    // 调用广告请求接口
    adLoader.loadAd(adRequestParams, adOptions, adLoadListener);
    this.timeOutHandler();
  }

  private async requestOAID(context: Context): Promise<string | undefined> {
    // 向用户请求授权广告跨应用关联访问权限
    let isPermissionGranted: boolean = false;
    try {
      const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      const result: PermissionRequestResult =
        await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
      isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to request permission. Code is ${err.code}, message is ${err.message}`);
    }
    if (isPermissionGranted) {
      hilog.info(0x0000, 'testTag', 'Succeeded in requesting permission');
      try {
        const oaid = await identifier.getOAID();
        hilog.info(0x0000, 'testTag', 'Succeeded in getting OAID');
        return oaid;
      } catch (err) {
        hilog.error(0x0000, 'testTag', `Failed to get OAID. Code is ${err.code}, message is ${err.message}`);
      }
    } else {
      hilog.error(0x0000, 'testTag', 'Failed to request permission. User rejected');
    }
    return undefined;
  }

  private timeOutHandler(): void {
    this.isTimeOut = false;
    // 超时处理
    this.timeOutIndex = setTimeout(() => {
      this.isTimeOut = true;
      this.routeToHome();
      hilog.error(0x0000, 'testTag', 'Load ad time out');
    }, this.timeOutDuration);
  }

  private routeToHome(): void {
    // 开发者可根据项目实际情况修改超时之后要跳转的目标页面
    hilog.info(0x0000, 'testTag', 'routeToHome');
    this.closeCallBack()
  }

  // 半屏开屏广告
  @Builder
  private splashHalfScreen() {
    Column() {
      this.splashFullScreen('87%');
      Column() {
        Row() {
          Image($r('app.media.ic_launch'))
            .width(36)
            .height(36)
            .margin({ right: 8 });
          Text('课堂')
            .fontColor('#1A1A1A');
        }.margin({ bottom: 8 });

        Text('Copyright © 2022-2024 Huawei Technologies Co., Ltd.')
          .fontColor('#1A1A1A')
          .fontSize(10);
      }
      .height('10%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16 });
    }.height('100%');
  }

  // 全屏开屏广告
  @Builder
  private splashFullScreen(height: string) {
    AdComponent({
      ads: this.ads,
      displayOptions: this.adDisplayOptions,
      interactionListener: {
        onStatusChanged: (status: string) => {
          switch (status) {
            case AdStatus.AD_OPEN:
              hilog.info(0x0000, 'testTag', 'Status is onAdOpen');
              break;
            case AdStatus.AD_CLICKED:
              hilog.info(0x0000, 'testTag', 'Status is onAdClick');
              break;
            case AdStatus.AD_CLOSED:
              hilog.info(0x0000, 'testTag', 'Status is onAdClose');
              this.routeToHome();
              break;
          }
        }
      }
    })
      .zIndex(1)
      .width('100%')
      .height(height)
      .transition(TransitionEffect.OPACITY.animation({ duration: 1000, curve: Curve.Friction, delay: 200 }))
  }

  aboutToAppear(): void {
    this.loadAd(this.adId)
  }

  build() {
    if (this.isShow) {
      if (this.ads[0].isFullScreen) {
        this.splashFullScreen('100%');
      } else {
        this.splashHalfScreen();
      }
    }else {
      Column() {
        Image($r('app.media.launch')).width(192).height(192)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
  }
}
