/**
 * 节流、防抖 工具类（用于点击事件，防止按钮被重复点击）
 */
export class SingleClickUtil {
  private static flag: boolean = false; //节流flag,true=已经进入执行状态了
  private static throttleTimeoutID: number; //节流timeoutID

  /**
   * 节流：在一定时间内，只触发一次
   * @param func 要执行的回调函数
   * @param wait = 1500 延时的时间 毫秒
   * @param immediate = true 是否立即执行
   */
  static throttle(func: () => void, wait: number = 1000, immediate: boolean = true) {
    if (immediate) {
      if (!SingleClickUtil.flag) {
        SingleClickUtil.flag = true;
        typeof func === 'function' && func();
        SingleClickUtil.throttleTimeoutID = setTimeout(() => {
          SingleClickUtil.flag = false;
          clearTimeout(SingleClickUtil.throttleTimeoutID);
        }, wait);
      }
    } else {
      if (!SingleClickUtil.flag) {
        SingleClickUtil.flag = true;
        SingleClickUtil.throttleTimeoutID = setTimeout(() => {
          SingleClickUtil.flag = false;
          typeof func === 'function' && func();
          clearTimeout(SingleClickUtil.throttleTimeoutID);
        }, wait);
      }
    }
  }
}