import { common } from '@kit.AbilityKit';
import { EventEnum } from '../constants/EventEnum';

/**
 * EventHub线程通信
 */
export class EventHubUtils {
  private static instance: EventHubUtils;
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;

  public emit(eventKey: EventEnum | string, ...args: Object[]) {
    this.eventHub.emit(eventKey, ...args);
  }
  public static getInstance(): EventHubUtils {
    // 单例
    if (!EventHubUtils.instance) {
      EventHubUtils.instance = new EventHubUtils();
    }
    return EventHubUtils.instance;
  }

  /**
   * 移除监听
   * @param eventKey
   * @param callback
   */
  public off(eventKey: EventEnum | string, callback?: Function) {
    this.eventHub.off(eventKey, callback);
  }

  public on(eventKey: EventEnum | string, callback: Function) {
    this.eventHub.on(eventKey, callback);
  }
}
