import { BaseViewModel, BundleInfo } from 'lib_common';

@ObservedV2
export class SettingAboutVM extends BaseViewModel {
  @Trace appName: string = '';
  @Trace appVersionName: string = '';
  @Trace appDesc: string =
    '这是一款便捷的外卖平台，汇聚海量餐饮商家与美食，支持智能推荐、快速下单、实时配送。多种支付方式与优惠活动，保障餐品新鲜准时送达，让你随时随地轻松享受美味。';

  constructor() {
    super();
    this.getBundleInfo();
  }

  async getBundleInfo() {
    let appInfo = AppStorage.get('appInfo') as BundleInfo
    this.appName = appInfo.appName
    this.appVersionName = appInfo.appVersionName;
  }
}
