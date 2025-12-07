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

import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { TopBar } from 'commonlib';
import { MessageItem, NumbObj } from '../models/MessageModel';
import { MessageListCard } from '../views/MessageListCard';
import { RouterMap, RouterModule } from 'commonlib';

@ComponentV2
export struct MessagePage {
  @Local propNumbObj: NumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;

  build() {
    Column() {
      this.topBuilder();
      Scroll() {
        Column() {
          this.messageItemBuilder();
        }
        .width('100%')
        .height('100%');
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%');
  }

  /**
   * 消息列表
   */
  @Builder
  messageItemBuilder() {
    List({ space: 2 }) {
      ForEach(this.propNumbObj.listArr, ((item: MessageItem, index: number) => {
        ListItem() {
          MessageListCard({ info: item })
            .onClick(() => {
              this.jumpMessageDetail(index);
            });
        };
      }), (item: MessageItem, index: number) => item.id + index);
    }
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .width('100%')
    .height('auto');
  }

  //进入消息详情
  jumpMessageDetail(index: number) {
    if (index === 0) {
      //系统消息
      RouterModule.push({ url: RouterMap.SYSTEM_MESSAGE_PAGE });
    } else {
      //课程消息
      RouterModule.push({ url: RouterMap.COURSE_MESSAGE_PAGE });
    }
  }

  /**
   * 顶部
   */
  @Builder
  topBuilder() {
    Row() {
      TopBar({ title: $r('app.string.message_notice') });
      Row() {
        Image($r('app.media.ic_public_trash'))
          .height($r('app.float.vp_40'))
          .width($r('app.float.vp_40'));
      }
      .onClick(() => {
        this.refreshData();
        //清空消息
        promptAction.showToast({ message: $r('app.string.operation_successful') });
        this.delayExecution();
      });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height($r('app.float.vp_56'))
    .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
  }

  //更新信息清空角标
  refreshData() {
    let propNumbObj = AppStorageV2.connect(NumbObj, () => new NumbObj())!;
    propNumbObj.listArr.forEach((item: MessageItem) => {
      item.unreadMessageCount = 0;
      item.isClearMessage = true;
    });
  }

  //延时操作
  delayExecution() {
    setTimeout(() => {
      promptAction.showToast({ message: $r('app.string.no_unreadMessageCount') });
    }, 1000);
  }
}

@Builder
export function MessageBuilder() {
  MessagePage();
}