export class BreakPointConstants {
  /*  手机 xs 不写*/
  static readonly BREAKPOINT_SM: string = 'sm';
  /*  折叠屏*/
  static readonly BREAKPOINT_MD: string = 'md';
  /*  ipad*/
  static readonly BREAKPOINT_LG: string = 'lg';
  /*  断点数组*/
  static readonly BREAKPOINT_VALUE: Array<string> = ['320vp', '600vp', '840vp'];
  /*  列占多少*/
  static readonly COLUMN_SM: number = 4;
  static readonly COLUMN_MD: number = 8;
  static readonly COLUMN_LG: number = 12;
  /*  列占多少*/
  static readonly GUTTER_X: number = 12;
  /*  列占多少*/
  static readonly CURRENT_BREAKPOINT: string = 'currentBreakpoint';
  static readonly RANGE_SM: string = '(320vp<=width<600vp)';
  static readonly RANGE_MD: string = '(600vp<=width<840vp)';
  static readonly RANGE_LG: string = '(840vp<=width)';
}