import { CommonConstants } from '../constants/CommonConstants';
import { EventEnum } from '../constants/EventEnum';
import { EventHubUtils } from '../utils/EventHubUtils';

/**
 * 页面跳转对话框
 */
@CustomDialog
export struct CommonPageDialog {
  @State showFlag: Visibility = Visibility.Visible;
  controller: CustomDialogController;
  @BuilderParam buildContent: () => void;

  aboutToAppear(): void {
    EventHubUtils.getInstance().on(EventEnum.PAGE_DIALOG_EVENT, () => {
      this.showFlag = Visibility.Hidden
      setTimeout(() => {
        this.controller.close()
      }, 300)
    })
  }

  build() {
    Column() {
      this.buildContent()
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .visibility(this.showFlag)
    .transition(TransitionEffect.OPACITY.animation({ duration: 300 }).combine(TransitionEffect.translate({ x: 500 })))

  }
}