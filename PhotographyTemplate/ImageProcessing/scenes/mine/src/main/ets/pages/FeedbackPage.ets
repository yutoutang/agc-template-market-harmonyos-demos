/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  MyScrollModifier,
  PreferConstant,
  PreferenceUtil,
  RouterMap,
  RouterModule,
  TopBar,
  TopRowModifier
} from 'commonlib';
import { Feedback, FeedbackModel } from 'feed_back';

@ComponentV2
export struct FeedbackPage {
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()
  @Local topRowModifier: TopRowModifier = new TopRowModifier()

  build() {
    NavDestination(){
      Column() {
        // 顶部导航
        this.feedbackTopBuilder()
        Scroll() {
          Feedback({
            maxLength: 100,
            maxCount: 5,
            submitClick: (feedbackData: FeedbackModel) => {
              // 提交反馈
              this.submitClick(feedbackData);
            }
          })
        }
        .attributeModifier(this.scrollModifier)
      }
      .width('100%')
      .height('100%')
    }.backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }

  /**
   * 顶部
   */
  @Builder
  feedbackTopBuilder() {
    Row() {
      TopBar({ title: '反馈问题' })
    }
    .attributeModifier(this.topRowModifier)
  }

  submitClick(feedbackData: FeedbackModel) {
    PreferenceUtil.getInstance(PreferConstant.FEEDBACK_RECORDS).put(feedbackData.id, feedbackData);
    this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
    RouterModule.replace({ url: RouterMap.FEEDBACK_RECORDS_PAGE })
  }
}

@Builder
export function FeedbackPageBuilder() {
  FeedbackPage()
}