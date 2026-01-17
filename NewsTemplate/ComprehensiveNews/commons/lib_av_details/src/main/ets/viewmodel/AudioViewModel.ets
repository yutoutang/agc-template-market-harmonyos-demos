import { AppStorageV2 } from '@kit.ArkUI';
import { AbilityConstant, common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseViewModel, BreakpointModel, GlobalContextUtils, Logger, TimeUtils, VideoType } from 'lib_common';
import { AvModel } from 'lib_news_api';
import { MediaController } from 'module_audioplayer';
import { broadcastLikeLanes, broadcastSize, CardSizeConstants, Constants } from '../constants/Constants';

const TAG = '[AudioDetails]'

@ObservedV2
export class AudioVM extends BaseViewModel {
  @Trace curAudioInfo: AvModel = new AvModel()
  @Trace breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get isCurrentPlay(): boolean {
    return MediaController.isSameCurrentPlay(this.curAudioInfo.id)
  }

  public setCurAudioInfo(curAudioInfo: AvModel) {
    this.curAudioInfo = curAudioInfo
  }

  public initAudioPlayer() {
    if (!MediaController.getAvplayer()) {
      MediaController.initAudioList(GlobalContextUtils.globalUIAbilityContext)
    }
  }

  public enableContinue(context: common.UIAbilityContext) {
    context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE).then(() => {
      Logger.info(TAG, 'setMissionContinueState ACTIVE result: ACTIVE')
    }).catch((e: BusinessError) => {
      Logger.error(TAG, 'setMissionContinueState fail, error: ' + JSON.stringify(e));
    });
  }

  public audioListSort(curAudioInfo: AvModel, flag: boolean) {
    if (flag) {
      curAudioInfo.section.sort((a, b) => new Date(TimeUtils.formatDate(a.updateTime, 'YYYY-MM-DD')).getTime() -
      new Date(TimeUtils.formatDate(b.updateTime, 'YYYY-MM-DD')).getTime())
    } else {
      curAudioInfo.section.sort((a, b) => new Date(TimeUtils.formatDate(b.updateTime, 'YYYY-MM-DD')).getTime() -
      new Date(TimeUtils.formatDate(a.updateTime, 'YYYY-MM-DD')).getTime())
    }
  }

  public isVideoTab() {
    return this.tabModel.selectedIndex !== 1 && this.tabModel.videoCurrentTabIndex !== VideoType.BROADCAST
  }

  /**
   * 猜您喜欢卡片根据断点改变大小
   * */
  public getBroadcastSize() {
    return broadcastSize.getValue(this.breakPointModel.currentBreakpoint) ?? CardSizeConstants.xlSize
  }

  /**
   * 获取猜您喜欢格栅
   * */
  public getBroadcastLanes() {
    return broadcastLikeLanes.getValue(this.breakPointModel.currentBreakpoint) ?? Constants.COMMON_LANES_3
  }
}