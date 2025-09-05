import { CommonBreakpoint } from 'lib_common'

@ObservedV2
export class FlexLayoutBreakPointVM {
  @Trace extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[]> = {}
  @Trace lanesCount:CommonBreakpoint<number> = new CommonBreakpoint<number>({
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3,
  });

  constructor(extraInfo?: Record<string, number | string | boolean | Record<string, string | boolean>[]>) {
    this.extraInfo = extraInfo ?? {}
  }

  @Computed
  get getLanes() {
    return this.extraInfo?.hotList ? this.lanesCount.getLanes() : 1
  }

  @Computed
  get getSearchLanes() {
    return this.lanesCount.getLanes()
  }
}