import {
  Constants,
  HomePageRouter,
  LoadingDialogUtil,
  NavHeaderBar,
  RouterMap,
  RouterModule,
  StoreInfoModel,
  UserIconModel,
  UserInfoModel,
} from 'common/Index';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { AppStorageV2, PersistenceV2, promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { callTelSheetBuilder } from 'base_ui';
import * as API from '../api/Index';

@Builder
export function PersonalCenterPageBuilder() {
  PersonalCenterPage()
}

@ComponentV2
struct PersonalCenterPage {
  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($r('app.media.mask'))
          .width(Constants.FULL_SIZE)
          .height(274)
        Column() {
          NavHeaderBar({
            title: $r('app.string.personal_center'),
            hasBackButton: false,
            hasBgColor: false,
            isMainPage: true,
          })
          Scroll() {
            Column() {
              UserMsgCard().margin({ top: 10 })
              MyCenter()
              HelpCenter()
            }
          }.layoutWeight(1).scrollBar(BarState.Off).align(Alignment.Top).edgeEffect(EdgeEffect.Spring);
        }
        .alignItems(HorizontalAlign.Start)
        .width(Constants.FULL_SIZE)
        .padding({
          left: 12,
          right: 12,
        })
      }
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.background_secondary'))
    }.hideTitleBar(true)
  }
}

@ComponentV2
struct UserMsgCard {
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Local userIconInfo: UserIconModel = PersistenceV2.connect(UserIconModel, () => new UserIconModel())!;
  @Local isSaved: boolean = this.userIconInfo.isSaved

  @Computed
  get avatarUri(): ResourceStr {
    return this.isSaved ? `file://${getContext().filesDir}/${this.userIconInfo.userIconPath}` :
    $r('app.media.ic_default_hd')
  }

  build() {
    Row() {
      Row() {
        if (this.userInfoModel.isRelative) {
          FunctionalButton({
            params: {
              // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              // 调整Button样式
              styleOption: {
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .type(ButtonType.Normal)
                  .backgroundImage(this.avatarUri)
                  .backgroundImageSize(ImageSize.Cover)
                  .width(64)
                  .height(64)
                  .borderRadius(50)
                  .backgroundColor('#E5E5E5'),
              },
            },
            // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
            controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err,
              data) => {
              if (err) {
                // 错误日志处理
                hilog.error(0x0000, 'testTag', 'error： %{public}d %{public}s', err.code, err.message);
                return;
              }
              // 成功日志处理
              hilog.info(0x0000, 'testTag', 'succeeded in choosing avatar');
              let file: fs.File = null!;
              try {
                file = fs.openSync(data.avatarUri, fs.OpenMode.READ_ONLY)
                this.userIconInfo.userIconPath = `${util.generateRandomUUID(false)}.jpg`
                let imagePath = `${getContext().filesDir}/${this.userIconInfo.userIconPath}`
                fs.copyFileSync(file.fd, imagePath)
                this.isSaved = true
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                console.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
              } finally {
                fs.closeSync(file);
              }
            }),
          })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(64)
            .height(64)
            .borderRadius(50)
        }

        Column() {
          if (this.userInfoModel.isRelative) {
            Text(this.userInfoModel.userInfo.name)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Row() {
              Image($r('app.media.icon_phone')).width(16)
              Text(this.userInfoModel.getTel())
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.font_secondary'))
                .margin({ left: 2 })
            }.margin({ top: 12, left: 1 })
          } else {
            Text($r('app.string.no_relative')).fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
      }

      Row() {
        Row() {
          Image(this.userInfoModel.isRelative ? $r('app.media.ic_relatived') : $r('app.media.connect'))
            .width(12)
            .height(12)
            .margin({ right: 4 })
          Text(this.userInfoModel.isRelative ? $r('app.string.disassociate') : $r('app.string.associate_account'))
            .fontSize($r('sys.float.Body_S'))
            .fontColor(this.userInfoModel.isRelative ? $r('sys.color.font_on_primary') : $r('sys.color.multi_color_09'))
        }
        .padding({
          left: 10,
          right: 10,
          top: 6,
          bottom: 6,
        })
        .borderRadius(14)
        .backgroundColor(this.userInfoModel.isRelative ? $r('sys.color.multi_color_09') :
        $r('sys.color.background_secondary'))
        .onClick(() => {
          if (this.userInfoModel.isRelative) {
            this.cancelRelative()
          } else {
            this.getQuickLoginAnonymousPhone()
          }
        })
      }
      .height(Constants.FULL_SIZE)
      .alignItems(this.userInfoModel.isRelative ? VerticalAlign.Top : VerticalAlign.Center)

    }
    .width(Constants.FULL_SIZE)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(112)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 16,
      right: 16,
      top: 24,
      bottom: 24,
    })
  }

  getQuickLoginAnonymousPhone() {
    LoadingDialogUtil.openLoadingDialog()
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    authRequest.scopes = ['phone'];
    // 获取code需传如下permission
    authRequest.permissions = ['serviceauthcode'];
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    authRequest.forceAuthorization = true;
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest).then((data) => {
        const authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        const state = authorizationWithHuaweiIDResponse.state;
        if (state !== undefined && authRequest.state !== state) {
          hilog.error(0x0000, 'testTag', `Failed to authorize. The state is different, response state: ${state}`);
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
        const authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        const code = authorizationWithHuaweiIDCredential.authorizationCode;
        this.userInfoModel.authCode = code ?? ''
        // 开发者处理code
        if (code) {
          this.login(code)
        } else {
          promptAction.showToast({ message: '账号关联失败' })
          LoadingDialogUtil.close()
        }
      }).catch((err: BusinessError<Object>) => {
        // 错误日志处理。todo 未获取权限时模拟登录成功
        LoadingDialogUtil.close()
        this.bindPhoneMock()
      });
    } catch (error) {
      this.dealAllError(error);
      LoadingDialogUtil.close()
    }

  }

  cancelRelative() {
    // 创建取消授权请求，并设置参数
    const cancelRequest = new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
    cancelRequest.state = util.generateRandomUUID(); // 建议使用generateRandomUUID生成state

    // 执行取消授权请求，并处理结果
    try {
      const controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(cancelRequest, (error: BusinessError<Object>, data) => {
        // todo 这里可以补充关联失败异常场景，模板为了体验流程暂未处理
        hilog.info(0x0000, 'testTag', 'Succeeded in canceling.');
        API.getCancelLogin().then(() => {
          this.userInfoModel.isRelative = false
          this.userInfoModel.userInfo.userTel = ''
        })
      });
    } catch (error) {
      this.dealAllError(error);
    }
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    promptAction.showToast({ message: '账号关联失败' })
  }

  login(code: string) {
    API.getOpenLoginHm(encodeURIComponent(code)).then((res) => {
      let tel = res.userTel ?? ''
      this.userInfoModel.userInfo.userTel =
        `${tel.substring(0, tel.length - 8)}****${tel.substring(tel.length - 4)}`
      this.userInfoModel.isRelative = true
      if (!code) {
        promptAction.showToast({ message: '手机号绑定成功！当前手机号为mock数据，非华为账号真实手机号' });
      }
    }).catch(() => {
      promptAction.showToast({ message: '账号关联失败' })
    }).finally(() => {
      LoadingDialogUtil.close()
    })
  }

  async bindPhoneMock() {
    RouterModule.push<Record<string, string>>(RouterMap.CONFIRM_DIALOG,
      { 'title': '提示', 'message': '元服务未获取phone权限或用户授权，点击确定将根据openId创建一个mock账号。' },
      async (value) => {
        const result = value.result as Record<string, boolean>;
        if (result.param) {
          this.login('')
        }
      });
  }
}

