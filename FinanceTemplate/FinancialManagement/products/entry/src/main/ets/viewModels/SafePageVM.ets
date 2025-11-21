import { PreferenceUtil, RouterMap, RouterModule } from 'module_base';

@ObservedV2
export class SafePageVM {
  privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY });
  }

  agreeBtnClick() {
    PreferenceUtil.getInstance().put('SafePrivacy', true)
    RouterModule.clear()
    RouterModule.push({ url: RouterMap.MAIN_ENTRY });
  }

  cancelBtnClick() {
    RouterModule.push({ url: RouterMap.AGREE_PRIVACY_PAGE });
  }

  quitApp() {
    getContext().getApplicationContext().killAllProcesses();
  }
}
