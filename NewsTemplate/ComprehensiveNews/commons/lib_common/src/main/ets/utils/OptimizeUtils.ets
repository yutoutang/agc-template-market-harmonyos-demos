export class OptimizeUtils {
  private static throttleTimeoutID: number | null = null;
  private static flag: boolean = false;

  public static debounce(func: () => void, delay: number = 500) {
    if (OptimizeUtils.throttleTimeoutID !== null) {
      clearTimeout(OptimizeUtils.throttleTimeoutID);
    }
    OptimizeUtils.throttleTimeoutID = setTimeout(() => {
      func();
      OptimizeUtils.throttleTimeoutID = null;
    }, delay);
  }


  public static throttle(func: () => void, wait: number = 1000) {
    if (!OptimizeUtils.flag) {
      OptimizeUtils.flag = true;
      func();
      setTimeout(() => {
        OptimizeUtils.flag = false;
      }, wait);
    }
  }
}