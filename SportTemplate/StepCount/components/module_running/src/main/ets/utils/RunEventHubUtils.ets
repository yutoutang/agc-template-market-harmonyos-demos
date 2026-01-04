import { common } from '@kit.AbilityKit';
import { RunEventEnum } from '../common/RunEventEnum';

/**
 * EventHub线程通信
 */
export class RunEventHubUtils {
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  private static instance: RunEventHubUtils;

  public static getInstance(): RunEventHubUtils {
    if (!RunEventHubUtils.instance) {
      RunEventHubUtils.instance = new RunEventHubUtils();
    }
    return RunEventHubUtils.instance;
  }

  public emit(eventKey: RunEventEnum | string, ...args: Object[]) {
    this.eventHub.emit(eventKey, ...args);
  }

  public off(eventKey: RunEventEnum | string, callback?: Function) {
    this.eventHub.off(eventKey, callback);
  }

  public on(eventKey: RunEventEnum | string, callback: Function) {
    this.eventHub.on(eventKey, callback);
  }

}
