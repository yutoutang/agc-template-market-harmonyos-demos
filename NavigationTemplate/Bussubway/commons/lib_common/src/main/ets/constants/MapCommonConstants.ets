export class MapCommonConstants {
  /**
   * 定位超时时间
   */
  static LOCATING_TIMEOUT_MS: number = 10000;
  /**
   * 定位优先级
   */
  static PRIORITY_LOCATING_SPEED: number = 0x502;
  /**
   * 位置
   */
  static NAVIGATION: number = 0x401;
  /**
   * 位置切换
   */
  static LOCATION_SWITCH_OFF: number = 3301100;
  /**
   * 位置失效
   */
  static LOCATION_FAILED: number = 3301200;
  /**
   * 反向地理编码失败
   */
  static REVERSE_GEOCODING_FAILED: number = 3301300;
  /**
   * WiFy或者蓝牙关闭
   */
  static WIFI_BLUETOOTH_OFF: number = 3301800;
  /**
   * 信息窗口标题
   */
  //static MARKER_TITLE: string = getContext(this).resourceManager.getStringSync($r('app.string.geocoded_location'));
  static MARKER_TITLE: string = '逆地理编码结果'
}
