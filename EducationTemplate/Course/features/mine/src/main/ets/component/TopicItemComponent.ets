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
import { SourceTextModifier } from 'commonlib';

@ComponentV2
export struct TopicItemComponent {
  @Local sourceTextModifier: SourceTextModifier = new SourceTextModifier()
  // 题目标题
  @Require @Param topicTitle: string;
  // 题目来源
  @Require @Param topicSource: string;

  build() {
    Column({ space: 4 }) {
      Text($r('app.string.single_choice'))
        .width($r('app.float.vp_28'))
        .height($r('app.float.vp_16'))
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(4)
      Text(this.topicTitle)
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .wordBreak(WordBreak.BREAK_ALL)
      Text() {
        Span($r('app.string.topic_source'))
        Span(this.topicSource)
      }
      .attributeModifier(this.sourceTextModifier)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding($r('app.float.vp_12'))
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .margin({ top: $r('app.float.vp_12') })
  }
}
 