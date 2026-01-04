/**
 * 节流、防抖 工具类（用于点击事件，防止按钮被重复点击）
 */
export class ClickUtil {
  private static throttleTimeoutID: number; //节流timeoutID
  private static flag: boolean = false; //节流flag,true=已经进入执行状态了

  /**
   * 节流：在一定时间内，只触发一次
   * @param func 要执行的回调函数
   * @param wait = 1500 延时的时间 毫秒
   * @param immediate = true 是否立即执行
   */
  static throttle(func: () => void, wait: number = 1000, immediate: boolean = true) {
    if (immediate) {
      if (!ClickUtil.flag) {
        ClickUtil.flag = true;
        typeof func === 'function' && func();
        ClickUtil.throttleTimeoutID = setTimeout(() => {
          ClickUtil.flag = false;
          clearTimeout(ClickUtil.throttleTimeoutID);
        }, wait);
      }
    } else {
      if (!ClickUtil.flag) {
        ClickUtil.flag = true;
        ClickUtil.throttleTimeoutID = setTimeout(() => {
          ClickUtil.flag = false;
          typeof func === 'function' && func();
          clearTimeout(ClickUtil.throttleTimeoutID);
        }, wait);
      }
    }
  }
}