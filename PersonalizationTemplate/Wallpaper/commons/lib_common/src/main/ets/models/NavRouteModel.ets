import { uiObserver } from '@kit.ArkUI';

/**
 * 无感监听
 */
@ObservedV2
export class NavRouteModel {
  // 路由变化监听事件
  @Trace navDestinationUpdateListeners: Map<string, (info: uiObserver.NavDestinationInfo) => void> = new Map();
}
