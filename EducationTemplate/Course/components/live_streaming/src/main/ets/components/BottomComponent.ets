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
import { LiveStreamingVM } from '../viewModels/LiveStreamingVM';

@ComponentV2
export struct BottomComponent {
  @Param isLock: boolean = false;
  @Param isCleanScreen: boolean = false;
  @Param onSubmit: (content: string) => void = () => {
  };
  @Param commentEvent: () => void = () => {
  };
  @Param backClick: () => void = () => {
  };
  @Param moreEvent: () => void = () => {
  };
  @Local inputContent: string = '';
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  inputController: TextInputController = new TextInputController();

  @Builder
  bottomBuilder() {
    if (this.isLock) {
      Row();
    } else {
      Row() {
        Image(this.isCleanScreen ? $r('app.media.icon_barrage_on') : $r('app.media.icon_barrage_off'))
          .width(40)
          .height(40)
          .margin({ right: 8 })
          .onClick(() => {
            this.commentEvent();
          });
        Row() {
          Image(this.liveVM.avatar)
            .width(30)
            .height(30)
            .margin({ left: 2 });

          TextInput({ text: this.inputContent, placeholder: '聊一聊吧', controller: this.inputController })
            .fontSize($r('sys.float.Subtitle_S'))
            .fontColor($r('sys.color.font_on_primary'))
            .placeholderColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .type(InputType.Normal)
            .layoutWeight(1)
            .maxLength(30)
            .margin({ left: -10 })
            .onChange((text) => {
              this.inputContent = text;
            })
            .onSubmit(() => {
              if (this.inputContent.trim().length <= 0) {
                this.getUIContext().getPromptAction().showToast({ message: '输入内容不可为空' });
                this.inputController.stopEditing();
                return;
              }
              this.inputController.stopEditing();
              this.onSubmit(this.inputContent);
              this.inputContent = '';
            });
        }
        .layoutWeight(1)
        .backgroundColor('rgba(46,48,51,1)')
        .borderRadius(20);

        Image($r('app.media.icon_screen'))
          .width(40)
          .height(40)
          .margin({ left: 8, right: 8 })
          .onClick(() => {
            this.backClick();
          });

        Image($r('app.media.icon_dot_grid_01'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.moreEvent();
          });
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .height('100%')
      .padding({ bottom: 20, left: 24, right: 24 });
    }
  }

  build() {
    this.bottomBuilder();
  }
}