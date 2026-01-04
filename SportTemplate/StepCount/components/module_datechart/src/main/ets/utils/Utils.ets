import { common } from '@kit.AbilityKit';

export class Utils {
  static getAbilityContext(component?: Object): common.UIAbilityContext {
    return getContext(component) as common.UIAbilityContext
  }

  static getResourceManager(component?: Object) {
    return Utils.getAbilityContext(component).resourceManager
  }

  static getColorSync(resId: number, component?: Object) {
    return Utils.getAbilityContext(component).resourceManager.getColorSync(resId)
  }

  /**
   * 格式化日期时间
   * @param date
   * @returns xx/xx
   */
  static formatDate(date: Date): string {
    return `${Utils.padZero(date.getMonth() + 1)}/${Utils.padZero(date.getDate())}`;
  }

  /**
   * 不足两位数，补0
   * @param input
   * @returns
   */
  static padZero(input: number) {
    return input.toString().padStart(2, '0');
  };
}