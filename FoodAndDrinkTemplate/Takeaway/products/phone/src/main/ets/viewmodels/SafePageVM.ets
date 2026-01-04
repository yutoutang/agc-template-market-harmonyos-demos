import { BaseViewModel, PreferenceUtils, RouterMap, RouterUtils } from 'lib_common';
import { agreePrivacyKey } from '../common/Constants';

@ObservedV2
export class SafePageVM extends BaseViewModel {
  privacyClick() {
    RouterUtils.pushPathByName(RouterMap.PRIVACY_PAGE);
  }

  /**
   * 同意按钮点击
   */
  agreeBtnClick() {
    PreferenceUtils.getInstance().put(agreePrivacyKey, true);
    RouterUtils.clearStack();
    // 非首次启动开屏页
    RouterUtils.pushPathByName(RouterMap.INDEX_PAGE, null, undefined, false);
  }

  cancelBtnClick() {
    RouterUtils.pushPathByName(RouterMap.AGREE_PRIVACY_PAGE);
  }

  quitApp() {
    getContext().getApplicationContext().killAllProcesses();
  }
}
