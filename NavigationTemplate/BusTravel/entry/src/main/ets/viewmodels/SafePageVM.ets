import { PreferenceUtils, RouterModule, Common } from 'common'

@ObservedV2
export class SafePageVM {
  // 跳转隐私协议页面
  privacyClick() {
    RouterModule.push({
      url: 'PrivacyPolicyDetailPage'
    })
  }

  agreeBtnClick() {
    PreferenceUtils.getInstance().put(Common.AGREE_PRIVACY_KEY, true)
    RouterModule.clear()
  }

  // 点击取消按钮弹出确认退出弹框
  cancelBtnClick() {
    RouterModule.push({
      url: 'AgreePrivacyPage'
    })
  }

  quitApp() {
    getContext().getApplicationContext().killAllProcesses()
  }
}
