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

import { window } from '@kit.ArkUI';

@ComponentV2
export struct AddNotePage {
  bottomHeight: number = 0;
  @Once @Param note: string = '';
  @Param close: () => void = () => {
  };
  @Param confirmAddNote: (note: string) => void = () => {
  }

  aboutToAppear(): void {
    try {
      // 获取导航条高度，手动进行避让
      window.getLastWindow(getContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    }catch (e) {
    }
  }

  build() {
    Column() {
      // 手势处理
      this.gestureHandleBuilder()
      // 标题
      this.titleBuilder()
      // 添加笔记输入框
      this.inputBoxBuilder()
    }
    .backgroundColor(Color.White)
    .layoutWeight(1)
    .height('100%')
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
    .borderRadius({ topLeft: $r('sys.float.corner_radius_level16'),
      topRight: $r('sys.float.corner_radius_level16') })
  }

  // 添加笔记输入框
  @Builder
  inputBoxBuilder() {
    TextArea({ placeholder: '输入笔记内容', text: this.note })
      .height($r('app.float.vp_152'))
      .maxLength(200)
      .showCounter(true)
      .onChange((value: string) => {
        this.note = value;
      })
  }

  // 答题卡手势处理
  @Builder
  gestureHandleBuilder() {
    Row() {
      Row()
        .width($r('app.float.vp_56'))
        .height($r('app.float.vp_5'))
        .backgroundColor($r('app.color.gesture_handle'))
        .borderRadius(3)
        .margin({ top: $r('app.float.vp_8') })
    }
    .justifyContent(FlexAlign.Center)
  }

  // 标题
  @Builder
  titleBuilder() {
    Row() {
      Row() {
        Image($r('app.media.close_btn'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .onClick(this.close)
          .id('close_button')
        Text($r('app.string.add_note'))
          .fontSize($r('sys.float.Title_S'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .margin({ left: $r('app.float.vp_12') })
      }

      Image($r('app.media.confirm_btn'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.confirmAddNote(this.note)
        })
        .id('confirm_button')
    }
    .width('100%')
    .height($r('app.float.vp_56'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
