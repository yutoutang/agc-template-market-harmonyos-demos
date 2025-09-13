/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BASE_URL } from '../constants/AppConstant';
import { Logger } from './Logger';
import { PopViewUtils } from './PopViewUtils';
import { NoticeDialog, NoticeDialogParams } from '../uicomponent/NoticeDialog';
import { ErrorCode } from '../constants/ErrorCode';

const TAG = '[CommonUtils]';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 时间戳转换成xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime?: number) {
    if (!datetime) {
      return '';
    }
    const date = new Date(datetime);
    return `${date.getFullYear()}-${CommonUtils.padZero(date.getMonth() + 1)}-${CommonUtils.padZero(date.getDate())}`;
  }

  /**
   * 时间戳转换成xxxx-xx-xx xx:xx:xx
   * @param datetime
   */
  static formatDateTime(datetime?: number) {
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
  static padZero(input: number) {
    return input.toString().padStart(2, '0');
  }

  /**
   * 金钱取整策略
   * @param cash
   */
  static handleCash(cash: number) {
    // 整数直接返回
    if (cash % 1 === 0) {
      return cash;
    }

    // 小数保留2位小数
    return cash.toFixed(2);
  }

  /**
   * 处理图片url
   * @param url
   * @returns
   */
  static handleImgUrl(url: string) {
    if (!url) {
      return '';
    }
    if (url.startsWith('https')) {
      return url;
    }

    // 处理mock图片资源
    if (url.startsWith('mockImage://')) {
      const resourceName = url.split('//')[1];
      try {
        const resource = getContext().resourceManager.getMediaBase64ByNameSync(resourceName);
        return resource;
      } catch (err) {
        Logger.error(TAG, `get image resource failed, ${err}, ${resourceName}`);
        return '';
      }
    }

    return `${BASE_URL}${url}`;
  };

  /**
   * 华为账号登录错误码处理
   * @param error
   */
  static showErrorMessage(error: BusinessError) {
    const userCanceled: number[] = [
      ErrorCode.SHIPPING_ADDRESS_USER_CANCELED, // The operation for obtaining the shipping address is canceled.
      ErrorCode.INVOICE_ASSISTANT_USER_CANCELED, // The operation for obtaining the invoice title is canceled.
      ErrorCode.AUTHENTICATION_USER_CANCELED, // Authorization revoking is performed.
      ErrorCode.EXTEND_SERVICE_USER_CANCELED,// The operation for obtaining the avatar is canceled.
    ];

    const networkError: number[] = [
      ErrorCode.SHIPPING_ADDRESS_NETWORK_ERROR,
      // A network exception occurred in the API for obtaining the shipping address.
      ErrorCode.AUTHENTICATION_NETWORK_ERROR, // A network exception occurs in the authorization API.
      ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR,
      // A network exception occurred in the API for obtaining the invoice title.
      ErrorCode.EXTEND_SERVICE_NETWORK_ERROR,// A network exception occurred in the API for obtaining the avatar.
    ];
    Logger.error(TAG, `Failed to obtain data. BusinessError errCode: ${error.code}, Message: ${error.message}`);

    // Network exception.
    if (networkError.includes(error.code)) {
      if (error.code === ErrorCode.INVOICE_ASSISTANT_NETWORK_ERROR) {
        return;
      }
      AlertDialog.show({
        message: $r('app.string.hwid_no_internet_connect'),
        offset: { dx: 0, dy: -12 },
        alignment: DialogAlignment.Center,
        autoCancel: false,
        confirm: {
          value: $r('app.string.hwid_text_button_known'),
          action: () => {
          },
        },
      });
    } else if (!userCanceled.includes(error.code)) {
      // Other exceptions not caused by user cancellations.
      promptAction.showToast({ message: error.message, duration: 2000 });
    }
  }

  /**
   * 打开普通提示弹窗
   * @param title
   * @param btnLabel
   * @param confirm
   */
  static openNoticeDialog(title: ResourceStr, btnLabel?: ResourceStr, confirm?: () => void) {
    PopViewUtils.showPopView<NoticeDialogParams>(wrapBuilder(NoticeDialog),
      new NoticeDialogParams(title, btnLabel, confirm),
      { alignment: DialogAlignment.Center });
  };
}
