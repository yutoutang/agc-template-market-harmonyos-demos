import { BreakPointConstants } from '../constants/BreakPointConstants'
import { mediaquery } from '@kit.ArkUI';

export class BreakPointSystem {
  private currentBreakPoint: string = BreakPointConstants.BREAKPOINT_SM
  private smListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_SM);
  private mdListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_MD);
  private lgListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_LG);

  /// 保存当前状态
  private updateCurrentBreakPoint(breakpoint: string) {
    if (this.currentBreakPoint !== breakpoint) {
      this.currentBreakPoint = breakpoint
      //应用级的存储
      AppStorage.setOrCreate<string>(BreakPointConstants.CURRENT_BREAKPOINT, this.currentBreakPoint)
    }
  }


  private isBreakPointSM = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_SM)
      //sm
    }
  }
  private isBreakPointMD = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_MD)
      //MD
    }
  }
  private isBreakPointLG = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentBreakPoint(BreakPointConstants.BREAKPOINT_LG)
      //LG
    }
  }

  public register() {
    this.smListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_SM);
    this.smListener.on('change', this.isBreakPointSM)
    this.mdListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_MD);
    this.mdListener.on('change', this.isBreakPointMD)
    this.lgListener = mediaquery.matchMediaSync(BreakPointConstants.RANGE_LG);
    this.lgListener.on('change', this.isBreakPointLG)
  }

  public unRegister() {
    this.smListener.off('change', this.isBreakPointSM)
    this.mdListener.off('change', this.isBreakPointMD)
    this.lgListener.off('change', this.isBreakPointLG)
  }
}