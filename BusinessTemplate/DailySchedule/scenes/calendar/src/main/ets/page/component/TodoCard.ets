/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { TodoItem } from '@ohos_agcit/daily_schedule_todo';
import { TODO_CARD_WIDTH } from '../../constant/CalendarConstant';

@ComponentV2
export struct TodoCard {
  @Param item: TodoItem = new TodoItem('1003', '记得上班打卡', new Date('2025-08-28T14:00:00'), 0, 0, 2, false)
  @Param color: ResourceColor = $r('app.color.card_red')

  build() {
    Column() {
      Row() {
        Column() {
        }
        .height('100%')
        .width('5%')
        .backgroundColor(this.color)

        Stack() {
          Text(this.item.title)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(600)
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Start)
            .fontColor(this.color)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Column() {
          }
          .width('100%')
          .height('100%')
          .backgroundColor(this.color)
          .opacity(0.25)
        }
        .height('100%')
        .width('95%')
      }
      .height(28)
      .width(TODO_CARD_WIDTH)
    }
  }
}