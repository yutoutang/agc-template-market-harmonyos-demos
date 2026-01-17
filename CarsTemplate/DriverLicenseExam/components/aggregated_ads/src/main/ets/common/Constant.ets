import { window } from '@kit.ArkUI';

export enum AdStatus {
  AD_LOAD = 'onAdLoad',

  AD_FAIL = 'onAdFail',

  AD_OPEN = 'onAdOpen',

  AD_CLICKED = 'onAdClick',

  AD_CLOSED = 'onAdClose',
}

export enum ChannelType {
  HUAWEI_AD = 0
}

export enum AdType {
  // Splash ad.
  SPLASH_AD = 1,

  // Banner ad.
  BANNER_AD = 8
}

export class Constants {
  static windowStage: window.WindowStage
}