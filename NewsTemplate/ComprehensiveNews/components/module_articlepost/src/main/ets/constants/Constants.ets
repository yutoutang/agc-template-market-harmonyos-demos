export class Constants {
  static readonly FULL_PERCENT: string = '100%';
  static readonly MAX_BODY_WORD_LIMIT: number = 30;
}

export const GRID_ROW_OPTIONS: GridRowOptions = {
  columns: {
    sm: 4,
    md: 8,
    lg: 12,
    xl: 12,
  },
  gutter: {
    x: {
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
    },
  },
  breakpoints: {
    value: ['0', '600vp', '840vp', '1440vp'],
    reference: BreakpointsReference.WindowSize,
  },
  direction: GridRowDirection.Row,
};

export const COL_SPAN: GridColColumnOption = {
  sm: 4,
  md: 8,
  lg: 8,
  xl: 8,
};

export const COL_OFFSET: GridColColumnOption = {
  sm: 0,
  md: 0,
  lg: 2,
  xl: 2,
};

export const GRID_MARGIN: GridRowColumnOption = {
  sm: 16,
  md: 24,
  lg: 32,
  xl: 32,
};