@ComponentV2
struct MyCenter {
  @Consumer('currentIndex') currentIndex: number = 0
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!

  @Styles
  cardStyle(){
    .layoutWeight(1)
    .padding({
      left: 18,
      right: 18,
      top: 15,
      bottom: 15,
    })
    .borderRadius(8)
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      Row({ space: 16 }) {
        Row() {
          Column() {
            Text($r('app.string.wallet')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.yuan_params',
              `${this.userInfoModel.isRelative ? this.userInfoModel.userInfo.wallet : 0}`))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.multi_color_09')).margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.wallet')).width(32)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .cardStyle()
        .onClick(() => {
          if (!this.userInfoModel.isRelative) {
            promptAction.showToast({ message: '请先关联账号~' })
            return
          }
          RouterModule.push(RouterMap.MY_WALLET_PAGE, null, (popInfo: PopInfo) => {
            API.getUserInfo().then(res => {
              this.userInfoModel.userInfo.wallet = res.wallet
            })
          })
        })

        Row() {

          Column() {
            Text($r('app.string.my_coupon')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.my_coupon_desc'))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.coupon')).width(32)
        }
        .cardStyle()
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          RouterModule.push(RouterMap.MY_COUPONS_PAGE, null, (popInfo: PopInfo) => {
            let result = popInfo.result as HomePageRouter
            this.currentIndex = result.index
          })
        })

      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 16 }) {
        Row() {
          Column() {
            Text($r('app.string.points')).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'))
            Text($r('app.string.points_param',
              `${this.userInfoModel.isRelative ? this.userInfoModel.userInfo.totalScore : 0}`))
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.multi_color_09')).margin({ top: 4 })
          }.alignItems(HorizontalAlign.Start)

          Image($r('app.media.ic_score_card')).width(32)
        }
        .cardStyle()
        .justifyContent(FlexAlign.SpaceBetween)

        Row().layoutWeight(1)
      }.justifyContent(FlexAlign.Start).margin({ top: 12 })

    }
    .width(Constants.FULL_SIZE)
    .margin({ top: 12 })
  }
}

@ComponentV2
struct HelpCenter {
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local callTelSheet: boolean = false

  build() {
    Column() {
      Text($r('app.string.help_center'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .margin({ left: 12 })
      Column() {
        Row() {
          Row() {
            Image($r('app.media.question')).width(16).height(16)
            Text($r('app.string.faqs'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width(Constants.FULL_SIZE)

        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          RouterModule.push(RouterMap.FREQUENT_QUESTION_PAGE)
        })

        Divider().margin({ left: 28, top: 12, bottom: 12 })
        Row() {
          Row() {
            Image($r('app.media.telephone')).width(16).height(16)
            Text($r('app.string.customer_phone'))
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .margin({ left: 12 })
          }

          Image($r('app.media.right_arrow')).width(16).height(16)
        }
        .width(Constants.FULL_SIZE)
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          // 拨打商家电话
          this.callTelSheet = true
        })
        .bindSheet($$this.callTelSheet, callTelSheetBuilder(this.storeModel.storeInfo.tel || '', () => {
          this.callTelSheet = false
        }), {
          height: 309,
          blurStyle: BlurStyle.Thick,
          showClose: false,
        });
      }
      .padding(12)
      .margin({ top: 12 })
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
    }.margin({ top: 16 }).alignItems(HorizontalAlign.Start)
  }
}