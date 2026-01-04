import { AlertDialog } from '@kit.ArkUI';
import { CommonConstants } from '../constants/CommonConstants';
import { GridRowColSetting } from '../constants/GridRowColSetting';
import { PopViewUtils } from '../utils/PopViewUtils';

export interface IConfirmDialogParams {
  primaryTitle?: ResourceStr;
  secondaryTitle?: ResourceStr;
  content: ResourceStr;
  priBtnV?: ResourceStr;
  secBtnV?: ResourceStr;
  priBtnFg?: ResourceColor;
  secBtnFg?: ResourceColor;
  confirm?: () => void;
  cancel?: () => void;
}

class ConfirmDialogParams implements IConfirmDialogParams {
  primaryTitle: ResourceStr = '';
  secondaryTitle: ResourceStr = '';
  priBtnV: ResourceStr = '取消';
  content: ResourceStr = '';
  secBtnV: ResourceStr = '确定';
  secBtnFg: ResourceColor = $r('app.color.app_theme');
  priBtnFg: ResourceColor = $r('app.color.app_theme');

  constructor(item: IConfirmDialogParams) {
    this.content = item.content;
    if (item.secondaryTitle) {
      this.secondaryTitle = item.secondaryTitle;
    }
    if (item.primaryTitle) {
      this.primaryTitle = item.primaryTitle;
    }
    if (item.priBtnV) {
      this.priBtnV = item.priBtnV;
    }
    if (item.priBtnFg) {
      this.priBtnFg = item.priBtnFg;
    }
    if (item.secBtnV) {
      this.secBtnV = item.secBtnV;
    }
    if (item.confirm) {
      this.confirm = item.confirm;
    }
    if (item.secBtnFg) {
      this.secBtnFg = item.secBtnFg;
    }
    if (item.cancel) {
      this.cancel = item.cancel;
    }
  }

  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
}

@Builder
function confirmDialogView(params: ConfirmDialogParams) {
  Column() {
    Column() {
      AlertDialog({
        secondaryTitle: params.secondaryTitle,
        primaryTitle: params.primaryTitle,
        content: params.content,
        primaryButton: {
          value: params.priBtnV,
          background: Color.Transparent,
          fontColor: params.priBtnFg || $r('app.color.app_theme'),
          action: () => {
            PopViewUtils.closePopView();
            params.cancel();
          },
        },
        secondaryButton: {
          fontColor: params.secBtnFg || $r('app.color.app_theme'),
          background: Color.Transparent,
          value: params.secBtnV,
          action: () => {
            PopViewUtils.closePopView();
            params.confirm();
          },
        },
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius($r('app.float.xxl_radius'))
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
  }
  .width(CommonConstants.FULL_PERCENT)
  .padding({

    right: CommonConstants.PADDING_PAGE,
    left: CommonConstants.PADDING_PAGE,
  })
}

/**
 * 通用确认弹窗
 */
export class CommonConfirmDialog {
  /**
   * 打开弹窗
   * @param param
   */
  public static show(param: IConfirmDialogParams) {
    PopViewUtils.showPopView<ConfirmDialogParams>(wrapBuilder(confirmDialogView), {}, new ConfirmDialogParams(param));
  }
}