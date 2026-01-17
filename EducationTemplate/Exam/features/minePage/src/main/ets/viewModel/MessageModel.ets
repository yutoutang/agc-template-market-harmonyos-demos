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

@ObservedV2
export class MessageItem {
  @Trace id: string
  @Trace icon: ResourceStr
  @Trace title: string
  @Trace subtitle: string
  @Trace time: string
  @Trace isDelete: boolean = false

  constructor(id: string, icon: ResourceStr, title: string, subtitle: string, time: string, isDelete: boolean) {
    this.id = id
    this.icon = icon
    this.title = title
    this.subtitle = subtitle
    this.time = time
    this.isDelete = isDelete
  }
}

// 存储消息中心数据
@ObservedV2
export class NumbObj {
  @Trace listArr: MessageItem[] = [
    new MessageItem('11', $r('app.media.icon_msg'), '热门活动', '端午佳节 更多活动惊喜等着你！', '3分钟前', false),
    new MessageItem('22', $r('app.media.icon_msg2'), '华为用户', '一级建造师精华题库更新了，快来学习吧~', '1小时前',
      false),
    new MessageItem('33', $r('app.media.Mask'), '华为用户', '我更新了新的试卷，快来学习吧~', '1小时前', false),
  ]
}