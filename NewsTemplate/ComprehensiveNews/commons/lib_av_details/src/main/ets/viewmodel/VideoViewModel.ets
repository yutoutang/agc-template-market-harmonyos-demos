import { AppStorageV2 } from '@kit.ArkUI';
import { BaseViewModel, BreakpointModel, BreakpointNameEnum } from 'lib_common';
import { AvModel } from 'lib_news_api';
import {
  CardTvWidthSizeConstants,
  CardTvHeightSizeConstants,
  televisionWidthSize,
  televisionHeightSize,
  televisionLanes,
  tvDetailsLanes,
  Constants,
  televisionTabletLanes,
} from '../constants/Constants';

const TAG = 'VideoDetails'

@ObservedV2
export class VideoVM extends BaseViewModel {
  @Trace curAudioInfo: AvModel = new AvModel()
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Trace isMute: boolean = false

  /**
   * 往期推荐卡片根据断点改变大小
   * */
  public geVideoWidth() {
    return televisionWidthSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvWidthSizeConstants.xlSize
  }

  public geVideoHeight() {
    return televisionHeightSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardTvHeightSizeConstants.xlSize
  }

  @Computed
  get isTablet() {
    return [BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint);
  }

  /**
   * 获取猜您喜欢格栅
   * */
  public getTelevisionLanes(isTvDetails: boolean) {
    return this.isTablet && isTvDetails ? televisionTabletLanes.getValue(this.breakPointModel.currentBreakpoint) :
      televisionLanes.getValue(this.breakPointModel.currentBreakpoint) ?? Constants.COMMON_LANES_1
  }

  /**
   * 电视详情栅格
   * */
  public getTvDetailsLanes() {
    return tvDetailsLanes.getValue(this.breakPointModel.currentBreakpoint) ?? Constants.COMMON_LANES_2
  }

  /**
   * 静音切换
   * */
  public setMute(value: boolean) {
    this.isMute = value
  }

  @Computed
  get videoBoxHeight() {
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes(this.breakPointModel.currentBreakpoint)) {
      return '100%'
    }
    return this.breakPointModel.currentBreakpoint === BreakpointNameEnum.SM ? 200 : 400
  }
}