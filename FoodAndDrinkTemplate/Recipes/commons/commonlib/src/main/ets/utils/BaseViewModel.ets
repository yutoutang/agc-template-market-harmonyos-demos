import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from '../models/BreakpointModel';
import { ContextUtils, GlobalContextUtils } from './ContextUtils';

/**
 * 所有ViewModel的基类，支持UI动态观测
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace contextModel: ContextUtils = GlobalContextUtils;
}