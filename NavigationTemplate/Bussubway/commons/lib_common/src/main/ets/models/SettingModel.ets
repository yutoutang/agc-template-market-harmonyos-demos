/**
 * 全局设置
 */
@ObservedV2
export class SettingModel {
  // 青少年模式
  @Trace teenagersSwitch: boolean = false;
  // 下载品质
  @Trace qualitySwitch: boolean = false;
  // 边听边存
  @Trace storageSwitch: boolean = false;
  // 通知开关
  @Trace pushSwitch: boolean = false;
  // 深色模式
  @Trace darkSwitch: boolean = false;
  // 字体大小
  @Trace fontSizeRatio: number = 1;
  // 隐私设置-个性化推荐
  @Trace personalizedPush: boolean = true;
  // 到站提醒
  @Trace warnType: number = 1; // 提醒类型：0-提前分钟数，1-提前站点
  @Trace warnValue: number = 2; // 提醒数值：1-5
  @Trace accessType: number = 1; // 交通方式选择：0-公交，1-地铁
  @Trace speedType: number = 1; // 刷新频率选择：0-10秒，1-30秒，2-1分钟
  @Trace isArrivalReminder: boolean = true; // 到站提醒
  @Trace abnormalReminderOn: boolean = true; // 异常提醒
  @Trace lastTrainReminderOn: boolean = true; // 末班提醒
  // 播放与网络设置
  @Trace network: SettingNetworkModel = new SettingNetworkModel();
  // 定位权限相关
  @Trace locationHasPermission: boolean = false // 是否已授权定位
  @Trace locationShowPrompt: boolean = false // 是否显示未授权提示
}

@ObservedV2
export class SettingNetworkModel {
  // 非WLAN网络流量
  @Trace downloadWithoutWlan: number = 0;
  // 非WLAN网络播放提醒
  @Trace remindWithoutWlan: number = 0;
  // 非WLAN网络下自动播放直播
  @Trace liveAutoplayWithoutWlan: boolean = true;
  // 使用移动网络改善内容浏览体验
  @Trace optimizeWith4G: boolean = true;
  // 视频自动下滑
  @Trace autoPlayNext: boolean = true;
  // 推荐频道自动播放视频
  @Trace autoPlayTabRecommend: boolean = true;
}