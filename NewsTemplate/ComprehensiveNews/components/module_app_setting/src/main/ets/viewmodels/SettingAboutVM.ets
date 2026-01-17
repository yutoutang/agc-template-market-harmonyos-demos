import { Want, bundleManager } from '@kit.AbilityKit';
import { LayeredDrawableDescriptor } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppGalleryUtils } from '../common/AppGalleryUtils';
import { ContextUtils } from '../common/ContextUtils';
import { Logger } from '../common/Logger';
import { TelephoneUtils } from '../common/TelephoneUtils';
import { BaseViewModel } from '../models/BaseViewModel';

const TAG = '[SettingAboutVM]';

@ObservedV2
export class SettingAboutVM extends BaseViewModel {
  @Trace appName: string = '';
  @Trace appVersionName: string = '';
  @Trace appIcon: ResourceStr | PixelMap = '';
  @Trace hasNewVersion: boolean = false;
  @Trace updateLabel: string = '检查更新'
  @Trace hotline: string = '000000';
  @Trace loading: boolean = false;

  constructor() {
    super();
    this.getBundleInfo();
  }

  async getBundleInfo() {
    const context = ContextUtils.globalContext;
    if (!context) {
      return;
    }
    try {
      const resource = context.resourceManager;
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      // 获取应用名称
      this.appName = resource.getStringSync(bundleInfo.appInfo.labelId);
      // 获取版本信息
      this.appVersionName = bundleInfo.versionName;
      // 获取应用图标
      const draw = resource.getDrawableDescriptor(bundleInfo.appInfo.iconId);
      const isLayered = draw instanceof LayeredDrawableDescriptor;
      if (isLayered) {
        let layered = draw as LayeredDrawableDescriptor;
        this.appIcon = layered.getPixelMap();
      } else {
        this.appIcon = resource.getMediaContentBase64Sync(bundleInfo.appInfo.iconId);
      }
    } catch (e) {
      Logger.error(TAG, 'getBundleInfo fail, error: ' + JSON.stringify(e));
    }
  }

  checkUpdate() {
    const context = ContextUtils.globalUIAbilityContext;
    if (!context) {
      return;
    }
    this.loading = true;
    AppGalleryUtils.checkAppUpdate(context).then((resp: boolean) => {
      this.hasNewVersion = resp;
      this.updateLabel = this.hasNewVersion ? '存在新版本' : '已是最新版本';
      if (this.hasNewVersion) {
        AppGalleryUtils.showUpdateDialog(context);
      } else {
        ContextUtils.showToast({ message: this.updateLabel });
      }
    }).finally(() => {
      this.loading = false;
    })
  }

  callHotline() {
    TelephoneUtils.callPhone(this.hotline);
  }

  goWebsite() {
    const context = ContextUtils.globalUIAbilityContext;
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: 'https://beian.miit.gov.cn/#/home',
    }
    context?.startAbility(want).catch((e: BusinessError) => {
      Logger.error(TAG, 'startAbility fail, error: ' + JSON.stringify(e));
    });
  }
}
