
/**
 * 用于检查数据是否为空的工具类
 */
class CheckEmptyUtils {
  /**
   * 检查对象是否为空
   *
   * @param
   * @return
   */
  isEmptyObj(obj: object | string) {
    return (typeof obj === 'undefined' || obj === null || obj === '')
  }

  /**
   * 检查字符串是否为空
   *
   * @param
   * @return
   */
  isEmptyStr(str: string) {
    return str.trim().length === 0
  }

  /**
   * 检查数组是否为空
   *
   * @param
   * @return
   */
  isEmptyArr(arr: Array<string>) {
    return arr.length === 0
  }
}

export default new CheckEmptyUtils()