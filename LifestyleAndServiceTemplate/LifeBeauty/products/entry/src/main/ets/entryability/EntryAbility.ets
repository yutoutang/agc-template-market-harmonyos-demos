import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { CommonConstants, CustomShareModel, RouterModule, ShareInfo, WindowUtil } from 'foundation';

const TAG = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.setGlobalConfig({
      tag: 'LifeBeauty', // 指定日志标识
      domain: 0xff00, // 日志对应的领域标识
      open: true,
      showStack: false,
    })
    Logger.info(TAG, 'Ability onCreate');
    this.handleShare(want);
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleShare(want);
  }

  onShare(wantParams: Record<string, Object>) {
    // 指定页面支持分享按钮点击事件
    let currentName: string[] = RouterModule.getStack().getAllPathName()
    let showShareMenu = false
    if (currentName.length && CommonConstants.SHARE_PAGES.includes(currentName[currentName.length-1])) {
      showShareMenu = true
    }
    const shareParams: ShareInfo = {
      showShareMenu,
      title: '美业元服务分享',
      description: '美业元服务分享',
      parameters: {} as CustomShareModel,
    };
    // 分享方：从临时缓存中获取自定义参数来设置want
    const instance = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
    if (instance.goodId) {
      const pageParams: CustomShareModel = {
        id: instance.id,
        pageName: instance.pageName,
        goodId: instance.goodId,
        goodName: instance.goodName,
        goodType: instance.goodType,
      }
      shareParams.title = pageParams.goodName;
      shareParams.description = pageParams.goodName;
      shareParams.parameters = pageParams;
    }

    wantParams['atomicservice.param.key.shareInfo'] = shareParams;
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'Succeeded in loading the content.');
      // 初始化全局使用的uiContext
      WindowUtil.init(windowStage.getMainWindowSync().getUIContext());
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  handleShare(want: Want) {
    // 接收方：从want中获取自定义参数，用于后续实现页面的路由跳转
    const paramStr = want?.parameters?.custShareParam as string;
    const shareParams: CustomShareModel = JSON.parse(paramStr || '{}');
    if (shareParams?.goodId) {
      const shareRouter: CustomShareModel = AppStorageV2.connect(CustomShareModel, () => new CustomShareModel())!;
      shareRouter.pageName = shareParams.pageName;
      shareRouter.goodId = shareParams.goodId;
      shareRouter.goodType = shareParams.goodType;
      shareRouter.id = new Date().getTime();
    }
  }
}
