/**
 * 定义全局防抖方法，默认500毫秒，参数类型设为可选参数
 * @param func 函数
 * @param interval 间隔时间
 * @returns
 */
export function singleClick(func: Function, interval = 500) {
  let lastTime = 0;
  return () => {
    const nowTime = Date.now();
    const remainTime = interval - (nowTime - lastTime);
    if (remainTime <= 0) {
      lastTime = nowTime;
      func();
    }
  };
}
