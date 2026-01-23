/**
 * 栅格通用设置
 */
export class GridRowColSetting {
  /**
   * 栅格布局-断点数列
   */
  public static readonly BREAK_POINT_VALUE: string[] = ['0', '600vp', '840vp', '1440vp'];
  
  /**
   * 栅格布局-列数
   */
  public static readonly GRID_ROW_OPTIONS_COLUMNS: GridRowColumnOption = {
    xl: 12,
    lg: 12,
    md: 8,
    sm: 4,
  }

  /**
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    xl: 32,
    lg: 32,
    md: 24,
    sm: 16,
  };

  /**
   * 栅格布局-x间距
   */
  public static readonly GRID_ROW_OPTIONS_GUTTER_X: GridRowSizeOption = {
    xl: 20,
    lg: 16,
    md: 12,
    sm: 8,
  }

  /**
   * 居中8栅格列span
   */
  public static readonly DEFAULT_CENTER_COL_SPAN: GridColColumnOption = {
    xl: 8,
    lg: 8,
    md: 8,
    sm: 4,
  };
  
  /**
   * 居中8栅格列offset
   */
  public static readonly DEFAULT_CENTER_COL_OFFSET: GridColColumnOption = {
    md: 0,
    lg: 2,
    xl: 2,
    sm: 0,
  };

  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: string): number {
    return Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp);
  }

  /**
   * 栅格行布局容器-默认参数
   */
  public static readonly DEFAULT_GRID_ROW_OPTIONS: GridRowOptions = {
    gutter: {
      x: GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X,
    },
    columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
    breakpoints: {
      value: GridRowColSetting.BREAK_POINT_VALUE,
      reference: BreakpointsReference.WindowSize,
    },
    direction: GridRowDirection.Row,
  };
}
