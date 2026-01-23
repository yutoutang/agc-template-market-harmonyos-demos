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

import { common } from '@kit.AbilityKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';
import { Logger } from './Logger';

interface DialogParams {
  title: string,
  confirmTitle?: string,
  confirmTitleColor?: string,
  cancelTitle?: string,
  cancelTitleColor?: string,
  confirmFunc?: () => void,
  cancelFunc?: () => void,
  sideslipCancel?: number
}

async function getUIContext() {
  return (await (getContext() as common.UIAbilityContext).windowStage.getMainWindow()).getUIContext()
}

/**
 * 全局弹窗
 */
class DialogUtil {
  static uiContext: UIContext;
  static contentNode: ComponentContent<Object>;
  static options: Object;
  static dialogBuilder: Object;

  static async openDialog(dialogBuilder: WrappedBuilder<[DialogParams]>, params: DialogParams): Promise<void> {
    try {
      if (!DialogUtil.uiContext) {
        DialogUtil.uiContext = await getUIContext()
      }
      DialogUtil.contentNode = new ComponentContent(DialogUtil.uiContext, dialogBuilder, params)
      let options: promptAction.BaseDialogOptions = {
        alignment: DialogAlignment.Center,
        autoCancel: true,
        offset: {
          dx: 0, dy: 0,
        },
        transition: undefined,
        showInSubWindow: false,
        keyboardAvoidMode: KeyboardAvoidMode.NONE,
        onWillDismiss: (action: DismissDialogAction) => {
          if (action.reason === DismissReason.PRESS_BACK) {
            if (params.sideslipCancel) {
              return
            }
            action.dismiss()
            DialogUtil.close()
          }
        },
      }
      let promptAction = DialogUtil.uiContext.getPromptAction()
      promptAction.openCustomDialog(DialogUtil.contentNode, options)
    } catch (error) {
      Logger.error('PromptActionUtils', ` openCustomDialog error = ${JSON.stringify(error)}`)
    }
  }

  static async close(): Promise<void> {
    try {
      const promptAction = DialogUtil.uiContext.getPromptAction()
      promptAction.closeCustomDialog(DialogUtil.contentNode).then(() => {
        if (DialogUtil.contentNode !== null) {
          DialogUtil.contentNode.dispose(); // 释放contentNode
        }
      })
    } catch (error) {
      Logger.error('PromptActionUtils', ` closeCustomDialog error = ${JSON.stringify(error)}`)
    }
  }
}

export { DialogParams, DialogUtil }