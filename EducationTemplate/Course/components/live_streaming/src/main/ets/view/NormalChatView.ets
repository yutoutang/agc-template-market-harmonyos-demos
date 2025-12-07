/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { BaseChatMessage } from '../models/BaseChatMesage';

@ComponentV2
export struct NormalChatView {
  @Param @Require content: string;
  @Param @Require userName: string;

  build() {
    Text() {
      Span(this.userName + '：')
        .fontColor($r('sys.color.font_on_secondary'));
      Span(this.content);
    }
    .padding({
      left: 10,
      right: 10,
      top: 4,
      bottom: 4
    })
    .fontColor($r('sys.color.font_on_primary'))
    .fontSize(14)
    .fontWeight(500)
    .lineHeight(19)
    .backgroundColor('rgba(0, 0, 0, 0.4)')
    .borderRadius(12);
  }
}

@Builder
export function normalChatViewBuilder(chat: BaseChatMessage) {
  NormalChatView({
    userName: chat.userName,
    content: chat.content,
  });
}
