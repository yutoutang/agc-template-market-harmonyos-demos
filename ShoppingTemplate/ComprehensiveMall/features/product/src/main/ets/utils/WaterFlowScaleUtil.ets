import { BreakpointSystem, BreakpointTypeEnum } from 'lib_foundation';

@ObservedV2
export class WaterFlowScaleUtil {
  @Trace
  private static _currentColumns: number = 0;
  private static readonly MAX_TABLET_COLUMNS = 6;
  private static readonly MIN_TABLET_COLUMNS = 4;
  private static readonly MAX_FOLDABLE_COLUMNS = 4;
  private static readonly MIN_FOLDABLE_COLUMNS = 2;

  @Computed
  public static get columnsTemplate() {
    if (!WaterFlowScaleUtil._currentColumns) {
      WaterFlowScaleUtil.initColumns();
    }
    return '1fr '.repeat(WaterFlowScaleUtil._currentColumns).trim();
  }

  private static initColumns() {
    if (WaterFlowScaleUtil._currentColumns) {
      return;
    }
    WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.getInitColumns();
  }

  private static getInitColumns() {
    const map: Map<BreakpointTypeEnum, number> = new Map([
      [BreakpointTypeEnum.SM, 2],
      [BreakpointTypeEnum.MD, 3],
      [BreakpointTypeEnum.LG, 5],
    ]);
    return map.get(BreakpointSystem.currentBreakpoint.value) as number;
  }

  public static handlePinchUpdate(scale: number) {
    // 直板机不支持缩放
    if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.SM) {
      return;
    }
    if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.MD) {
      if (scale > 1.5 && WaterFlowScaleUtil._currentColumns > WaterFlowScaleUtil.MIN_FOLDABLE_COLUMNS) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.MIN_FOLDABLE_COLUMNS;
      } else if (scale < 0.7 && WaterFlowScaleUtil._currentColumns < WaterFlowScaleUtil.MAX_FOLDABLE_COLUMNS) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.MAX_FOLDABLE_COLUMNS;
      } else if (scale > 0.9 && scale < 1.1) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.getInitColumns();
      }
      return;
    }
    if (BreakpointSystem.currentBreakpoint.value === BreakpointTypeEnum.LG) {
      if (scale > 1.5 && WaterFlowScaleUtil._currentColumns > WaterFlowScaleUtil.MIN_TABLET_COLUMNS) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.MIN_TABLET_COLUMNS;
      } else if (scale < 0.7 && WaterFlowScaleUtil._currentColumns < WaterFlowScaleUtil.MAX_TABLET_COLUMNS) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.MAX_TABLET_COLUMNS;
      } else if (scale > 0.9 && scale < 1.1) {
        WaterFlowScaleUtil._currentColumns = WaterFlowScaleUtil.getInitColumns();
      }
    }
  }
}
