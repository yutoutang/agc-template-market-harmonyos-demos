import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { authentication } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import {
  bindMobileWithCode,
  confirmRebindMobileWithSecret,
  getUserInfo,
  loginWithHuaweiID,
  unbindMobile,
} from '../http/ApiManage';
import { DialogRebindBuilder, RebindParams } from '../uicomponent/DialogReBind';
import { PopViewUtils } from '../utils/PopViewUtils';
import { CancelBindParams, DialogCancelBindBuilder } from '../uicomponent/DialogCancelBind';
import { CurAppInfo } from '../constants/AppConstant';
import { AppStorageBank } from '../model/Model';
import { getUIContext, LoadingDialogUtil } from '../utils/LoadingUtils';

const TAG = '[Login]';

/**
 * 获取并设置用户信息
 */
export const queryUserInfo = async () => {
  try {
    const userInfo = await getUserInfo();
    AppStorageBank.updateUserInfo(userInfo);
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
    promptAction.showToast({ message: $r('app.string.login_in_error') });
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
      const rebindPhone = async () => {
        try {
          await confirmRebindMobileWithSecret(resp.rebindSecret);
          if (onBind) {
            onBind();
          }
          cancelAuthorization();
          queryUserInfo();
        } catch (e) {
          cancelAuthorization();
          Logger.error(TAG, 'ReBindPhone error:' + JSON.stringify(e));
          promptAction.showToast({ message: $r('app.string.bind_phone_error') });
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
      cancelAuthorization();
      queryUserInfo();
    }
  } catch (e) {
    cancelAuthorization();
    Logger.error(TAG, 'BindPhone error:' + JSON.stringify(e));
    promptAction.showToast({ message: $r('app.string.bind_phone_error') });
  } finally {
    LoadingDialogUtil.close();
  }
};

/**
 * 解绑手机号
 */
export const unbindPhone = () => {
  try {
    const unbind = async () => {
      await unbindMobile();
      queryUserInfo();
    };
    PopViewUtils.showPopView<CancelBindParams>(wrapBuilder(DialogCancelBindBuilder),
      new CancelBindParams(unbind),
      { alignment: DialogAlignment.Center });
  } catch (e) {
    Logger.error(TAG, 'unbindPhone error: ' + JSON.stringify(e));
    promptAction.showToast({ message: $r('app.string.unbind_phone_error') });
  }
};


/**
 * 获取
 */
export const onGetPhoneNumberFail = (callback?: () => void) => {
  promptAction.showDialog({
    title: '提示',
    message: '元服务未获取phone权限或用户授权，点击确定创建一个mock账号。',
    buttons: [
      {
        text: '取消',
        color: $r('sys.color.brand'),
      },
      {
        text: '确定',
        color: $r('sys.color.brand'),
      },
    ],
  }, (err, data) => {
    if (err) {
      LoadingDialogUtil.close();
      return;
    }
    if (data.index === 1) {
      bindPhone('123', callback);
    } else {
      LoadingDialogUtil.close();
    }
  });
}

/**
 * 登录按钮样式1
 */
@ComponentV2
export struct LoginButton {
  @Event onBind?: () => void = () => {
  };

  aboutToAppear(): void {
    getUIContext().then((uiContext: UIContext) => {
      LoadingDialogUtil.setUIContext(uiContext);
    })
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.bind_phone_btn'),
          styleOption: {
            plain: true,
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .type(ButtonType.Normal)
              .size({ height: 16 })
              .borderRadius(0)
              .padding(0)
              .fontSize(12)
              .fontColor(Color.Black)
              .fontWeight(FontWeight.Medium)
              .backgroundColor(Color.Transparent)
              .borderWidth({ bottom: 1 }),
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
        .id('phoneFunctionalButtonId1')
        .onClick(() => {
          LoadingDialogUtil.openLoadingDialog();
        })
    }
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
    getUIContext().then((uiContext: UIContext) => {
      LoadingDialogUtil.setUIContext(uiContext);
    })
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: $r('app.string.good_card_appoint_btn'),
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
    getUIContext().then((uiContext: UIContext) => {
      LoadingDialogUtil.setUIContext(uiContext);
    })
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
    getUIContext().then((uiContext: UIContext) => {
      LoadingDialogUtil.setUIContext(uiContext);
    })
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '抢购',
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
    getUIContext().then((uiContext: UIContext) => {
      LoadingDialogUtil.setUIContext(uiContext);
    })
  }

  build() {
    Row() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '立即抢购',
          styleOption: {
            styleConfig: new functionalButtonComponentManager
              .ButtonConfig()
              .fontSize(14)
              .fontColor($r('app.color.common_fg_white'))
              .backgroundColor($r('app.color.common_theme_color'))
              .size({ height: 40, width: 120 }),
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