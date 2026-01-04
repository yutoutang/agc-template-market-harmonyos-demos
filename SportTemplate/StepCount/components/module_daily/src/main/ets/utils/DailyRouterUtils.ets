import { DailyRouterMap } from '../constants/DailyRouterMap';
import { DailyLogger } from './DailyLogger';

const TAG = '[RouterUtils]';

export enum StackEnum {
  Main = 'main',
}

/**
 * 路由管理类
 */
export class RouterUtils {
  /**
   * 路由栈Map
   */
  private static stackMap: Map<string, NavPathStack> = new Map([
    [StackEnum.Main, new NavPathStack()],
  ]);

  /**
   * 获取栈
   * @returns
   */
  public static getStack(name?: string): NavPathStack {
    if (name) {
      return RouterUtils.stackMap.get(name) || new NavPathStack();
    }
    return RouterUtils.stackMap.get(StackEnum.Main) || new NavPathStack();
  }

  /**
   * 跳转页面
   * @param name
   * @param param
   * @param onPop
   * @param animated
   */
  public static pushPathByName(name: DailyRouterMap, param: Object | null = null, onPop?: Callback<PopInfo>,
    animated: boolean = true, stackName: string = StackEnum.Main) {
    DailyLogger.info(TAG, `RouterUtil route: ${name}, param: ${JSON.stringify(param)}`);
    if (onPop) {
      RouterUtils.getStack(stackName).pushPathByName(name, param, onPop, animated);
    } else {
      RouterUtils.getStack(stackName).pushPathByName(name, param, animated);
    }
  }

  /**
   * 更换页面
   * @param name
   * @param param
   * @param animated
   */
  public static replacePathByName(name: DailyRouterMap, param: Object | null = null, animated: boolean = true,
    stackName: string = StackEnum.Main) {
    RouterUtils.getStack(stackName).replacePathByName(name, param, animated);
  }
}



