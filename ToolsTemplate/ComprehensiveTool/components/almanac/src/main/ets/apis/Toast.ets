import { ComponentContent, PromptAction, UIObserver, window } from '@kit.ArkUI'

@ComponentV2
struct CustomBuilder {
  @BuilderParam customContent: () => void;
  @BuilderParam customFooter: () => void;
  @Param @Require option: ToastOption;

  build() {
    Column() {
      Column() {
        Text(this.option.hasTitle)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
      }
      .margin({ bottom: 16 })
      .alignItems(HorizontalAlign.Center)

      Column() {
        this.customContent()
      }

      Row() {
        this.customFooter()
      }
      .height(60)
      .margin({ top: 19 })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.SpaceBetween)
    .width(328)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(32)
    .padding({ top: 20, left: 16, right: 16 })
  }
}

class ToastOption {
  /**
   * toast类型
   */
  type: 'loading' | 'dialog' | 'custom' = 'loading';
  /**
   * dialog类型时提示语
   */
  message?: ResourceStr = '';
  /**
   * 是否显示标题
   */
  hasTitle?: ResourceStr = '';
  /**
   * 确认回调
   */
  confirmAction?: (selected?: number | number [] | string[]) => void = () => {
  };
  /**
   * 取消回调
   */
  cancelAction?: () => void = () => {
  };
  /**
   * 自定义主体内容
   */
  customContent?: () => void = () => {
  };
  /**
   * 自定义底部内容
   */
  customFooter?: () => void = () => {
  };
  /**
   * 确认按钮颜色
   */
  confirmColor?: ResourceStr | Color = $r('sys.color.font_emphasize');
  /**
   * 取消按钮颜色
   */
  cancelColor?: ResourceStr | Color = $r('sys.color.font_emphasize');
}

@Builder
function loadingBuilder(option: ToastOption) {
  Column() {
    LoadingProgress().height(40).width(40)
    Text(option.message ?? '加载中')
  }
  .padding({
    left: 25,
    right: 25,
    top: 20,
    bottom: 20,
  })
  .borderRadius(12)
  .backgroundColor($r('sys.color.background_primary'))
}

@Builder
function dialogBuilder(options: ToastOption) {
  Column() {
    if (options.hasTitle) {
      Column() {
        Text(options.hasTitle)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Title_S'))
      }
    }
    Column() {
      Row({ space: 10 }) {
        Text(options.message)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
      }
    }
    .layoutWeight(1)
    .margin({ top: 16 })
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.Center)

    Row() {
      Text('取消')
        .fontWeight(FontWeight.Medium)
        .fontColor(options.cancelColor ? options.cancelColor : $r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .onClick(() => {
          baseToast.hideAll();
        })
        .textAlign(TextAlign.Center)
        .width('50%')
        .height('100%')
      Text('确认')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor(options.confirmColor ? options.confirmColor : $r('sys.color.font_emphasize'))
        .onClick(() => {
          options?.confirmAction?.();
        })
        .textAlign(TextAlign.Center)
        .width('50%')
        .height('100%')
    }
    .height(60)
    .width('100%')
    .margin({ top: 19 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .height(150)
  .width(328)
  .borderRadius(32)
  .padding({ top: 20 })
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor($r('sys.color.background_primary'))
}

/**
 * 集中处理插槽
 */
@Builder
function defaultBuilder(options: ToastOption) {
  if (options?.type === 'loading') {
    loadingBuilder(options)
  } else if (options?.type === 'dialog') {
    dialogBuilder(options)
  } else if (options?.type === 'custom') {
    CustomBuilder({
      option: options,
      customContent: options.customContent,
      customFooter: options.customFooter,
    })
  }
}

class Toast {
  private uiObserver: UIObserver | null = null;
  private promptAction: PromptAction | null = null;
  private loadingDialog: ComponentContent<ToastOption> | null = null;
  private static _instance: Toast = new Toast();
  private loadingDialogArray: ComponentContent<ToastOption>[] = [];

  constructor() {
  }

  private static getInstance(loadingDialog: ComponentContent<ToastOption>, promptAction: PromptAction,
    uiObserver: UIObserver): Toast {
    if (!Toast._instance) {
      Toast._instance = new Toast();
    }
    Toast._instance.uiObserver = uiObserver;
    Toast._instance.loadingDialog = loadingDialog;
    Toast._instance.loadingDialogArray?.push(loadingDialog);
    Toast._instance.promptAction = promptAction;
    return Toast._instance;
  }

  private async open(options: ToastOption) {
    let windowClass = await window.getLastWindow(getContext());
    let uiContext = windowClass.getUIContext();
    let loadingDialog = new ComponentContent(uiContext, wrapBuilder(defaultBuilder), options);
    let promptAction = uiContext.getPromptAction();
    let uiObserver = uiContext.getUIObserver();
    Toast._instance = Toast.getInstance(loadingDialog, promptAction, uiObserver);
    await promptAction.openCustomDialog(loadingDialog, {
      isModal: true,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      transition: TransitionEffect.IDENTITY,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss();
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss();
        }
      },
    });
  }

  /**
   * 显示弹窗
   */
  public show(option: ToastOption) {
    this.open(option);
  }

  /**
   * 关闭弹窗
   */
  public hide() {
    this.autoHide();
  }

  private async autoHide() {
    if (Toast._instance === null || Toast._instance.loadingDialog === null) {
      return;
    }
    await Toast._instance.promptAction?.closeCustomDialog(Toast._instance.loadingDialog);
    Toast._instance.loadingDialog?.dispose();
  }

  public hideAll() {
    setTimeout(() => {
      if (Toast._instance === null || Toast._instance.loadingDialogArray?.length <= 0) {
        return;
      }
      Toast._instance.loadingDialogArray?.forEach(async (item: ComponentContent<ToastOption>) => {
        await Toast._instance.promptAction?.closeCustomDialog(item);
        item?.dispose();
      })
    }, 1);
  }
}

const baseToast = new Toast();

export { baseToast };