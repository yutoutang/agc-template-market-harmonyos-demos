import { resourceManager } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';

export class RunResUtil {
  private static context: common.UIAbilityContext; //common.UIAbilityContext，上下文

  /**
   * 获取提供访问应用资源的能力
   * @returns
   */
  static getResourceManager(): resourceManager.ResourceManager {
    return RunResUtil.context.resourceManager;
  }

  /**
   * 初始化方法,缓存全局变量，在UIAbility的onCreate方法中初始化该方法。
   * @param windowStage 窗口管理器
   */
  static init(context: common.UIAbilityContext) {
    RunResUtil.context = context;
  }

  /**
   * 获取指定资源对应的字符串
   * @param resId 资源ID值
   * @param args 格式化字符串资源参数。
   *   支持参数类型：%d、%f、%s、%%、%数字\$d、%数字\$f、%数字\$s；
   *   说明：%%转义为%; %数字\$d表示使用第几个参数；
   *   举例：%%d格式化后为%d字符串; %1\$d表示使用第一个参数
   */
  static getStringSync(resId: number | Resource, args?: (string | number)[]): string {
    if (args !== undefined && args.length > 0) {
      if (typeof resId === 'number') {
        return RunResUtil.getResourceManager().getStringSync(resId, ...args);
      } else {
        return RunResUtil.getResourceManager().getStringSync(resId, ...args);
      }
    } else {
      if (typeof resId === 'number') {
        return RunResUtil.getResourceManager().getStringSync(resId);
      } else {
        return RunResUtil.getResourceManager().getStringSync(resId);
      }
    }
  }
}