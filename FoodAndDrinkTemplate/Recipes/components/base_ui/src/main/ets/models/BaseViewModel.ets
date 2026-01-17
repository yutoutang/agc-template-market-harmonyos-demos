import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from './BreakpointModel';

/**
 * 所有ViewModel的基类，支持UI动态观测WindowModel.ets
 */
@ObservedV2
export abstract class BaseViewModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}