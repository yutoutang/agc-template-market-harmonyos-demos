const TAG = '[StringUtils]';

/**
 * 字符处理类
 */
export class StringUtils {
  static trimLastCharacter(oldStr: string, lastCharacter: string) {
    const regex = new RegExp(`${lastCharacter}$`);
    const newStr: string = oldStr.replace(regex, '');
    return newStr
  }

  static trimInBracket(str: string) {
    const leftBracket = str.indexOf('(')
    if (leftBracket !== -1) {
      return str.substring(0, leftBracket) as string
    }
    return str
  }
}