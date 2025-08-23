import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { AppStorageV2 } from '@kit.ArkUI'
import { getDataFromJSON, GlobalState, RouteEntryVM, UserInfoModel } from 'common'
import { PersonalSet } from '../model/PersonalSet'


@Builder
export function PersonalSettingBuilder() {
  PersonalSetting()
}

@ComponentV2
export struct PersonalSetting {
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'UserInfoModel', () => new UserInfoModel())!
  @Local personalSetItems: Array<PersonalSet> = []
  vm: RouteEntryVM = RouteEntryVM.instance;
  @Local appCache: number = 100.3
  @Local isShow: Boolean = false;
  @Local notifyToggle: boolean = false;
  @Local quickLoginAnonymousPhone: string = this.userInfo.phoneNumber; // 获取匿名手机号
  domainId: number = 0x0000;
  logTag: string = 'QuickLoginButtonComponent';
  @Local nickName: string = ''
  @Local isNickNameShow: Boolean = false;

  async aboutToAppear(): Promise<void> {
    this.initDataSource()
    let data: boolean = await notificationManager.isNotificationEnabled()
    this.notifyToggle = data
    this.getQuickLoginAnonymousPhone()
  }

  initDataSource() {
    this.personalSetItems = getDataFromJSON<PersonalSet>('PersonalCenter_PersonalSetting.json', this);
  }

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(this.domainId, this.logTag,
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    //(权限名称为：quickLoginMobilePhone),后续才能获取匿名手机号数据
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数只能设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;
        if (anonymousPhone) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in authentication.');
          this.quickLoginAnonymousPhone = anonymousPhone;
          return;
        }
        hilog.info(this.domainId, this.logTag, 'Succeeded in authentication. AnonymousPhone is empty.');
        // 未获取到匿名手机号需要跳转到应用自定义的登录页面
      }).catch((error: BusinessError) => {
        this.dealAllError(error);
      })
    } catch (error) {
      this.dealAllError(error);
    }
  }

  @Builder
  myNameBuilder() {
    Column() {
      TextInput({ placeholder: '请输入您的名称', text: $$this.nickName })
        .caretColor($r('app.color.system_color_green'))
        .fontSize(14)
        .fontWeight(FontWeight.Regular)
        .width('90%')
        .placeholderFont({ size: $r('sys.float.Body_L') })
        .backgroundColor($r('sys.color.white'))
        .margin({ bottom: 246 })
        .maxLength(7)
      Button('确定')
        .height(40)
        .width('80%')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.system_color_green'))
        .onClick(() => {
          this.userInfo.nickName = this.nickName
          this.isNickNameShow = false;
      })
    }
    .width('100%')
  }

  @Builder
  buildFaceView() {
    Row() {
      Text('头像')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
      Row() {
        FunctionalButton({
          params: {
            // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
            openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
            label: '',
            // 调整Button样式
            styleOption: {
              styleConfig: new functionalButtonComponentManager.ButtonConfig()
                .type(ButtonType.Normal)
                .backgroundImage(this.userInfo.avatarUri)
                .backgroundImageSize(ImageSize.Cover)
                .width(40)
                .height(40)
                .borderRadius($r('sys.float.corner_radius_level10'))
                .backgroundColor($r('sys.color.white'))
            },
          },
          // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
          controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
            if (err) {
              // 错误日志处理
              hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
              return;
            }
            // 成功日志处理
            hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
            this.userInfo.avatarUri = data.avatarUri!;
          })
        })
      }

    }
    .padding(12)
    .width('90%')
    .backgroundColor($r('sys.color.white'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 12, bottom: 12 })
  }

  @Builder
  buildPersonalInfo() {
    Column() {
      Row() {
        Text('昵称')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Row() {
          Text(this.userInfo.nickName)
          Image($r('app.media.ic_public_brush'))
            .height(24)
            .width(24)
            .margin({ left: 4 })
        }
        .onClick(() => {
          this.isNickNameShow = true
        })
        .bindSheet($$this.isNickNameShow, this.myNameBuilder(), {
          height: 418,
          backgroundColor: '#f1f3f5',
          showClose: false,
          preferType: SheetType.CENTER,
          title: { title: '设置昵称' },
        })

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .margin({ top: 13, bottom: 16 })
        .strokeWidth('1px').color($r('sys.color.ohos_id_color_list_separator'))

      Row() {
        Text('电话')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Row() {
          Text(this.quickLoginAnonymousPhone)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
        }
        .margin({ right: 4 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('90%')
    .padding({
      left: 12,
      right: 12,
      top: 17,
      bottom: 17
    })
    .backgroundColor($r('sys.color.white'))
    .backgroundColor($r('sys.color.white'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.buildFaceView()
          this.buildPersonalInfo()
        }
        .width('100%')
        .height('100%')
        .align(Alignment.TopStart)
        .backgroundImageSize(ImageSize.Auto)
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#F5F5F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title('个人设置')
  }
}