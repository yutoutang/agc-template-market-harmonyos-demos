import { AbilityConstant, bundleManager, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { cloudFunction, cloudResPrefetch } from '@kit.CloudFoundationKit';
import { AppInfoModel, Constants, FormCard, FormCardJump, MyCarModel, StoreInfoModel, WindowModel } from 'common';
import { pushService } from '@kit.PushKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreloadResponse } from 'network';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 在应用启动时调用函数获取应用数据
    this.functionPreload();
    // 获取应用包名
    let bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY |
    bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION);
    let packageName = bundleInfo.name;
    let appInfo: AppInfoModel = AppStorageV2.connect(AppInfoModel, () => new AppInfoModel())!;
    appInfo.packageName = bundleInfo.name;
    console.info(`packageName: ${JSON.stringify(packageName)}.`);
    this.resolvePagePath(want);
    // 获取Push Token
    try {
      const pushToken: string = await pushService.getToken();
      hilog.info(0x0000, 'testTag', 'Succeeded in getting push token');
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      hilog.error(0x0000, 'testTag', 'Failed to get push token: %{public}d %{public}s', e.code, e.message);
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口
      // 设置窗口全屏
      await windowClass.setWindowLayoutFullScreen(true);
      let type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
      let avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowTopHeight = px2vp(avoidArea.topRect.height);
      type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
      avoidArea = windowClass.getWindowAvoidArea(type);
      windowModel.windowBottomHeight = px2vp(avoidArea.bottomRect.height);
    });
    windowModel.windowStage = windowStage
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.resolvePagePath(want);
  }

  resolvePagePath(want: Want) {
    // 从want中获取传入的链接信息
    let uri = want?.uri;
    let parameters = want?.parameters;
    console.info(`uri is: ${uri}`);
    if (uri) {
      //解析通过router跳转的页面
      let storeInfoModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!
      storeInfoModel.storeId = want.parameters?.sid as string;
      console.info(`storeId is: ${storeInfoModel.storeId}`);
      // 桌号
      let myCarModel: MyCarModel = AppStorageV2.connect(MyCarModel, () => new MyCarModel())!
      myCarModel.tableId = want.parameters?.tid as string;
      console.info(`tableId is: ${myCarModel.tableId}`);
      // 扫码进入清空购物车
      storeInfoModel.qrCodeFlag = true
    } else if (parameters?.url) {
      let formCardJump: FormCardJump = JSON.parse(parameters?.params.toString() || '');
      let formCard: FormCard = AppStorageV2.connect(FormCard, () => new FormCard())!
      if (formCardJump?.params?.orderId) {
        formCard.id = new Date().getTime()
        formCard.orderId = formCardJump.params.orderId
        formCard.url = parameters?.url as string
      }
    }
  }

  functionPreload() {
    try {
      cloudResPrefetch.getPrefetchResult(cloudResPrefetch.PrefetchMode.INSTALL_PREFETCH)
        .then((data: cloudResPrefetch.PrefetchResult) => {
          hilog.info(0x0000, 'testTag',
            `Succeeded in getting install prefetch data, result: ${JSON.stringify(data.result)}`);
          this.initPreload(data.result as PreloadResponse); // data.result即是缓存的应用数据
        }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag',
          `Failed to get install prefetch data, code: ${err.code}, message: ${err.message}`);
        // 使用原有方式获取应用数据
        this.functionNormal();
      })
    } catch (e) {
      this.initPreload()
    }
  }

  functionNormal() {
    hilog.info(0x0000, 'testTag', 'promise start');
    let promise = cloudFunction.call({
      name: 'preload',
      timeout: Constants.REQUEST_TIME_OUT,
      loadMode: cloudFunction.LoadMode.NORMAL, // 默认为NORMAL, 接口会调用云函数从云服务器获取应用数据
    });
    promise.then((data: cloudFunction.FunctionResult) => {
      hilog.info(0x0000, 'testTag', 'call function successfully');
      this.initPreload(data.result as PreloadResponse); // data.result即是缓存的应用数据
    }).catch((err: Error) => {
      hilog.info(0x0000, 'testTag', 'fail to call function: %{public}s', err.message);
      this.initPreload(); // data.result即是缓存的应用数据
    });
  }

  initPreload(result?: PreloadResponse) {
    let storeInfo: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel()) as StoreInfoModel;
    storeInfo.preloadFinished = true
    if (result) {
      if (result.appInfo) {
        storeInfo.storeId = result.appInfo.storeId;
        storeInfo.storeType = result.appInfo.storeType;
      }
      if (result.tableList?.length) {
        storeInfo.tableList = result.tableList;
      }
    }
  }
};
