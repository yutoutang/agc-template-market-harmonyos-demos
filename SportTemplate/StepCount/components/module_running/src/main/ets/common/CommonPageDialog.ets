import { RunEventHubUtils } from '../utils/RunEventHubUtils';
import { RunCommonConstants } from './RunCommonConstants';
import { RunEventEnum } from './RunEventEnum';

/**
 * 页面跳转对话框
 */
@CustomDialog
export struct CommonPageDialog {
  controller: CustomDialogController;
  @State showFlag: Visibility = Visibility.Visible;
  @BuilderParam buildContent: () => void;

  aboutToAppear(): void {
    // 监听事件
    RunEventHubUtils.getInstance().on(RunEventEnum.PAGE_DIALOG_EVENT, () => {
      // 隐藏
      this.showFlag = Visibility.Hidden
      // 延迟关闭
      setTimeout(() => {
        // 关闭
        this.controller.close()
      }, 300)
    })
  }

  build() {
    Column() {
      this.buildContent()
    }
    .height(RunCommonConstants.FULL_PERCENT)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }).combine(TransitionEffect.translate({ x: 500 })))
    .width(RunCommonConstants.FULL_PERCENT)
    .visibility(this.showFlag)

  }
}