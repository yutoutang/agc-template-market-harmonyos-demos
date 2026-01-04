import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 打印日志，method装饰器
 * @param target
 * @param propertyKey
 * @param descriptor
 * @returns
 */
export function logMethod(target: any, propertyKey: string, descriptor: PropertyDescriptor): PropertyDescriptor {
  const originalMethod = descriptor.value;

  descriptor.value = function (...args: any[]): any {
    hilog.info(0x0000, 'testTag', `[Method Call] ${target.constructor.name}.${propertyKey}() with args:`, args);
    // 执行原方法
    const result = originalMethod.apply(this, args);

    hilog.info(0x0000, 'testTag', `[Method Result] ${target.constructor.name}.${propertyKey}() returned:`, result);
    return result;
  };

  return descriptor;
}