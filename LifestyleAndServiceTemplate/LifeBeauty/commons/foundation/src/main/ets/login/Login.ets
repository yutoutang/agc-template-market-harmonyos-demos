import { util } from '@kit.ArkTS';
import { PersistenceV2 } from '@kit.ArkUI';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import {
  bindMobileWithCode,
  confirmRebindMobileWithSecret,
  getUserInfo,
  loginWithHuaweiID,
  unbindMobile,
} from '../http/ApiManage';
import { DialogRebindBuilder, RebindParams } from '../uicomponent/DialogReBind';
import { PopViewUtils } from '../utils/PopViewUtils';
import { CurAppInfo } from '../constants/AppConstant';
import { GetUserInfoResp } from '../model/Model';
import { LoadingDialogUtil } from '../utils/LoadingUtils';
import { WindowUtil } from '../utils/WindowUtil';

const TAG = '[Login]';

/**
 * 获取并设置用户信息
 */
export const queryUserInfo = async () => {
  const storageUserInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  try {
    const userInfo = await getUserInfo(storageUserInfo.isBindMobile);
    storageUserInfo.userId = userInfo.userId;
    storageUserInfo.nickName = userInfo.nickName;
    storageUserInfo.avatar = userInfo.avatar;
    storageUserInfo.mobile = userInfo.mobile;
    storageUserInfo.createdTime = userInfo.createdTime;
    storageUserInfo.updatedTime = userInfo.updatedTime;
    storageUserInfo.memberId = userInfo.memberId;
    storageUserInfo.points = userInfo.points;
  } catch (e) {
    Logger.error(TAG, 'queryUserInfo error:' + JSON.stringify(e));
  }
};

/**
 * 静默登录
 */
export const silentLogin = async (): Promise<Boolean> => {
  try {
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    loginRequest.forceLogin = false;
    let controller = new authentication.AuthenticationController();
    return controller.executeRequest(loginRequest).then(async (data) => {
      const loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
      const loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data;
      Logger.info(TAG, `loginResponse=${JSON.stringify(loginWithHuaweiIDCredential)}`);

      const resp = await loginWithHuaweiID({
        clientId: CurAppInfo.CLIENT_ID,
        code: loginWithHuaweiIDCredential?.authorizationCode || '',
        idToken: loginWithHuaweiIDCredential?.idToken || '',
        openId: loginWithHuaweiIDCredential?.openID || '',
        unionId: loginWithHuaweiIDCredential?.unionID || '',
      });
      Logger.info(TAG, 'loginWithHuaweiID success, token:' + resp.token);
      AppStorage.setOrCreate('Token', resp.token);
      await queryUserInfo();
      return true;
    }).catch(async (error: BusinessError) => {
      Logger.error(TAG, 'LoginWithHuaweiID executeRequest error: ' + JSON.stringify(error));
      // 为了不阻塞模板体验，不做失败拦截
      await queryUserInfo();
      return true;
    });
  } catch (e) {
    ToastDialog.showToast({ message: '华为账号登录异常，请稍后重试~' });
    return false;
  }
}

/**
 * 取消授权，每次申请关联手机号都要拉起面板
 */
export function cancelAuthorization() {
  const cancelRequest: authentication.CancelAuthorizationRequest =
    new authentication.HuaweiIDProvider().createCancelAuthorizationRequest();
  cancelRequest.state = util.generateRandomUUID();
  try {
    const controller: authentication.AuthenticationController = new authentication.AuthenticationController();
    controller.executeRequest(cancelRequest).then((data: authentication.AuthenticationResponse) => {
      const cancelAuthorizationResponse = data as authentication.CancelAuthorizationResponse;
      const state: string = cancelAuthorizationResponse.state!;
      if (cancelRequest.state !== state) {
        Logger.error(TAG, 'Failed to cancel. The state is different');
        return;
      }
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
    })
  } catch (err) {
    Logger.error(TAG, `Failed to cancel. errCode is ${err.code}, errMessage is ${err.message}`);
  }
}

/**
 * 关联手机号
 */
export const bindPhone = async (code: string | undefined, onBind?: () => void) => {
  if (!code) {
    return;
  }
  try {
    const resp = await bindMobileWithCode(code);

    // 涉及确认换绑
    if (resp.rebindSecret) {
      closeLoading();
      const rebindPhone = async () => {
        try {
          openLoading();
          await confirmRebindMobileWithSecret(resp.rebindSecret);
          if (onBind) {
            onBind();
          }
          setBindMobileSuccess();
          cancelAuthorization();
          queryUserInfo();
          closeLoading();
        } catch (e) {
          closeLoading();
          cancelAuthorization();
          Logger.error(TAG, 'ReBindPhone error:' + JSON.stringify(e));
          ToastDialog.showToast({ message: '关联手机号失败，请稍后重试~' });
        }
      };

      const cancelCB = () => {
        cancelAuthorization();
      };

      PopViewUtils.showPopView<RebindParams>(wrapBuilder(DialogRebindBuilder),
        new RebindParams(rebindPhone, cancelCB),
        { alignment: DialogAlignment.Center });
    } else {
      if (onBind) {
        onBind();
      }
      setBindMobileSuccess();
      cancelAuthorization();
      queryUserInfo();
    }
  } catch (e) {
    cancelAuthorization();
    Logger.error(TAG, 'BindPhone error:' + JSON.stringify(e));
    ToastDialog.showToast({ message: '关联手机号失败，请稍后重试~' });
  } finally {
    LoadingDialogUtil.close();
  }
};

