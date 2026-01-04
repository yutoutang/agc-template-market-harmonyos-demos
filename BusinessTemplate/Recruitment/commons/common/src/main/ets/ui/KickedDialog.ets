import { AppStorageV2, ComponentContent } from '@kit.ArkUI';
import { GlobalContext } from '../basic/GlobalContext';
import { BreakpointModel } from '../model/BreakpointModel';
import { KickedDialogModel } from '../model/KickedDialogModel';
import { CMPromptAction } from '../util/CMPromptAction';

/**
 * 清除缓存确认弹框
 */
export class KickedDialog {
  private constructor() {
  }

  static ShowPopup(dialogVM: KickedDialogModel) {
    if (CMPromptAction.contentNode === undefined) {
      let uiContext = GlobalContext.getUIContext();
      if (uiContext) {
        let contentNode = new ComponentContent(uiContext, wrapBuilder(buildPopup), dialogVM);
        CMPromptAction.uiContext = uiContext;
        CMPromptAction.contentNode = contentNode;
        CMPromptAction.options = {
          alignment: DialogAlignment.Center,
          autoCancel: true,
          onWillDismiss: (_reason: DismissDialogAction) => {
            CMPromptAction.closeDialog();
            return true;
          }
        };
        CMPromptAction.openDialog();
      } else {
      }
    }
  }

  static ClosePopup() {
    CMPromptAction.closeDialog();
  }
}

@ComponentV2
struct popup {
  @Param @Require dialogVM: KickedDialogModel;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Column() {
      Blank().height($r('app.float.vp_16'))

      Text(this.dialogVM.title)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)
        .lineHeight($r('app.float.vp_20'))
        .maxLines(-1)
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })

      Blank().height($r('app.float.vp_16'))

      Row() {
        Button(this.dialogVM.cancelTitle)
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_tertiary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            KickedDialog.ClosePopup();
            this.dialogVM.onValueConcelClick(this.dialogVM);
          })

        Blank()
          .height($r('app.float.vp_22'))
          .width('1px')
          .color($r('sys.color.comp_divider'))

        Button(this.dialogVM.confirmTitle)
          .type(ButtonType.Normal)
          .layoutWeight(1)
          .height('100%')
          .backgroundColor(Color.Transparent)
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            KickedDialog.ClosePopup();
            this.dialogVM.onValueConfirmClick(this.dialogVM);
          })
      }
      .width('100%')
      .height($r('app.float.vp_40'))

      Blank().height($r('app.float.vp_16'))
    }
    .backgroundColor(Color.White)
    .width(this.breakpointModel.currentDisplayWidth > 400 ?
      376 :
      this.breakpointModel.currentDisplayWidth - 32)
    .borderRadius($r('sys.float.corner_radius_level12'))
  }
}

@Builder
function buildPopup(dialogVM: KickedDialogModel) {
  popup({ dialogVM: dialogVM })
}

