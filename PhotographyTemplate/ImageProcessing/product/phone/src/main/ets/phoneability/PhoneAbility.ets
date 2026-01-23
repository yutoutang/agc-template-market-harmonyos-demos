import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AppStorageV2 } from '@kit.ArkUI';
import { WindowSize } from 'commonlib';

const DOMAIN = 0x0000;

export default class PhoneAbility extends UIAbility {
  private mWindow!: window.Window;
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('context',this.context)
    // 全局设置为浅色模式
    let applicationContext = this.context.getApplicationContext();
    applicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.mWindow = windowStage.getMainWindowSync();
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    // 订阅窗口尺寸变化
    this.mWindow.on('windowSizeChange', (size: window.Size) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
      windowModel.screenHeight = size.height
      windowModel.screenWidth = size.width
    });

    // 安全区域变化时更新状态栏和导航栏高度
    this.mWindow.on('avoidAreaChange', (data) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        // 存储窗口内容规避的状态栏高度
        windowModel.statusHeight = data.area.topRect.height
      } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // 存储窗口内容规避的底部安全区高度
        windowModel.bottomHeight = data.area.bottomRect.height
      }
    })

    this.mWindow.on('windowStatusChange', (windowStatusType) => {
      let windowModel: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
      windowModel.windowStatusType = windowStatusType
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}