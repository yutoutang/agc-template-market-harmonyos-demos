import { UIAbility, Want } from '@kit.AbilityKit';
import { window, KeyboardAvoidMode } from '@kit.ArkUI';
import { FrameworkUtil, Logger, RouterMap, RouterModule, TabsIndexMap, WindowUtil } from 'commonlib';
import { buffer } from '@kit.ArkTS';
import auth from '@hw-agconnect/auth';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  public onCreate(want: Want): void {
    // 认证服务初始化
    let file = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
    let json: string = buffer.from(file.buffer).toString();
    auth.init(this.context, json);

    // 获取router事件中传递的targetPage参数
    if (want?.parameters?.params) {
      try {
        let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
        const cardType = params.cardType as string;
        const message = params.message as string;
        this.handleWantInfo(cardType, message);
      } catch (err) {
        Logger.error(TAG, 'handle want info failed. error:' + JSON.stringify(err));
      }
    }
  }

  // 如果UIAbility已在后台运行，在收到Router事件后会触发onNewWant生命周期回调
  public onNewWant(want: Want): void {
    if (want?.parameters?.params) {
      try {
        let params: Record<string, Object> = JSON.parse(want.parameters.params as string);
        const cardType = params.cardType as string;
        const message = params.message as string;
        const data = params.data as string;
        this.handleWantInfo(cardType, message, data);
      } catch (err) {
        Logger.error(TAG, 'handle want info failed. error:' + JSON.stringify(err));
      }
    }
  }

  public onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/EmptyPage', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      try {
        const win = windowStage.getMainWindowSync()
        WindowUtil.initWindowUtil(win)
        win.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET)
        Logger.info(TAG, 'Succeeded in loading the content.');
      } catch (err) {
        Logger.error(TAG, 'failed in loading the content.');
      }
    });
  }

  public handleWantInfo(cardType: string, message: string, data?: string) {
    if (cardType === 'mini') {
      if (message === 'home') {
        FrameworkUtil.switchTab(TabsIndexMap.HOME);
      } else if (message === 'checkIn') {
        FrameworkUtil.switchTab(TabsIndexMap.CHECK_IN);
      }
    } else if (cardType === 'middle') {
      if (message === 'home') {
        FrameworkUtil.switchTab(TabsIndexMap.HOME);
      } else if (message === 'courseDetail' && data) {
        const courseId: number | undefined = JSON.parse(data)?.courseId;
        if (courseId) {
          RouterModule.clear();
          RouterModule.push({
            url: RouterMap.COURSE_DETAIL,
            param: {
              courseId,
            },
          });
        }
      }
    }
  }
}
