/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { ComponentContent, promptAction, window } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';

const TAG = '[PopViewUtils]';

export enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<object>;
  popType: PopViewShowType;
}

export class PopViewUtils {
  private static popShare: PopViewUtils;
  private static uiContext: UIContext;
  private infoList: PopViewModel[] = [];
  private sheetList: PopViewModel[] = [];

  static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  private static showDialog<T extends object>(type: PopViewShowType, contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = getUIContext();
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom,
        autoCancel: options?.autoCancel || false,
        maskColor: options?.maskColor,
        onWillDismiss: (v: DismissDialogAction) => {
          Logger.debug(TAG, 'dismiss reason:' + v.reason)
          if (options?.autoCancel) {
            v.dismiss();
          }
        },
      };
      prompt.openCustomDialog(componentContent, customOptions);
      let infoList = PopViewUtils.shareInstance().infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      infoList[0] = info;
    }
  }

  private static closeDialog(type: PopViewShowType): void {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = getUIContext();
    }
    if (PopViewUtils.uiContext) {
      let prompt = PopViewUtils.uiContext.getPromptAction();
      let sameTypeList = PopViewUtils.shareInstance().infoList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().infoList = PopViewUtils.shareInstance().infoList.filter((model) => {
          return model.com !== info.com;
        })
        prompt.closeCustomDialog(info.com);
      }
    }
  }

  private static showSheetView<T extends Object>(type: PopViewShowType,
    contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>, args?: T,
    options?: SheetOptions): void {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = getUIContext();
    }
    if (PopViewUtils.uiContext) {
      let componentContent: ComponentContent<Object> | null = null;
      if (args) {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView, args);
      } else {
        componentContent = new ComponentContent(PopViewUtils.uiContext, contentView as WrappedBuilder<[]>);
      }
      PopViewUtils.uiContext.openBindSheet(componentContent, options);
      let sheetList = PopViewUtils.shareInstance().sheetList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type,
      };
      sheetList[0] = info;
    }
  }

  private static closeSheetView(type: PopViewShowType): void {
    if (!PopViewUtils.uiContext) {
      PopViewUtils.uiContext = getUIContext();
    }
    if (PopViewUtils.uiContext) {
      let sameTypeList = PopViewUtils.shareInstance().sheetList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info?.com) {
        PopViewUtils.shareInstance().sheetList = PopViewUtils.shareInstance().sheetList.filter((model) => {
          return model.com !== info.com;
        })
        PopViewUtils.uiContext.closeBindSheet(info.com);
      }
    }
  }

  public static showPopView<T extends object>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions): void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  public static closePopView(): void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }

  /**
   * 打开半模态弹窗
   * @param contentView
   * @param args
   * @param options
   */
  public static showSheet<T extends Object>(contentView: WrappedBuilder<[T]> | WrappedBuilder<[]>,
    options?: SheetOptions, args?: T): void {
    PopViewUtils.showSheetView(PopViewShowType.OPEN, contentView, args, options);
  }

  /**
   * 关闭半模态弹窗
   */
  public static closeSheet(): void {
    PopViewUtils.closeSheetView(PopViewShowType.OPEN);
  }
}

function getUIContext() {
  const windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  return windowStage.getMainWindowSync().getUIContext();
}
