/**
 * 获取字符串中的数字
 * @param str
 * @returns
 */
export function getCoin(str:string):number|undefined{
  const regex = /(\d+)/
  const match = str.match(regex)
  if (match) {
    const number = parseInt(match[1])
    return number
  } else {
    return undefined
  }
}