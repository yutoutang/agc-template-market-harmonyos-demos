import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, bundleManager, common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { site } from '@kit.MapKit';
import { paymentService } from '@kit.PaymentKit';
import { Logger } from './Logger';
import { PopViewUtils } from './PopViewUtils';
import {
  NoticeDialogBuilder,
  CommonDialogParams,
  ICommonDialogParams,
  ConfirmDialogBuilder,
} from '../uicomponent/NoticeDialog';
import { fullLoading, FullLoadingParam } from '../uicomponent/UILoading';

const TAG = '[Utils]';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 对象赋值
   * @param target
   * @param source
   * @returns
   */
  static assign(target: Object, ...source: Object[]) {
    for (let s of source) {
      for (let key of Object.keys(s)) {
        const value = Reflect.get(s, key) as Object;
        Reflect.set(target, key, value)
      }
    }
  }

  /**
   * 时间戳转换年月日xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 时间戳转换成年月日时分秒xxxx-xx-xx xx:xx:xx
   * @param datetime
   */
  static formatDateTime(datetime?: number): string {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() +
      1)}-${CommonUtils.padZero(date.getDate())} ${CommonUtils.padZero(date.getHours())}:${CommonUtils.padZero(date.getMinutes())}:${CommonUtils.padZero(date.getSeconds())}`;
  }

  /**
   * 不足的补零
   * @param input
   * @returns
   */
  static padZero(input: number): string {
    return input.toString().padStart(2, '0');
  }

  /**
   * 金钱取整策略
   * @param cash
   */
  static handleCash(cash: number): string {
    try {
      // 整数直接返回
      if (cash % 1 === 0) {
        return cash.toString();
      }

      // 小数保留2位小数
      return cash.toFixed(2);
    } catch (e) {
      Logger.error(TAG, 'handleCash fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 打开通用提示弹窗
   * @param title
   * @param btnLabel
   * @param confirm
   */
  static openNoticeDialog(param: ICommonDialogParams) {
    PopViewUtils.showPopView<CommonDialogParams>(wrapBuilder(NoticeDialogBuilder),
      new CommonDialogParams(param),
      { alignment: DialogAlignment.Center, autoCancel: true });
  };

  /**
   * 打开通用确认弹窗
   * @param param
   */
  static openConfirmDialog(param: ICommonDialogParams) {
    PopViewUtils.showPopView<CommonDialogParams>(wrapBuilder(ConfirmDialogBuilder),
      new CommonDialogParams(param),
      { alignment: DialogAlignment.Center, autoCancel: true });
  };

  /**
   * 打开loading
   * @param param
   */
  static showLoading() {
    PopViewUtils.showPopView<FullLoadingParam>(wrapBuilder(fullLoading),
      new FullLoadingParam(),
      { alignment: DialogAlignment.Center, autoCancel: false });
  };

  /**
   * 关闭loading弹窗
   */
  static hideLoading() {
    PopViewUtils.closePopView();
  }

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string): string {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('mockImage://')[1];
      const prefixUrl: string = 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/household%2F';
      return `${prefixUrl}${resourceName}`;
    }
    // resources下的资源通过resourceImage://xxx表达
    if (url.startsWith('resourceImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(TAG, `get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return url
  };
}

/**
 * 系统Utils
 */
export class SystemSceneUtils {
  static isApplyLocPermAgain: boolean = false;
  static context: Context = getContext() as common.UIAbilityContext;

  /**
   * 检查用户是否授权
   * @param permission
   * @returns
   */
  static async checkPermissionGrant(permission: Permissions): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    // 获取应用程序的accessTokenID
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      tokenId = bundleInfo.appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  }

  /**
   * 向用户申请位置权限
   * @returns
   */
  static async applyLocationPermission(): Promise<boolean> {
    const permissions: Permissions[] = [
      'ohos.permission.APPROXIMATELY_LOCATION',
    ];

    const isGrantedAppLo = await SystemSceneUtils.checkPermissionGrant(permissions[0]);

    if (isGrantedAppLo) {
      Logger.info(TAG, 'already granted location and approximate location permissions')
      return true;
    }
    if (!SystemSceneUtils.context) {
      SystemSceneUtils.context = getContext() as common.UIAbilityContext;
    }
    // 向用户申请
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(SystemSceneUtils.context, permissions)
      .then(async (result: PermissionRequestResult) => {
        if (result.authResults.every(v => v === 0)) {
          return true;
        }
        // 二次向用户申请
        if (SystemSceneUtils.isApplyLocPermAgain) {
          const resp = await atManager.requestPermissionOnSetting(SystemSceneUtils.context, permissions);
          return resp.every(v => v === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
        }
        SystemSceneUtils.isApplyLocPermAgain = true;
        return false;
      });
  }

  /**
   * 获取当前所在城市位置
   * @returns
   */
  static async getCurrentCityInfo(): Promise<string> {
    try {
      const requestInfo: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        timeoutMs: 1000,
      };
      const currentLocation = await geoLocationManager.getCurrentLocation(requestInfo);

      const reverseGeoCodeReq: site.ReverseGeocodeParams = {
        location: currentLocation,
        language: 'zh_CN',
      };
      const reverseGeocodeResult = await site.reverseGeocode(reverseGeoCodeReq);
      Logger.info(TAG, 'reverseGeocodeResult=' + JSON.stringify(reverseGeocodeResult));
      return reverseGeocodeResult.addressComponent.city?.cityName ?? '';
    } catch (e) {
      Logger.error(TAG, 'getCurrentCityInfo fail, error: ' + JSON.stringify(e));
      return '';
    }
  }

  /**
   * 调用华为支付
   * @returns
   */
  static requestPaymentPromise(ignoreRequestPayment: boolean, context: common.UIAbilityContext): Promise<void> {
    if (ignoreRequestPayment) {
      return new Promise((resolve) => resolve());
    }
    // todo 补充订购信息
    const orderStr = '{}';
    return paymentService.requestPayment(context, orderStr)
      .then(() => {
        Logger.info(TAG, 'succeeded in paying');
      })
      .catch((error: BusinessError) => {
        Logger.error(TAG, `failed to pay, error.code: ${error.code}, error.message: ${error.message}`);
        promptAction.showToast({ message: '拉起支付失败' });
      });
  }
}
