import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from './BreakpointModel';

@ObservedV2
export abstract class BaseViewModel {
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}