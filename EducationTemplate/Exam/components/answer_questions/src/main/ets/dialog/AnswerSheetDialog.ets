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
import { AnswerSheetPage } from '../components/AnswerSheetPage';
import { TopicItemModel } from '../viewModel/TopicItemModel';

/**
 * 底部弹框沉浸式适配
 * 1、设置弹框尾部元素对导航条避让
 */
@ComponentV2
export struct AnswerSheetDialog {
  @Param ques: TopicItemModel[] = [];
  @Param quesType: number = 1;
  @Param practiceDuration: number = 0;
  @Param textTimerController: TextTimerController = new TextTimerController();
  @Event selectIndex: (index: number) => void = () => {
  };
  @Event close: () => void = () => {
  };
  @Event viewReport: () => void = () => {
  };
  @Local bottomHeight: number = 0;

  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext()?.getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      });
    } catch (e) {
    }
  }

  build() {
    AnswerSheetPage({
      practiceDuration: this.practiceDuration,
      quesType: this.quesType,
      ques: this.ques,
      close: () => {
        this.close();
        this.textTimerController.start();
      },
      selectIndex: (index) => {
        this.selectIndex(index);
        this.close();
      },
      viewReport: () => {
        this.viewReport();
      }
    })
      .height('100%');
  }
}