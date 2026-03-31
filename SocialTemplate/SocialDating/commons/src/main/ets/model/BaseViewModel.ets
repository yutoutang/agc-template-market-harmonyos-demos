import { ContextUtils, GlobalContextUtils } from '../utils/ContextUtils';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  contextModel: ContextUtils = GlobalContextUtils;
}