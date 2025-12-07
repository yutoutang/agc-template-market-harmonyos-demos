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

import { AppStorageV2, window } from '@kit.ArkUI';
import { RouterMap, RouterModule, WindowSize } from 'commonlib';
import { ChatViewVM } from 'live_streaming';

@ComponentV2
export struct InputComment {
  @Local vm: ChatViewVM = ChatViewVM.instance;
  @Local keyboardHeight: number = 0;
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
  @Local inputNum: number = 0;
  @Local contentHeight: number = 30
  @Local content: string = '';
  private uiContext: UIContext = this.getUIContext()
  textSize: SizeOptions = {};
  screenWidth: number = 0
  controller: TextAreaController = new TextAreaController();

  @Builder
  ToolBar() {
    Row() {
      TextArea({ placeholder: '聊一聊吧', text: this.content, controller: this.controller })
        .width('90%')
        .height(this.contentHeight)
        .fontSize('16fp')
        .fontWeight(500)
        .lineHeight(18)
        .padding(5)
        .maxLength(30)
        .backgroundColor(Color.Transparent)
        .defaultFocus(true)
        .barState(BarState.Off)
        .onChange((value: string) => {
          this.content = value
          this.checkMaxLength(value)
          this.contentSizeChange()
        })

      Image($r('app.media.paper_plane'))
        .width($r('app.float.vp_24'))
        .height($r('app.float.vp_24'))
        .margin({ right: $r('app.float.vp_12'), bottom: $r('app.float.vp_5') })
        .onClick(() => {
          this.controller.stopEditing()
          this.onSubmit()
        })
    }
    .width('95%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
    .margin(10)
    .padding({ left: 5 })
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .borderRadius(20)
  }

  aboutToAppear(): void {
    this.getCurrentScreen()
    window.getLastWindow(getContext(this)).then(win => {
      this.addKeyboardHeightListener(win);
    });
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext(this)).then(win => {
      this.removeKeyboardHeightListener(win);
    });
  }

  build() {
    Stack() {
      Column() {
        this.ToolBar()
        Divider()
        Column()
          .height(this.keyboardHeight)
      }
      .backgroundColor(Color.White)
    }
    .height('100%')
    .width('100%')
    .alignContent(Alignment.Bottom)
    .expandSafeArea([SafeAreaType.KEYBOARD])
  }

  onSubmit() {
    if (this.content.trim() === '') {
      this.getUIContext().getPromptAction().showToast({ message: '输入内容不可为空' })
    } else {
      this.vm.onSubmit(this.content)
    }
    this.content = ''
    let paths: string[] = RouterModule.stack.getAllPathName()
    let isExit = paths.includes(RouterMap.INPUT_COMMENT_PAGE)
    if (isExit) {
      RouterModule.pop()
    }
  }

  addKeyboardHeightListener(win: window.Window) {
    win.on('keyboardHeightChange', height => {
      if (height !== 0) {
        this.keyboardHeight = this.getUIContext().px2vp(height - this.windowSize.bottomHeight);
        return;
      } else {
        this.keyboardHeight = 0
        let paths: string[] = RouterModule.stack.getAllPathName()
        let isExit = paths.includes(RouterMap.INPUT_COMMENT_PAGE)
        if (isExit) {
          RouterModule.pop()
        }
      }
    });
  }

  removeKeyboardHeightListener(win: window.Window) {
    win.off('keyboardHeightChange');
  }

  contentSizeChange() {
    this.textSize = this.uiContext.getMeasureUtils().measureTextSize({
      textContent: this.content,
      fontSize: '16fp',
      lineHeight: 18,
      fontWeight: 500,
      constraintWidth: (this.screenWidth * 0.95 * 0.90 - 10 - 5)
    });
    this.contentHeight = Math.max(this.uiContext.px2vp(Number(this.textSize.height)), 20) + 10;
  }

  checkMaxLength(content: string) {
    if (content.trim().length >= 30) {
      this.getUIContext().getPromptAction().showToast({
        message: '最多只能输入30字',
        duration: 2000
      });
    }
  }

  /**
   * 获取当前屏幕宽高
   */
  getCurrentScreen() {
    this.screenWidth = this.uiContext.px2vp(this.windowSize.screenWidth);
  }
}


@Builder
export function InputCommentBuilder() {
  InputComment();
}