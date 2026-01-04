/**
 * @fileType: common
 * @zhName: 事件发射器工具类
 */
import emitter from '@ohos.events.emitter';


/**
 * 线程间通信
 */
export class EmitterUtil {
  static on<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    emitter.on(eventId, callback);
  }

  static off<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    emitter.off(eventId, callback);
  }

  static once<T>(eventId: string, callback: Callback<emitter.GenericEventData<T>>): void {
    emitter.once(eventId, callback);
  }

  static emit<T>(eventId: string, data?: emitter.GenericEventData<T>) {
    emitter.emit(eventId, data);
  }
}
