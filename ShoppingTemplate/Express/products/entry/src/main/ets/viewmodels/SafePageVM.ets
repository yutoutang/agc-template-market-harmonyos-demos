import { RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base';

@ObservedV2
export class SafePageVM {
  privacyClick() {
    RouterModule.push({ url: RouterMap.PRIVACY_PAGE });
  }

  agreeBtnClick() {
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
