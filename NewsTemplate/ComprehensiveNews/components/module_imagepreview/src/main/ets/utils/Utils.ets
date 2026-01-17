import { componentUtils, ComponentUtils } from '@kit.ArkUI'
import { UtilLog } from '@hw-agconnect/util-log'

/**
 * 组件信息类型
 */
export interface ComInfoType {
  width: number
  height: number
  localLeft: number
  localTop: number
  screenLeft: number
  screenTop: number
  windowTop: number
  windowLeft: number
}

/**
 * 获取组件信息
 * @param {context} UIContext
 * @param {key} 组件id
 * */
export const getComponentsInfo = (context: UIContext, key: string): ComInfoType | undefined => {
  try {
    let comUtils: ComponentUtils = context.getComponentUtils()
    let info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
    return {
      width: context.px2vp(info.size.width),
      height: context.px2vp(info.size.height),
      localLeft: context.px2vp(info.localOffset.x),
      localTop: context.px2vp(info.localOffset.y),
      screenLeft: context.px2vp(info.screenOffset.x),
      screenTop: context.px2vp(info.screenOffset.y),
      windowLeft: context.px2vp(info.windowOffset.x),
      windowTop: context.px2vp(info.windowOffset.y),
    }
  } catch (e) {
    UtilLog.error('getComponentsInfo fail, error: ' + JSON.stringify(e));
    return undefined;
  }
}

/**
 * 获取区间值
 */
export const clamp = (num: number, min: number, max: number): number => Math.min(Math.max(num, min), max)


/**
 * 根据类型和单位拼接尺寸 用于组件尺寸类属性格式化
 */
export function getSizeByUnit(val: string | number): string {
  if (typeof val === 'string') {
    return val
  }
  let unit = 'vp'
  return `${val}${unit}`
}
