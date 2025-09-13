import { BreakpointModel } from './Model'

@ObservedV2
export class FlexLayoutBreakPointVM {
  @Trace public static  breakpointModel: BreakpointModel = new BreakpointModel()
}