/**
 * 解绑手机号
 */
export const unbindPhone = () => {
  try {
    UIDialog.open({
      titleOptions:{
        primaryTitle: '账号解除关联',
      },
      contentOptions: {
        content: '请确认是否解除账号关联？',
        contentTextAlign: TextAlign.Center,
      },
      showConfirmButton: true,
      showCancelButton: true,
      confirmButtonOptions: {
        buttonFontColor: '#E64566'
      },
      cancelButtonOptions: {
        buttonFontColor: $r('sys.color.font_primary')
      },
      onConfirm: async () => {
        await UIDialog.closeLast();
        openLoading();
        await unbindMobile();
        const storageUserInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
        storageUserInfo.isBindMobile = false;
        queryUserInfo();
      }
    })
  } catch (e) {
    Logger.error(TAG, 'unbindPhone error: ' + JSON.stringify(e));
    ToastDialog.showToast({ message: '解绑手机号失败，请稍后重试~' });
  }
};


/**
 * 获取
 */
export const onGetPhoneNumberFail = (callback?: () => void) => {
  UIDialog.open({
    titleOptions: {
      primaryTitle: '提示',
    },
    contentOptions: {
      content: '元服务未获取phone权限或用户授权，点击确定创建一个mock账号。',
    },
    showConfirmButton: true,
    showCancelButton: true,
    cancelButtonOptions: {
      buttonFontColor: $r('sys.color.brand')
    },
    onCancel: () => {
      closeLoading();
      LoadingDialogUtil.close();
      UIDialog.closeLast();
    },
    onConfirm: () => {
      UIDialog.closeLast();
      bindPhone('123', callback);
    }
  })
}

/**
 * 登录按钮样式1
 */
@ComponentV2
export struct LoginButton {
  @Param btnSize: SizeOptions = {width: 72, height: 28};
  @Param isEffect: boolean = true;
  @Param showLoginBtn: boolean = true;
  @BuilderParam contentView: CustomBuilder;
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    LoadingDialogUtil.setUIContext(WindowUtil.uiContext);
  }

  build() {
    Stack() {
      if (this.contentView) {
        this.contentView()
      }
      this.loginBtnBuilder()
    }
  }

  @Builder
  loginBtnBuilder() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: ' ',
          styleOption: {
            plain: true,
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .type(ButtonType.Capsule)
              .size(this.btnSize)
              .fontSize(14)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.Transparent)
              .stateEffect(this.isEffect)
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            openLoading()
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      })
        .id('phoneFunctionalButtonId1')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
    .visibility(this.showLoginBtn ? Visibility.Visible : Visibility.None)
  }
}

/**
 * 登录按钮样式2
 */
@ComponentV2
export struct LoginButtonType2 {
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    LoadingDialogUtil.setUIContext(WindowUtil.uiContext);
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.good_card_purchase_btn'),
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontWeight(500)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 28, width: 72 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      })
        .id('phoneFunctionalButtonId2')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
  }
}

/**
 * 登录按钮样式3
 */
@ComponentV2
export struct LoginButtonType3 {
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    LoadingDialogUtil.setUIContext(WindowUtil.uiContext);
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.book_good_btn'),
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .width('100%')
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color')),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      })
        .id('phoneFunctionalButtonId3')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
  }
}


/**
 * 登录按钮样式4
 */
@ComponentV2
export struct LoginButtonType4 {
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    LoadingDialogUtil.setUIContext(WindowUtil.uiContext);
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '购买',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 28, width: 72 }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      })
        .id('phoneFunctionalButtonId4')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
  }
}

/**
 * 登录按钮样式5
 */
@ComponentV2
export struct LoginButtonType5 {
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    LoadingDialogUtil.setUIContext(WindowUtil.uiContext);
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '立即购买',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 40, width: '100%' }),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((err, data) => {
            if (err) {
              Logger.error(TAG, 'fail to get phone number, error: ' + JSON.stringify(err));
              onGetPhoneNumberFail(this.onBind);
              return;
            }
            Logger.info(TAG, 'succeeded in getting phone number. data.code = ' + data.code);
            bindPhone(data.code, this.onBind);
          }),
      })
        .id('phoneFunctionalButtonId5')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
  }
}

@Builder
function loadingBuilderView(param: object) {
  Column() {
    LoadingProgress()
      .width(40)
      .height(40)
      .color($r('sys.color.icon_on_primary'))
  }
  .width(80)
  .height(80)
  .borderRadius(12)
  .justifyContent(FlexAlign.Center)
  .backgroundColor('#99000000')
}

// loading
export function openLoading() {
  PopViewUtils.showPopView(wrapBuilder(loadingBuilderView), [],
    {
      alignment: DialogAlignment.Center,
      autoCancel: false,
      maskColor: Color.Transparent
    });
}

// close loading
export function closeLoading() {
  PopViewUtils.closePopView()
}

// 绑定手机号成功
function setBindMobileSuccess() {
  const storageUserInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  storageUserInfo.isBindMobile = true;
}