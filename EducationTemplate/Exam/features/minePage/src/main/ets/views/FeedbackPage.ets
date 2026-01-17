/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an ''AS IS'' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { PreferenceUtil, PreferConstant } from 'commonlib';
import { Feedback, FeedbackItemType } from 'feed_back';
import { Header } from '../components/Header';
import { RouterModule } from 'router_module';

@ComponentV2
export struct FeedbackPage {
  // 接收意见反馈har返回来的数据
  @Local feedList: FeedbackItemType = {
    description: '',
    stageImageUris: [],
    phone: '',
    time: ''
  }

  build() {
    Column() {
      Header({ title: '意见反馈' })
      Feedback({
        des: 99,
        num: 3,
        butOnClick: (val: FeedbackItemType) => {
          this.feedList = val;
          let info = PreferenceUtil.getInstance().get(PreferConstant.FEEDBACK_RECORD, []) as FeedbackItemType[]
          let arr: FeedbackItemType[] = []
          info.forEach((model: FeedbackItemType) => {
            arr.push(model)
          })
          arr.push(this.feedList)
          PreferenceUtil.getInstance().put(PreferConstant.FEEDBACK_RECORD, arr)
          this.getUIContext().getPromptAction().showToast({ message: '提交成功', duration: 2000 });
          RouterModule.pop()
        }
      })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}

@Builder
export function FeedbackPageBuilder() {
  FeedbackPage()
}
