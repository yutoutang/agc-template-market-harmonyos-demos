export class RunStrUtil {
  /**
   * 去除字符串里的所有空格
   * @param str
   * @returns
   */
  static trimAll(str: string): string {
    return str.replace(/\s/g, '');
  }

  /**
   * 判断字符串是否为空和空白符(空白符包括空格、制表符、全角空格和不间断空格)。true为空，否则false
   * @param str
   * @returns
   */
  static isBlank(str: string | undefined | null): boolean {
    if ((str === undefined) || (str === null)) {
      return true;
    }
    let trimStr = RunStrUtil.trimAll(str);
    return trimStr.length === 0;
  }

  /**
   * 判断字符串是否为非空和空白符(空白符包括空格、制表符、全角空格和不间断空格)true为非空，否则false
   * @param str
   * @returns
   */
  static isNotBlank(str: string | undefined | null): boolean {
    return !RunStrUtil.isBlank(str);
  }
}
