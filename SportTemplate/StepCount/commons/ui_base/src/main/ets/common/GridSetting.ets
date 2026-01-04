import { Width } from './Constant';

export class CommonGridSetting {
  private static gridRowOptions: GridRowOptions = {
    gutter: {
      x: {
        sm: 16,
        md: 16,
        lg: 16,
        xl: 16
      }
    },
    columns: {
      sm: 4,
      md: 8,
      lg: 12,
      xl: 12
    },
    breakpoints: {
      value: [Width.ZERO, Width.SM, Width.MD, Width.LG],
      reference: BreakpointsReference.WindowSize,
    },
  };
  private static readonly gridMargin: GridRowSizeOption = {
    sm: 16,
    md: 24,
    lg: 24,
    xl: 24
  };

  static getCommonGridOption(direction: GridRowDirection = GridRowDirection.Row) {
    const options: GridRowOptions = JSON.parse(JSON.stringify(CommonGridSetting.gridRowOptions));
    options.direction = direction;
    return options;
  }

  static getGridMargin(breakpoint: string): number {
    return CommonGridSetting.gridMargin[breakpoint];
  }

  static getColumn(breakpoint: string): number {
    if (CommonGridSetting.gridRowOptions.columns) {
      return CommonGridSetting.gridRowOptions.columns[breakpoint];
    }
    return 4;
  }
}
