export interface BreakpointTypes<T> {
  sm: T;
  md: T;
  lg: T;
}

export class BreakpointType<T> {
  private sm: T;
  private md: T;
  private lg: T;

  public constructor(param: BreakpointTypes<T>) {
    this.sm = param.sm;
    this.md = param.md;
    this.lg = param.lg;
  }

  public getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === 'sm') {
      return this.sm;
    }
    if (currentBreakpoint === 'md') {
      return this.md;
    }
    return this.lg;
  }
}