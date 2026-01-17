/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { BASE_URL } from '../constants/AppConstant';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { UIDialog } from '@hw-agconnect/ui-dialog';
import { ErrorCode } from '../constants/ErrorCode';
import { WindowUtil } from './WindowUtil';

const TAG = '[CommonUtils]';

/**
 * 通用Utils
 */
export class CommonUtils {
  /**
   * 时间戳转换成xxxx-xx-xx
   * @param datetime
   */
  static formatDate(datetime: number | string | Date | undefined, format = 'YYYY-MM-DD') {
    if (!datetime) {
      return '';
    }
    let targetDate = datetime instanceof Date ? datetime : new Date(datetime);
    const month = targetDate.getMonth();
    const formats: Record<string, string | number> = {
      // 年份
      'YYYY': targetDate.getFullYear(),
      'YY': targetDate.getFullYear().toString().slice(-2),
      // 月份
      'MM': CommonUtils.padZero(month + 1),
      // 日期
      'DD': CommonUtils.padZero(targetDate.getDate()),
      // 时间
      'HH': CommonUtils.padZero(targetDate.getHours()),
      'hh': CommonUtils.padZero(targetDate.getHours() % 12 || 12),
      'mm': CommonUtils.padZero(targetDate.getMinutes()),
      'ss': CommonUtils.padZero(targetDate.getSeconds()),
    }
    return format.replace(/\[([^\]]+)]|Y{2,4}|M{1,4}|D{1,2}|H{1,2}|h{1,2}|m{1,2}|s{1,2}/g,
      (match: string, escaped: string): string => escaped || formats[match].toString())
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
        const resource = WindowUtil.context!.resourceManager.getMediaBase64ByNameSync(resourceName);
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
      UIDialog.open({
        contentOptions:{
          content: $r('app.string.hwid_no_internet_connect'),
          contentTextAlign: TextAlign.Center,
        },
        confirmButtonOptions:{
          button: $r('app.string.hwid_text_button_known'),
        },
        showConfirmButton: true,
        onConfirm: () => {
          UIDialog.closeLast();
        }
      })
    } else if (!userCanceled.includes(error.code)) {
      // Other exceptions not caused by user cancellations.
      ToastDialog.showToast({ message: error.message, duration: 2000 });
    }
  }
}
