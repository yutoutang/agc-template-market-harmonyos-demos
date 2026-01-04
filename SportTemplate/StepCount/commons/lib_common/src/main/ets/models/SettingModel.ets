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
  // 运动与健康权限
  @Trace exerciseAndHealthAuthorization: boolean = false;
  // 位置权限
  @Trace positionAuthorization: boolean = false;
  // 新消息通知
  @Trace pushNewSwitch: boolean = false;
  // 自动生成运动记录
  @Trace autoSportsRecordSwitch: boolean = false;
  // 自动生成运动记录最短距离
  @Trace autoSportsRecordMinValue: string = '200m';
  @Trace autoSportsRecordSelectIndex: number = 0;
  // 深色模式
  @Trace darkSwitch: boolean = false;
  // 字体大小
  @Trace fontSizeRatio: number = 1;
  // 隐私设置-个性化推荐
  @Trace personalizedPush: boolean = true;
  // 播放与网络设置
  @Trace network: SettingNetworkModel = new SettingNetworkModel();
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