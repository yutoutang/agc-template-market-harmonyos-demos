export class CommonUtil {
  public static debounce<T>(func: (params: T) => void, delay: number) {
    let timer: number = -1;
    return (params: T) => {
      clearTimeout(timer);
      timer = setTimeout(() => {
        func(params);
      }, delay);
    };
  }
}