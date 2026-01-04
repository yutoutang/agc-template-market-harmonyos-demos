import { CommonConstants } from '../constants/CommonConstants';
import { PopViewUtils } from '../utils/PopViewUtils';

@Builder
export function loadingView() {
  Column({ space: CommonConstants.SPACE_M }) {
    LoadingProgress()
      .color($r('sys.color.icon_on_primary'))
      .width(72)
      .height(72)
    Text('加载中')
      .fontColor($r('sys.color.font_primary'))
      .textAlign(TextAlign.Center)
      .fontSize(16)
  }
  .width(150)
  .aspectRatio(1)
  .justifyContent(FlexAlign.Center)
  .backgroundColor($r('sys.color.comp_background_secondary'))
  .borderRadius($r('app.float.medium_radius'))
}

/**
 * 全局Loading弹窗打开关闭
 */
export class CommonLoadingDialog {
  /**
   * 打开loading
   */
  public static show() {
    PopViewUtils.showPopView(wrapBuilder(loadingView), {
      maskColor: Color.Transparent,
    });
  }

  /**
   * 关闭loading
   */
  public static close() {
    PopViewUtils.closePopView();
  }
}