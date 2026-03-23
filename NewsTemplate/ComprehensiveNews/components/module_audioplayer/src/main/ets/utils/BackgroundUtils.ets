import { wantAgent, common } from '@kit.AbilityKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[BackgroundUtils]';

export class BackgroundUtils {
  /**
   * 开启后台播放
   * @param context
   */
  public static startContinuousTask(context?: common.UIAbilityContext): void {
    if (!context) {
      UtilLog.error('this avPlayer: ', `context undefined`);
      return;
    }
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.abilityInfo.bundleName,
          abilityName: context.abilityInfo.name,
        },
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: Object) => {
      try {
        if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
          backgroundTaskManager.startBackgroundRunning(context,
            backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(() => {
            UtilLog.info('this avPlayer: ', 'startBackgroundRunning succeeded');
          }).catch((error: BusinessError) => {
            UtilLog.error('this avPlayer: ', `startBackgroundRunning failed Cause: code ${error.code}`);
          });
        }
      } catch (error) {
        UtilLog.error('this avPlayer: ',
          `startBackgroundRunning failed. code ${(error as BusinessError).code} message ${(error as BusinessError).message}`);
      }
    }).catch((err: BusinessError) => {
      UtilLog.error(`getWantAgent failed, code: ${JSON.stringify(err.code)}, message: ${JSON.stringify(err.message)}`);
    })
  };

  /**
   * 暂停后台任务
   * @param context
   */
  public static stopContinuousTask(context: common.UIAbilityContext): void {
    if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
      backgroundTaskManager.stopBackgroundRunning(context).then(() => {
        UtilLog.info(TAG, 'stopBackgroundRunning succeeded');
      }).catch((error: BusinessError) => {
        UtilLog.error(TAG, `stopBackgroundRunning failed Cause: code ${error.code}, message: ${error.message}`);
      });
    }
  };
}