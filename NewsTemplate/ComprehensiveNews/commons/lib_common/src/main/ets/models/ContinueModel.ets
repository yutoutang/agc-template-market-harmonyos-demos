import { BreakpointNameEnum } from '../constants/GridRowColSetting';
import { NewsEnum } from '../constants/NewsEnum';

/**
 * 自由流转-应用接续模型
 */
@ObservedV2
export class ContinueModel {
  @Trace id: number = 0;
  @Trace newsId: string = '';
  @Trace newsType: NewsEnum = 0;
  @Trace playerProgress: number = 0;
  @Trace scrollOffset: number = 0;
  @Trace breakpoint: string = BreakpointNameEnum.SM;
  @Trace isTargetDevice: boolean = false;
}