import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { Logger } from '@ohos_agcit/driver_license_exam_commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { WantUtils } from '../util/WantUtils';
import { ShareService } from 'aggregated_share';
import { notificationManager } from '@kit.NotificationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/MainEntry', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');

      // 获取应用主窗口
      let windowClass: window.Window = windowStage.getMainWindowSync();
      // 设置窗口全屏
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
        console.info('Succeeded in setting the window layout to full-screen mode.');
      }).catch((err:BusinessError) => {
        console.info('Succeeded in setting the window layout to full-screen mode.');
      })

      // 获取布局避让的遮挡区域
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR;
      let avoidArea = windowClass.getWindowAvoidArea(type);
      let bottomRectHeight = avoidArea.bottomRect.height;
      AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

      type = window.AvoidAreaType.TYPE_SYSTEM;
      avoidArea = windowClass.getWindowAvoidArea(type);
      let topRectHeight = avoidArea.topRect.height;
      AppStorage.setOrCreate('topRectHeight', topRectHeight);

      notificationManager.requestEnableNotification(this.context).then(() => {
        hilog.info(0x0000, 'testTag', `[ANS] requestEnableNotification success`);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', `[ANS] requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
      });

      // 注册监听函数，动态获取避让区数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height;
          AppStorage.setOrCreate('topRectHeight', topRectHeight);
        } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height;
          AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
        }
      });
    });
  }
  // 实例化分享服务
  private shareServiceImpl: ShareService =
    ShareService.create()
    // todo 填写微信开放平台配置的应用AppID
      .initWX('wxc92d9d6570127a32')
      // todo 填写QQ互联平台配置的应用AppID
      .initQQ(102061317);

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    Logger.info(TAG, 'Ability onCreate');
    WantUtils.handlePushCall(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onNewWant');
    WantUtils.handlePushWant(want);
    this.shareServiceImpl.handleWant(want, this.context);
  }


}
